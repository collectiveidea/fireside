require "message"

FactoryGirl.define do
  factory :message do
    room

    trait :starred do
      starred true
    end

    trait :private do
      private true
    end

    factory :text_message,  class: TextMessage do
      user
      body "Hello, world!"
    end

    factory :paste_message, class: PasteMessage do
      user
      body "Hello…\nworld!"
    end

    factory :sound_message, class: SoundMessage do
      user
      body "/play tmyk"
    end

    factory :tweet_message, class: TweetMessage do
      user
      body "https://twitter.com/StayPuft/status/428306266306269184"
    end

    factory :allow_guests_message, class: AllowGuestsMessage

    factory :disallow_guests_message, class: DisallowGuestsMessage

    factory :enter_message, class: EnterMessage do
      user
    end

    factory :leave_message, class: LeaveMessage do
      user
    end

    factory :lock_message, class: LockMessage do
      user
    end

    factory :timestamp_message, class: TimestampMessage

    factory :topic_change_message, class: TopicChangeMessage

    factory :unlock_message, class: UnlockMessage do
      user
    end

    factory :upload_message, class: UploadMessage do
      user
    end
  end
end
