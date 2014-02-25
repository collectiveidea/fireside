Capybara::Session.class_eval do
  def cookies
    @cookies ||= ActionDispatch::Cookies::CookieJar.new(key_generator)
  end

  private

  def key_generator
    @key_generator ||= ActiveSupport::LegacyKeyGenerator.new(SecureRandom.hex)
  end
end

RSpec.configure do |config|
  config.before(type: :feature) do
    ActionDispatch::Request.any_instance.stub(:cookie_jar) { page.cookies }
  end
end
