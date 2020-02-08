FactoryBot.define do
  factory :task do
    sequence(:title) { |n| "title_#{n}" }
    status { :todo }
    user
  end
end
