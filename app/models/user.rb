class User < ActiveRecord::Base
  GRAVATAR_URL_TEMPLATE = "https://secure.gravatar.com/avatar/%s?d=mm&s=55"

  has_secure_password

  has_many :presences, inverse_of: :user, dependent: :destroy
  has_many :rooms, through: :presences

  validates :name, presence: true
  validates :email, presence: true, email: true, uniqueness: true

  before_create :set_api_auth_token

  def avatar_url
    GRAVATAR_URL_TEMPLATE % gravatar_hash
  end

  def join_room(room)
    presences.find_or_create_by!(room_id: room.id)
  end

  private

  def set_api_auth_token
    self.api_auth_token ||= SecureRandom.hex(20)
  end

  def gravatar_hash
    Digest::MD5.hexdigest(email.strip.downcase)
  end
end
