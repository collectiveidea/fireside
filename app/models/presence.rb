class Presence < ActiveRecord::Base
  belongs_to :user, inverse_of: :presences
  belongs_to :room, inverse_of: :presences

  validates :user_id, :room_id, presence: true, strict: true
  validates :room_id, uniqueness: { scope: :user_id }
end
