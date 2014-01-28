module RequestHelpers
  extend ActiveSupport::Concern

  included do
    alias_method_chain :get,    :help
    alias_method_chain :post,   :help
    alias_method_chain :put,    :help
    alias_method_chain :delete, :help

    attr_reader :format
  end

  module ClassMethods
    def using_json_and_xml(&block)
      %w(json xml).each do |format|
        context("using #{format.upcase}", format: format, &block)
      end
    end
  end

  def default_headers
    @default_headers ||= {}
  end

  def authenticate(username, password = nil)
    default_headers["Authorization"] = ActionController::HttpAuthentication::Basic.encode_credentials(username, password)
  end

  def with_format(format)
    set_format(format)
    yield
  ensure
    reset_format
  end

  def set_format(format)
    if @format = Mime::Type.lookup_by_extension(format)
      default_headers["Accept"]       = @format.to_s
      default_headers["Content-Type"] = @format.to_s
    end
  end

  def reset_format
    default_headers.delete("Accept")
    default_headers.delete("Content-Type")
  end

  def get_with_help(path, headers = {})
    get_without_help(path, nil, default_headers.merge(headers))
  end

  def post_with_help(path, value = nil, headers = {})
    post_without_help(path, build_body(value), default_headers.merge(headers))
  end

  def put_with_help(path, value = nil, headers = {})
    put_without_help(path, build_body(value), default_headers.merge(headers))
  end

  def delete_with_help(path, headers = {})
    delete_without_help(path, nil, default_headers.merge(headers))
  end

  private

  def build_body(value)
    format ? Content.new(value, format).to_s : value
  end
end

RSpec.configure do |config|
  config.include(RequestHelpers, type: :request)

  config.around(type: :request) do |example|
    with_format(example.metadata[:format]) { example.run }
  end
end
