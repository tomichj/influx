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

      it 'deletes stripe subscription' do
        expect(Stripe::Customer.retrieve(@subscription.stripe_customer_id).subscriptions.data.count).to be 1
        CancelSubscription.call(subscription: @subscription)
        expect(Stripe::Customer.retrieve(@subscription.stripe_customer_id).subscriptions.data.count).to be 0
      end

      it 'does not change subscription state on error' do
        custom_error = StandardError.new('Please knock first.')
        StripeMock.prepare_error(custom_error, :get_customer)
        expect { CancelSubscription.call(subscription: @subscription) }.to raise_error('Please knock first.')
        expect(@subscription.reload.state).to eq 'active'
      end
    end
  end
end
