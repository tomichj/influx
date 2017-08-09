require 'spec_helper'

module Influx
  describe ChangeSubscriptionPlan do
    describe '#call' do
      before do
        @token = StripeMock.generate_card_token({})
        @plan1 = create(:plan)
        @plan2 = create(:plan)
        ActivateStripePlan.call(plan: @plan1)
        ActivateStripePlan.call(plan: @plan2)
        @subscription = create(:subscription, plan: @plan1, stripe_token: @token)
        ActivateStripeSubscription.call(subscription: @subscription)
      end

      context 'paid plan to paid plan' do
        before { ChangeSubscriptionPlan.call(subscription: @subscription, new_plan: @plan2) }

        it 'changes the stripe plan' do
          stripe_customer = Stripe::Customer.retrieve(@subscription.stripe_customer_id)
          stripe_subscription = stripe_customer.subscriptions.retrieve(@subscription.stripe_id)
          expect(stripe_subscription.plan.id).to eq @plan2.stripe_id
        end

        it 'changes the influx plan' do
          expect(@subscription.reload.plan).to eq @plan2
        end
      end


    end
  end
end
