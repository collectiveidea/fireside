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

  serialize :metadata, Hash

  validates :room_id, presence: true, strict: true

  def self.inherited(subclass)
    subclasses << subclass
    super
  end

  def self.subclasses
    @subclasses ||= []
  end

  after_create :notify_room

  def self.old_to_new
    order(:created_at)
  end

  def self.post(user, room, attributes)
    attributes.update(user_id: user.id, room_id: room.id, private: room.locked?)
    infer_subclass!(attributes).create(attributes)
  end

  def self.infer_subclass!(attributes)
    subclass = subclasses.detect { |s| s.matches?(attributes) } || TextMessage
    attributes.delete(:type)
    subclass
  end

  def self.matches?(attributes)
    false
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

class TextMessage < Message
  validates :user_id, presence: true, strict: true
  validates :body, presence: true

  def self.matches?(attributes)
    attributes[:type] == "TextMessage"
  end
end

class PasteMessage < Message
  validates :user_id, presence: true, strict: true
  validates :body, presence: true

  def self.matches?(attributes)
    (attributes[:type] == "PasteMessage") || (attributes[:body] =~ /\n/)
  end
end

class SoundMessage < Message
  SOUNDS = %w(
    56k bell bezos bueller clowntown cottoneyejoe crickets dadgummit dangerzone
    danielsan deeper drama greatjob greyjoy heygirl horn horror inconceivable
    live loggins makeitso noooo nyan ohmy ohyeah pushit rimshot rollout sax
    secret sexyback story tada tmyk trololo trombone vuvuzela what whoomp yeah
    yodel
  )

  validates :user_id, presence: true, strict: true

  def self.matches?(attributes)
    body = attributes[:body]
    match = body && body.match(/^\/play (\w+)$/)
    match && SOUNDS.include?(match[1])
  end
end

class TweetMessage < Message
  TWEET_PATTERN = %r(^https?://(www\.)?twitter\.com/\w+/status/\w+)

  validates :user_id, presence: true, strict: true

  def self.matches?(attributes)
    attributes[:body] =~ TWEET_PATTERN
  end
end

class AllowGuestsMessage < Message
end

class DisallowGuestsMessage < Message
end

class EnterMessage < Message
  validates :user_id, presence: true, strict: true

  def self.post(user, room)
    create!(user: user, room: room, private: room.locked?)
  end
end

class LeaveMessage < Message
  validates :user_id, presence: true, strict: true

  def self.post(user, room)
    create!(user: user, room: room, private: room.locked?)
  end
end

class LockMessage < Message
  validates :user_id, presence: true, strict: true

  def self.post(user, room)
    create!(user: user, room: room, private: room.locked?)
  end
end

class TimestampMessage < Message
end

class TopicChangeMessage < Message
end

class UnlockMessage < Message
  validates :user_id, presence: true, strict: true

  def self.post(user, room)
    create!(user: user, room: room, private: room.locked?)
  end
end

class UploadMessage < Message
  validates :user_id, presence: true, strict: true
end
