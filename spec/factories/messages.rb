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
  end
end
