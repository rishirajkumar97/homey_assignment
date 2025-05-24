FactoryBot.define do
  factory :user do
    sequence(:user_name) { |n| "user#{n}" }
    sequence(:email) { |n| "user#{n}@example.com" }
    full_name { "Test User" }
    password { "password123" }
    password_confirmation { "password123" }
    role { "member" }

    trait :admin do
      role { "admin" }
      full_name { "Admin User" }
    end

    trait :manager do
      role { "manager" }
      full_name { "Manager User" }
    end

    trait :member do
      role { "member" }
      full_name { "Member User" }
    end
  end
end