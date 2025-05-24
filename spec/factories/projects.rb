FactoryBot.define do
  factory :project do
    name { "MyString" }
    description { "MyText" }
    content { "MyText" }
    status { 1 }
  end
end
