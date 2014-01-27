module RequestHelpers
  extend ActiveSupport::Concern

  included do
    alias_method_chain :get,    :help
    alias_method_chain :post,   :help
    alias_method_chain :put,    :help
    alias_method_chain :delete, :help
  end

  def default_env
    @default_env ||= {
      "ACCEPT" => "application/json",
      "CONTENT_TYPE" => "application/json"
    }
  end

  def authenticate(username, password = nil)
    default_env["HTTP_AUTHORIZATION"] = ActionController::HttpAuthentication::Basic.encode_credentials(username, password)
  end

  def get_with_help(path, parameters = nil, env = {})
    get_without_help(path, parameters, default_env.merge(env))
  end

  def post_with_help(path, parameters = nil, env = {})
    post_without_help(path, parameters, default_env.merge(env))
  end

  def put_with_help(path, parameters = nil, env = {})
    put_without_help(path, parameters, default_env.merge(env))
  end

  def delete_with_help(path, parameters = nil, env = {})
    delete_without_help(path, parameters, default_env.merge(env))
  end
end

RSpec.configure do |config|
  config.include(RequestHelpers, type: :request)
end
