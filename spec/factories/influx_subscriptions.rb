FactoryGirl.define do
  factory :subscription, :class => 'Influx::Subscription' do
    # plan_id 1
    # subscriber_id 1
    start '2017-08-07 08:34:39'
    cancel_at_period_end false
    current_period_start '2017-08-07 08:35:39'
    current_period_end '2017-08-07 08:35:39'
    ended_at '2017-08-07 08:35:39'
    trial_start Time.now
    trial_end Time.now + 7.days
    canceled_at '2017-08-07 08:35:39'
    email 'justin@tomich.org'
    stripe_token 'tok_test1234'
    stripe_id 'sub_1234'
  end
end
