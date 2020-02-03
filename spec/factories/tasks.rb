FactoryBot.define do
  factory :task do
    title { 'タイトル' }
    status { :todo }
  end
end
