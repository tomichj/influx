FactoryGirl.define do
  factory :subscription, :class => 'Influx::Subscription' do
    association :plan
    association :subscriber

    cancel_at_period_end false
    # started_at            30.days.ago
    # current_period_start 0.minutes.ago
    # current_period_end   30.days.from_now
    # ended_at             nil
    # trial_start          30.days.ago
    # trial_end            23.days.ago
    # canceled_at          nil
    email 'justin@tomich.org'
    # stripe_token 'tok_test1234'
    # stripe_id 'sub_1234'
  end
end
