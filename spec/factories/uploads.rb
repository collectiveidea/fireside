FactoryGirl.define do
  factory :upload do
    room
    file { Rails.root.join("spec/support/campfire.gif").open }
  end
end
