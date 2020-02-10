FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user_#{n}@example.com" }
    password { 'password' }
    password_confirmation { 'password' }

    factory :user_with_tasks do
      transient { tasks_count { 5 } }
      after(:create) do |user, evaluator|
        create_list(:task, evaluator.tasks_count, user: user)
      end
    end
  end
end
