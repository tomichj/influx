require 'spec_helper'

module Influx
  describe ActivateStripeSubscription do
    let(:token){ StripeMock.generate_card_token({}) }
    describe '#call' do
      it 'creates subscription' do
        subscription = create(:subscription, stripe_token: token)
        ActivateStripePlan.call(plan: subscription.plan)
        puts subscription.inspect

        ActivateStripeSubscription.call(subscription: subscription)
        puts subscription.inspect
      end

    end
  end
end
