FactoryGirl.define do
  factory :upload do
    user
    room
    file { Rails.root.join("spec/support/campfire.gif").open }
  end
end
