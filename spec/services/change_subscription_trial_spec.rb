require 'spec_helper'

module Influx
  module Services
    describe ChangeSubscriptionTrial do
      describe '#call' do
        before do
          @sub = create(:subscription, stripe_token: StripeMock.generate_card_token({}))
          ActivateStripePlan.call(plan: @sub.plan)
          ActivateStripeSubscription.call(subscription: @sub)
        end

        it 'can change trial period' do
          expect(@sub.trial_end).to be_nil
          ChangeSubscriptionTrial.call(subscription: @sub, trial_end: 5.days.from_now.to_i)
          expect(@sub.trial_end).to be_within(1.hour).of(5.days.from_now)
        end
      end
    end
  end
end
