FactoryBot.define do
  factory :activity do
    type { "" }
    content { "MyText" }
    project { nil }
    user { nil }
    created_at { "2025-05-24 01:30:59" }
    created_by { nil }
  end
end
