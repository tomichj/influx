require 'spec_helper'

module Influx
  describe Subscription do
    describe '#sync_with!' do
      it 'should sync fields from stripe subscription' do
        plan = create(:plan)
        Influx::Services::ActivateStripePlan.call(plan: plan)
        subscription = create(:subscription, plan: plan)
        stripe_subscription = Stripe::Customer.create.subscriptions.create(
          plan: plan.stripe_id,
          source: StripeMock.generate_card_token(last4: '1234', exp_year: Time.now.year + 1)
        )

        # load up a cancelled timestamp, so we can test it in sync
        now = Time.now.to_i
        expect(stripe_subscription).to receive(:canceled_at).and_return(now).at_least(1)

        subscription.sync_with!(stripe_subscription)
        subscription.reload

        expect(subscription.current_period_start).to eq Time.at(stripe_subscription.current_period_start)
        expect(subscription.current_period_end).to eq Time.at(stripe_subscription.current_period_end)
        expect(subscription.canceled_at).to eq Time.at(now)
        expect(subscription.amount).to eq 5000
        expect(subscription.stripe_status).to eq 'active'
      end
    end

    describe 'trialing' do
      context 'with trial not end' do
        before(:each) do
          @subscription = build(:subscription, stripe_status: 'trialing', trial_end: Time.now + 5.days)
        end
        it 'is trialing' do
          expect(@subscription.trial?).to be_truthy
        end
        it 'is not expired' do
          expect(@subscription.trial_expired?).to be_falsey
        end
        it 'is active' do
          expect(@subscription.trial_active?).to be_truthy
        end
      end
      context 'trial end reached' do
        before(:each) do
          @subscription = build(:subscription, stripe_status: 'trialing', trial_end: Time.now - 5.days)
        end
        it 'is trialing' do
          expect(@subscription.trial?).to be_truthy
        end
        it 'is expired' do
          expect(@subscription.trial_expired?).to be_truthy
        end
        it 'is not active' do
          expect(@subscription.trial_active?).to be_falsey
        end
      end
    end

    describe 'events' do
      it 'fires active event on activate' do
        subscription = build(:subscription, state: 'pending')
        expect(Influx.configuration).to receive(:instrument).with('influx.subscription.active', subscription)
        subscription.activate!
      end
      it 'fires cancel event on canceled' do
        subscription = build(:subscription, state: 'active')
        expect(Influx.configuration).to receive(:instrument).with('influx.subscription.cancel', subscription)
        subscription.cancel!
      end
      it 'fires cancel event on canceled' do
        subscription = build(:subscription, state: 'pending')
        expect(Influx.configuration).to receive(:instrument).with('influx.subscription.fail', subscription)
        subscription.fail!
      end
    end
  end
end
