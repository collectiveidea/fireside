class User < ActiveRecord::Base
  GRAVATAR_URL_TEMPLATE = "https://secure.gravatar.com/avatar/%s?d=mm&s=55"

  has_secure_password

  validates :name, presence: true
  validates :email, presence: true, email: true, uniqueness: true

  before_create :set_api_auth_token

  def avatar_url
    GRAVATAR_URL_TEMPLATE % gravatar_hash
  end

  private

  def set_api_auth_token
    self.api_auth_token ||= SecureRandom.hex(20)
  end

  def gravatar_hash
    Digest::MD5.hexdigest(email.strip.downcase)
  end
end
