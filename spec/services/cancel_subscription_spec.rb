require 'spec_helper'

module Influx
  describe CancelSubscription do
    let(:token){ StripeMock.generate_card_token({}) }
    describe '#call' do
      before(:each) do
        @subscription = create(:subscription, stripe_token: token)
        ActivateStripePlan.call(plan: @subscription.plan)
        ActivateStripeSubscription.call(subscription: @subscription)
      end

      it 'cancels the subscription immediately' do
        CancelSubscription.call(subscription: @subscription)
        expect(@subscription.reload.state).to eq 'canceled'
      end
    end
  end
end
