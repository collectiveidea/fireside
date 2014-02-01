FactoryGirl.define do
  factory :message do
    user
    room
    body "Hello, world!"

    trait :starred do
      starred true
    end

    trait :private do
      private true
    end

    factory :text_message, class: TextMessage

    factory :paste_message, class: PasteMessage
  end
end
