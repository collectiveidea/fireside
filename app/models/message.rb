# encoding: utf-8

class Message < ActiveRecord::Base
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

  def self.recent
    old_to_new.limit(25)
  end

  def self.today
    now = Time.current
    today = now.beginning_of_day..now.end_of_day
    old_to_new.where(created_at: today)
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

  def self.from_payload(payload)
    new(JSON.load(payload))
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
    connection.execute("NOTIFY #{channel}, #{connection.quote(payload)}")
  end

  def channel
    "room_#{room_id}"
  end

  def payload
    JSON.dump(attributes)
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
  SOUND_PATTERN = /^\/play (\w+)$/
  SOUND_TEMPLATE = "#{ENV["PROTOCOL"]}://#{ENV["HOST"]}/sounds/%s.mp3"
  IMAGE_TEMPLATE = "#{ENV["PROTOCOL"]}://#{ENV["HOST"]}/images/%s"

  DESCRIPTIONS = {
    "56k" => IMAGE_TEMPLATE % "56k.gif",
    "bell" => ":bell:",
    "bezos" => ":laughing::thought_balloon:",
    "bueller" => "anyone?",
    "clowntown" => IMAGE_TEMPLATE % "clowntown.gif",
    "cottoneyejoe" => ":notes::hear_no_evil::notes:",
    "crickets" => "hears crickets chirping",
    "dadgummit" => "dad gummit!! :fishing_pole_and_fish:",
    "dangerzone" => IMAGE_TEMPLATE % "dangerzone.png",
    "danielsan" => ":fireworks: :trophy: :fireworks:",
    "deeper" => IMAGE_TEMPLATE % "top.gif",
    "drama" => IMAGE_TEMPLATE % "drama.jpg",
    "greatjob" => IMAGE_TEMPLATE % "greatjob.png",
    "greyjoy" => ":confounded::trumpet:",
    "guarantee" => "guarantees it :ok_hand:",
    "heygirl" => ":sparkles::information_desk_person::sparkles:",
    "horn" => ":dog: :scissors: :cat:",
    "horror" => ":skull: :skull: :skull: :skull: :skull: :skull: :skull: :skull: :skull: :skull:",
    "inconceivable" => "doesn't think it means what you think it means...",
    "live" => "is DOING IT LIVE",
    "loggins" => IMAGE_TEMPLATE % "loggins.jpg",
    "makeitso" => "make it so :point_right:",
    "noooo" => ":princess::skull::unamused:",
    "nyan" => IMAGE_TEMPLATE % "nyan.gif",
    "ohmy" => "raises an eyebrow :smirk:",
    "ohyeah" => "isn't playing by the rules",
    "pushit" => IMAGE_TEMPLATE % "pushit.gif",
    "rimshot" => "plays a rimshot",
    "rollout" => ":shipit::car:",
    "sax" => ":city_sunset::saxophone::notes:",
    "secret" => "found a secret area :key:",
    "sexyback" => ":underage:",
    "story" => "and now you know...",
    "tada" => "plays a fanfare :flags:",
    "tmyk" => ":sparkles: :star: The More You Know :sparkles: :star:",
    "trololo" => "троллинг :trollface:",
    "trombone" => "plays a sad trombone",
    "vuvuzela" => "======<() ~ ♪ ~♫",
    "what" => IMAGE_TEMPLATE % "what.gif",
    "whoomp" => ":clap::bangbang::sunglasses:",
    "yeah" => IMAGE_TEMPLATE % "yeah.gif",
    "yodel" => ":mega::mount_fuji::hear_no_evil:",
  }

  SOUNDS = DESCRIPTIONS.keys

  validates :user_id, presence: true, strict: true

  before_create :set_metadata, if: :set_metadata?

  def self.matches?(attributes)
    body = attributes[:body]
    match = body && body.match(SOUND_PATTERN)
    match && SOUNDS.include?(match[1])
  end

  def description
    metadata["description"]
  end

  def url
    SOUND_TEMPLATE % body
  end

  private

  def set_metadata
    self.body = body.match(SOUND_PATTERN)[1]
    self.metadata = { "description" => DESCRIPTIONS[body] }
  end

  def set_metadata?
    metadata.blank?
  end
end

class TweetMessage < Message
  TWEET_PATTERN = %r(^https?://(www\.)?twitter\.com/\w+/status/\w+)

  validates :user_id, presence: true, strict: true

  before_create :set_metadata, if: :set_metadata?

  def self.matches?(attributes)
    attributes[:body] =~ TWEET_PATTERN
  end

  private

  def set_metadata
    self.metadata = {
      "author_avatar_url" => tweet_author_avatar_url.to_s,
      "author_username" => tweet_author_username,
      "id" => tweet_id,
      "message" => tweet_message
    }

    self.body = "#{tweet_message} -- @#{tweet_author_username}, #{tweet_url}"
  end

  def set_metadata?
    metadata.blank? && tweet
  end

  def tweet
    return @tweet if defined? @tweet
    @tweet = twitter ? twitter.status(body) : nil
  rescue Twitter::Error
    @tweet = nil
  end

  def twitter
    return @twitter if defined? @twitter
    @twitter = twitter_configured? ? Twitter::REST::Client.new(twitter_configuration) : nil
  end

  def twitter_configured?
    twitter_configuration.values.all?(&:present?)
  end

  def twitter_configuration
    {
      consumer_key: ENV["TWITTER_CONSUMER_KEY"],
      consumer_secret: ENV["TWITTER_CONSUMER_SECRET"]
    }
  end

  def tweet_author_avatar_url
    tweet.user.profile_image_url
  end

  def tweet_author_username
    tweet.user.screen_name
  end

  def tweet_id
    tweet.id
  end

  def tweet_message
    tweet.text
  end

  def tweet_url
    "http://twitter.com/#{tweet_author_username}/status/#{tweet_id}"
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

  def self.post(user, room, upload)
    create!(user: user, room: room, private: room.locked?, metadata: { "upload_id" => upload.id })
  end
end
