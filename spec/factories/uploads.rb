FactoryGirl.define do
  factory :upload do
    user
    room
    message
    file { Rails.root.join("spec/support/campfire.gif").open }

    trait :private do
      private true
    end
  end
end
