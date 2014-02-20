FactoryGirl.define do
  factory :user do
    name "John Doe"
    sequence(:email) { |n| "john#{n}@example.com" }
    password "secret"

    trait :admin do
      admin true
    end
  end
end
