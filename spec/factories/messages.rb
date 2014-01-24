FactoryGirl.define do
  factory :message do
    room
    body "Hello, world!"

    trait :starred do
      starred true
    end
  end
end
