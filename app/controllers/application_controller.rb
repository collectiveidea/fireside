class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from ActionController::ParameterMissing, ActionController::UnpermittedParameters do
    head :bad_request
  end

  before_action :authenticate_by_token

  attr_accessor :current_user

  private

  def authenticate_by_token
    authenticate_or_request_with_http_basic do |username, password|
      self.current_user = User.find_by(api_auth_token: username)
    end
  end
end
