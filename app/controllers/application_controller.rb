class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session

  rescue_from ActionController::ParameterMissing, ActionController::UnpermittedParameters do
    head :bad_request
  end

  before_action :authenticate_api_request, if: :api_request?
  before_action :authenticate_web_request, if: :web_request?

  attr_accessor :current_user

  private

  def authenticate_api_request
    authenticate_or_request_with_http_basic do |username, password|
      if user = User.find_by(api_auth_token: username)
        self.current_user = user
      elsif user = User.find_by(email: username)
        self.current_user = user.authenticate(password)
      end
    end
  end

  def api_request?
    (request.format.json? || request.format.xml?) && !request.xhr?
  end

  def authenticate_web_request
    id = cookies[:current_user_id]
    self.current_user = id && User.find(id)
    head :unauthorized unless current_user
  end

  def web_request?
    request.format.html? || request.xhr?
  end
end
