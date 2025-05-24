FactoryBot.define do
  factory :activity do
    content { "Test activity content" }
    association :project
    association :creator, factory: :user
    type { "Activity" }

    factory :comment do
      type { "Activity::Comment" }
      content { "This is a test comment with @user1 mention" }

      trait :with_mentions do
        after(:create) do |comment|
          user = create(:user, user_name: 'user1')
          create(:activity_reference, activity: comment, reference: user)
        end
      end
    end

    factory :audit_log do
      type { "Activity::AuditLog" }
      content { "Status changed from draft to active" }
    end
  end
end