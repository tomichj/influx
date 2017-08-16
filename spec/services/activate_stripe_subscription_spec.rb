require 'spec_helper'

module Influx
  describe ActivateStripeSubscription do
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

      it 'captures credit card info' do
        subscription = create(:subscription, stripe_token: token)
        ActivateStripePlan.call(plan: subscription.plan)
        ActivateStripeSubscription.call(subscription: subscription)
        subscription.reload
        expect(subscription.stripe_id).to_not be_nil
        expect(subscription.card_last4).to_not be_nil
        expect(subscription.card_expiration).to_not be_nil
        expect(subscription.card_type).to_not be_nil
      end

      it 're-uses an explicitly specified customer' do
        stripe_customer = Stripe::Customer.create
        subscriber = create(:subscriber, stripe_customer_id: stripe_customer.id)
        subscription = create(:subscription, stripe_token: nil, subscriber: subscriber)
        ActivateStripePlan.call(plan: subscription.plan)
        ActivateStripeSubscription.call(subscription: subscription)
        expect(Stripe::Customer).to_not receive(:create)
      end

      it 'sets default source for new customers' do
        subscription = create(:subscription, stripe_token: token)
        ActivateStripePlan.call(plan: subscription.plan)
        ActivateStripeSubscription.call(subscription: subscription)
        expect(Stripe::Customer.retrieve(subscription.stripe_customer_id).default_source).to_not be_nil
      end

      it 'does not override existing customer default source' do
        # reuse the subscriber and plan
        subscriber = create(:subscriber)
        plan = create(:plan)
        ActivateStripePlan.call(plan: plan)

        # first subscription will set default_source for customer
        subscription1 = create(:subscription, stripe_token: token, subscriber: subscriber, plan: plan)
        ActivateStripeSubscription.call(subscription: subscription1)
        source1 = Stripe::Customer.retrieve(subscriber.stripe_customer_id).default_source

        # second subscription will leave customer's default_source alone, as it's already set
        token2 = StripeMock.generate_card_token({})
        subscription2 = create(:subscription, stripe_token: token2, subscriber: subscriber, plan: plan)
        ActivateStripeSubscription.call(subscription: subscription2)
        source2 = Stripe::Customer.retrieve(subscriber.stripe_customer_id).default_source

        expect(source2).to be source1
      end

      describe 'on stripe error' do
        it 'updates the error attribute' do
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
