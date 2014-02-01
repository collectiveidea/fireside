class Message < ActiveRecord::Base
  class Payload < Struct.new(:attributes)
    def self.load(payload_string)
      new(JSON.load(payload_string))
    end

    def self.dump(message)
      new(message.attributes).dump
    end

    def dump
      JSON.dump(attributes)
    end

    private

    def method_missing(method, *)
      attributes.fetch(method.to_s) { super }
    end
  end

  belongs_to :user, inverse_of: :messages
  belongs_to :room, inverse_of: :messages

  validates :body, presence: true

  after_create :notify_room

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

  private

  def notify_room
    connection = self.class.connection
    connection.execute("NOTIFY #{channel}, #{connection.quote(payload_string)}")
  end

  def channel
    "room_#{room_id}"
  end

  def payload_string
    Payload.dump(self)
  end
end
