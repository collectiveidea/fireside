class Room < ActiveRecord::Base
  has_many :messages, inverse_of: :room, dependent: :nullify
  has_many :presences, inverse_of: :room, dependent: :destroy
  has_many :users, through: :presences

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

  def unlock
    update(locked: false)
  end

  def unlocked?
    !locked?
  end
end
