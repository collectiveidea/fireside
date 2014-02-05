module StreamingHelpers
  SERVER_HOST = "127.0.0.1"

  extend ActiveSupport::Concern

  included do
    attr_reader :server, :server_port, :server_thread, :response
  end

  def with_server
    start_server
    yield
  ensure
    stop_server
  end

  def stream(path, headers = {})
    headers.reverse_merge!(default_headers)

    chunks = []

    begin
      client_thread = Thread.new do
        Net::HTTP.start(SERVER_HOST, server_port) do |http|
          request = Net::HTTP::Get.new(path)

          headers.each do |name, value|
            request[name] = value
          end

          http.request(request) do |response|
            Thread.current[:response] = response

            response.read_body do |value|
              if value.present?
                chunks << build_chunk(value, headers)
              end
            end
          end
        end
      end

      wait_for_server

      yield chunks
    end

    response = client_thread[:response]
    @response = ActionDispatch::TestResponse.new(
      response.code,
      response.to_hash,
      chunks.join("\n")
    )
  end

  private

  def start_server
    @server = Puma::Server.new(Rails.application)
    @server_port = find_available_server_port
    server.add_tcp_listener(SERVER_HOST, server_port)
    @server_thread = server.run
  end

  def find_available_server_port
    server = TCPServer.new(SERVER_HOST, 0)
    server.addr[1]
  ensure
    server.close if server
  end

  def stop_server
    server_thread.kill if server_thread
  end

  def wait_for_server
    sleep 0.1 until server.running > 0
  end

  def build_chunk(value, headers)
    accept = Mime::Type.lookup(headers["Accept"])

    if accept.json? || accept.xml?
      Content.new(value, accept)
    else
      value
    end
  end
end

RSpec.configure do |config|
  config.include(StreamingHelpers, type: :request, streaming: true)

  config.around(type: :request, streaming: true) do |example|
    with_truncation { with_server { example.run } }
  end
end
