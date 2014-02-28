module StreamingHelpers
  SERVER_HOST = "127.0.0.1"

  extend ActiveSupport::Concern

  included do
    attr_reader :response
  end

  def with_server
    start_server
    wait_for_server
    yield
  ensure
    stop_server
  end

  def stream(path, headers = {})
    headers.reverse_merge!(default_headers)

    chunks = []

    client = Thread.new do
      Net::HTTP.start(SERVER_HOST, server_port) do |http|
        request = Net::HTTP::Get.new(path)

        headers.each do |name, value|
          request[name] = value
        end

        http.request(request) do |response|
          Thread.current[:response] = response

          response.read_body do |value|
            Thread.current[:connected] = true
            chunks << build_chunk(value, headers) if value.present?
          end
        end
      end
    end

    Timeout.timeout(10) { loop until client[:connected] }

    yield chunks

    client.kill

    @response = ActionDispatch::TestResponse.new(
      client[:response].code,
      client[:response].to_hash,
      chunks.join("\n")
    )
  end

  private

  def start_server
    server.run
  end

  def server
    @server ||= begin
      server = Puma::Server.new(Rails.application, server_events)
      server.add_tcp_listener(SERVER_HOST, server_port)
      server
    end
  end

  def server_events
    @server_events ||= begin
      events = Puma::Events.new(STDOUT, STDERR)
      events.register(:state) { |s| @server_state = s }
      events
    end
  end

  def server_port
    @server_port ||= begin
      server = TCPServer.new(SERVER_HOST, 0)
      server.addr[1]
    ensure
      server.close if server
    end
  end

  def wait_for_server
    Timeout.timeout(10) { loop until @server_state == :running }
  end

  def stop_server
    server.halt(true)
  end

  def build_chunk(value, headers)
    accept = Mime::Type.lookup(headers["Accept"])
    accept.json? || accept.xml? ? Content.new(value, accept) : value
  end
end

RSpec.configure do |config|
  config.include(StreamingHelpers, type: :request, streaming: true)

  config.around(type: :request, streaming: true) do |example|
    with_truncation { with_server { example.run } }
  end
end
