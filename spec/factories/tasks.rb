FactoryBot.define do
  sequence(:title, "title_1")

  factory :task do
    title { generate :title }
    status { :todo }
  end
end
