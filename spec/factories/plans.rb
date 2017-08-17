FactoryGirl.define do
  factory :plan, class: 'Influx::Plan' do
    sequence(:name)      { |n| 'The Rspec Test Plan' }
    sequence(:stripe_id) { |n| "rspec-test-plan#{n}" }
    amount 5000
    interval 'month'
    interval_count 1
    # trial_period_days 1
    published false
  end
end
