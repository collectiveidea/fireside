class User < ActiveRecord::Base
  has_secure_password

  validates :name, presence: true
  validates :email, presence: true, email: true, uniqueness: true

  before_create :set_api_auth_token

  private

  def set_api_auth_token
    self.api_auth_token ||= SecureRandom.hex(20)
  end
end
