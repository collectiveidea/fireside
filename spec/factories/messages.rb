FactoryGirl.define do
  factory :message do
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
