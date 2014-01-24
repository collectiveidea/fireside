class Room < ActiveRecord::Base
  MEMBERSHIP_LIMIT = 1_000_000

  has_many :messages, inverse_of: :room, dependent: :nullify

  validates :name, presence: true, uniqueness: true
  validates :active_token_value, uniqueness: { allow_nil: true }, strict: true

  def self.old_to_new
    order(:created_at)
  end

  def membership_limit
    MEMBERSHIP_LIMIT
  end
end
