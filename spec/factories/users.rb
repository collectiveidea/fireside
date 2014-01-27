FactoryGirl.define do
  factory :user do
    name "John Doe"
    sequence(:email) { |n| "john.doe.#{n}@gmail.com" }
    password "secret"
    password_confirmation { password }

    trait :admin do
      admin true
    end
  end
end
