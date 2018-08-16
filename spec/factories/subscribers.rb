FactoryBot.define do
  sequence :email do |n|
    "user#{n}@example.com"
  end

  sequence :name do |n|
    "Bob Testy#{n}"
  end

  factory :subscriber, class: 'User' do
    email
    name
  end
end
