require 'spec_helper'

module Influx
  describe CancelSubscription do
    let(:token){ StripeMock.generate_card_token({}) }
    describe '#call' do
      it 'creates a customer' do
        subscription = create(:subscription, stripe_token: token)
        ActivateStripePlan.call(plan: subscription.plan)
        ActivateStripeSubscription.call(subscription: subscription)
        expect(subscription.reload.stripe_customer_id).to_not be_nil
      end

      it 'creates a customer with free plan without stripe_token' do
        plan = create(:plan, amount: 0)
        subscription = create(:subscription, plan: plan, stripe_token: nil)
        ActivateStripePlan.call(plan: subscription.plan)
        ActivateStripeSubscription.call(subscription: subscription)
        expect(subscription.reload.stripe_customer_id).to_not be_nil
      end

      it 'capstures credit card info' do
        subscription = create(:subscription, stripe_token: token)
        ActivateStripePlan.call(plan: subscription.plan)
        ActivateStripeSubscription.call(subscription: subscription)
        subscription.reload
        expect(subscription.stripe_id).to_not be_nil
        expect(subscription.card_last4).to_not be_nil
        expect(subscription.card_expiration).to_not be_nil
        expect(subscription.card_type).to_not be_nil
      end

      describe 'on stripe error' do
        it 'should update the error attribute' do
          StripeMock.prepare_card_error(:card_declined, :new_customer)
          subscription = create(:subscription, stripe_token: token)
          ActivateStripePlan.call(plan: subscription.plan)
          ActivateStripeSubscription.call(subscription: subscription)
          subscription.reload
          expect(subscription.error).to_not be_nil
          expect(subscription.errored?).to be true
        end
      end



    end
  end
end
