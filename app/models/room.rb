class Room < ActiveRecord::Base
  has_many :messages, inverse_of: :room, dependent: :nullify

  validates :name, presence: true, uniqueness: true
  validates :active_token_value, uniqueness: { allow_nil: true }, strict: true

  def self.old_to_new
    order(:created_at)
  end

  def membership_limit
    nil
  end

  def full
    false
  end

  alias_method :full?, :full

  def lock
    update(locked: true)
  end
end
