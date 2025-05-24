FactoryBot.define do
  factory :activity_reference do
    association :activity
    association :reference, factory: :user
  end
end