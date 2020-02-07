FactoryBot.define do
  sequence(:email) { |n| "user_#{n}@example.com" }

  factory :user do
    email { generate :email }
    password { 'password' }
    password_confirmation { 'password' }
  end
end