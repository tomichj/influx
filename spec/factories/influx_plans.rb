FactoryGirl.define do
  factory :plan, class: 'Influx::Plan' do
    stripe_id 'rspec-test-plan'
    name 'The Rspec Test Plan'
    amount 5000
    interval "month"
    interval_count 1
    trial_period_days 1
    published false
  end
end
