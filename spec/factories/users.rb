FactoryBot.define do
  sequence(:email) { |n| "user_#{n}@example.com" }

  factory :user do
    email { generate :email }
    password { 'password' }
    password_confirmation { 'password' }

    factory :user_with_tasks do
      transient { tasks_count { 5 } }
      after(:create) do |user, evaluator|
        create_list(:task, evaluator.tasks_count, user: user )
      end
    end
  end
end