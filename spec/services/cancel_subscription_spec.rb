require 'spec_helper'

module Influx
  describe CancelSubscription do
    describe '#call' do
      before(:each) do
        token = StripeMock.generate_card_token({})
        @subscription = create(:subscription, stripe_token: token)
        ActivateStripePlan.call(plan: @subscription.plan)
        ActivateStripeSubscription.call(subscription: @subscription)
      end

      it 'changes influx subscription state to canceled' do
        CancelSubscription.call(subscription: @subscription)
        expect(@subscription.reload.state).to eq 'canceled'
      end

      it 'invokes delete on stripe subscription' do
        stripe_subscription = Stripe::Subscription.retrieve(@subscription.stripe_id)
        expect(stripe_subscription).to receive(:delete)
        expect(Stripe::Subscription).to receive(:retrieve).and_return(stripe_subscription)
        CancelSubscription.call(subscription: @subscription)
      end
    end
  end
end
