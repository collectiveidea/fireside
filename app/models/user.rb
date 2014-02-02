class User < ActiveRecord::Base
  GRAVATAR_URL_TEMPLATE = "https://secure.gravatar.com/avatar/%s?d=mm&s=55"

  has_secure_password

  has_many :messages, inverse_of: :user, dependent: :nullify
  has_many :presences, inverse_of: :user, dependent: :destroy
  has_many :rooms, through: :presences
  has_many :uploads, inverse_of: :user, dependent: :nullify

  validates :name, presence: true
  validates :email, presence: true, email: true, uniqueness: true

  before_create :set_api_auth_token

  alias_attribute :email_address, :email

  def avatar_url
    GRAVATAR_URL_TEMPLATE % gravatar_hash
  end

  def in_room?(room)
    presences.where(room_id: room.id).exists?
  end

  def join_room(room)
    presences.find_or_create_by!(room_id: room.id)
  end

  def leave_room(room)
    presences.where(room_id: room.id).destroy_all
  end

  private

  def set_api_auth_token
    self.api_auth_token ||= SecureRandom.hex(20)
  end

  def gravatar_hash
    Digest::MD5.hexdigest(email.strip.downcase)
  end
end
