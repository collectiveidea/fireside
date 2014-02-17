FactoryGirl.define do
  factory :room do
    sequence(:name) { |n| "Room ##{n}" }

    trait :with_guest_access do
      open_to_guests true
      active_token_value { SecureRandom.hex(3).first(5) }
    end

    trait :locked do
      locked true
    end

    trait :unlocked do
      locked false
    end
  end
end
