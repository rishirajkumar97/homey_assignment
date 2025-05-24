FactoryBot.define do
  factory :project do
    sequence(:name) { |n| "Project #{n}" }
    description { "Test project description" }
    content { "Detailed project content goes here" }
    status { "draft" }
    association :creator, factory: :user

    trait :active do
      status { "active" }
    end

    trait :on_boarding do
      status { "on_boarding" }
    end

    trait :closed do
      status { "closed" }
    end

    trait :with_activities do
      after(:create) do |project|
        create_list(:comment, 2, project: project)
        create_list(:audit_log, 1, project: project)
      end
    end
  end
end