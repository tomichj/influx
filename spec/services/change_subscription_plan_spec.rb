require 'spec_helper'

module Influx
  module Services
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
            stripe_customer     = Stripe::Customer.retrieve(@subscription.stripe_customer_id)
            stripe_subscription = stripe_customer.subscriptions.retrieve(@subscription.stripe_id)
            expect(stripe_subscription.plan.id).to eq @plan2.stripe_id
          end

          it 'changes the influx plan' do
            expect(@subscription.reload.plan).to eq @plan2
          end
        end

        describe 'trial_end' do
          before do
            @stripe_sub = Stripe::Subscription.new
            allow(@stripe_sub).to receive(:save).and_return(true) # trial_end value is wiped when save is called
            allow_any_instance_of(ChangeSubscriptionPlan).to receive(:retrieve_stripe_subscription).and_return(@stripe_sub)
          end

          context 'is not set' do
            before do
              ChangeSubscriptionPlan.call(subscription: @subscription, new_plan: @plan2)
            end

            it 'should not have trial_end set' do
              expect(@stripe_sub.try(:trial_end)).to be_nil
            end
          end

          context 'is set' do
            before do
              @trial_end = 'now'
              ChangeSubscriptionPlan.call(subscription: @subscription, new_plan: @plan2, trial_end: @trial_end)
            end

            it 'should have trial_end set' do
              expect(@stripe_sub.trial_end).to eq(@trial_end)
            end
          end
        end

        describe 'cancel at period end' do
          context 'is not set' do
            before do
              ChangeSubscriptionPlan.call(subscription: @subscription, new_plan: @plan2)
            end

            it 'should not change attribute' do
              expect(@subscription.cancel_at_period_end).to be false
            end
          end

          context 'is set' do
            before do
              @subscription = create(:subscription, plan: @plan1, stripe_token: @token, cancel_at_period_end: true)
              ActivateStripeSubscription.call(subscription: @subscription)
              ChangeSubscriptionPlan.call(subscription: @subscription, new_plan: @plan2)
            end

            it 'should be reset to false' do
              expect(@subscription.cancel_at_period_end).to be false
            end
          end
        end
      end
    end
  end
end
