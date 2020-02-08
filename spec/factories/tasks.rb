FactoryBot.define do
  sequence(:title) { |n| "title_#{n}" }

  factory :task do
    title { generate :title }
    status { :todo }
    user
  end
end
