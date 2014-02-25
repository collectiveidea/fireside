module RequestHelpers
  extend ActiveSupport::Concern

  included do
    alias_method_chain :get,    :help
    alias_method_chain :post,   :help
    alias_method_chain :put,    :help
    alias_method_chain :delete, :help
  end

  module ClassMethods
    def with_formats(*formats, &block)
      formats.each do |format|
        with_format(format, &block)
      end
    end

    def with_format(format, &block)
      context("using #{format.upcase}", format: format, &block)
    end
  end

  def default_headers
    @default_headers ||= {}
  end

  def with_format(format)
    set_format(format)
    yield
  ensure
    reset_format
  end

  def set_format(format)
    if format = Mime::Type.lookup_by_extension(format)
      default_headers["Accept"]       = format.to_s
      default_headers["Content-Type"] = format.to_s
    end
  end

  def reset_format
    default_headers.delete("Accept")
    default_headers.delete("Content-Type")
  end

  def get_with_help(path, headers = {})
    headers.reverse_merge!(default_headers)
    get_without_help(path, nil, headers)
  end

  def post_with_help(path, value = nil, headers = {})
    headers.reverse_merge!(default_headers)
    body = build_body(value, headers)
    post_without_help(path, body, headers)
  end

  def put_with_help(path, value = nil, headers = {})
    headers.reverse_merge!(default_headers)
    body = build_body(value, headers)
    put_without_help(path, body, headers)
  end

  def delete_with_help(path, headers = {})
    headers.reverse_merge!(default_headers)
    delete_without_help(path, nil, headers)
  end

  private

  def build_body(value, headers)
    content_type = Mime::Type.lookup(headers["Content-Type"])

    if content_type.json? || content_type.xml?
      Content.new(value, content_type).to_s
    else
      value
    end
  end
end

RSpec.configure do |config|
  config.include(RequestHelpers, type: :request)

  config.around(type: :request) do |example|
    with_format(example.metadata[:format]) { example.run }
  end
end
