class Message < ActiveRecord::Base
  belongs_to :user, inverse_of: :messages
  belongs_to :room, inverse_of: :messages

  validates :body, presence: true

  def self.old_to_new
    order(:created_at)
  end

  def self.post(user, room, attributes)
    attributes.update(user_id: user.id, room_id: room.id, private: room.locked?)
    infer_type!(attributes)
    create(attributes)
  end

  def self.infer_type!(attributes)
    old_type = attributes.delete(:type)

    new_type = if %w(TextMessage PasteMessage).include?(old_type)
             old_type
           elsif attributes[:body] =~ /\n/
             "PasteMessage"
           else
             "TextMessage"
           end

    attributes[:type] = new_type
  end

  def star
    update(starred: true)
  end

  def unstar
    update(starred: false)
  end
end
