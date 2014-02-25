module AuthenticationHelpers
  module RequestHelpers
    def authenticate(username, password = nil)
      default_headers["Authorization"] = ActionController::HttpAuthentication::Basic.encode_credentials(username, password).to_s
    end
  end

  module FeatureHelpers
    def authenticate(user)
      page.cookies[:current_user_id] = user.id
    end
  end
end

RSpec.configure do |config|
  config.include(AuthenticationHelpers::RequestHelpers, type: :request)
  config.include(AuthenticationHelpers::FeatureHelpers, type: :feature)
end
