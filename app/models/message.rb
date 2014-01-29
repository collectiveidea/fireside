class Message < ActiveRecord::Base
  belongs_to :user, inverse_of: :messages
  belongs_to :room, inverse_of: :messages

  validates :body, presence: true

  def self.old_to_new
    order(:created_at)
  end

  def self.create_for_room(room, attributes)
    create(attributes.merge(room_id: room.id, private: room.locked?))
  end

  def star
    update(starred: true)
  end

  def unstar
    update(starred: false)
  end
end
