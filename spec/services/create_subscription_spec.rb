require 'spec_helper'

module Influx
  module Services
    describe CreateSubscription do
      describe '#call' do
        before(:each) do
          @plan       = create(:plan)
          @subscriber = create(:subscriber)
          @token      = StripeMock.generate_card_token({})
        end

        it 'creates a subscription' do
          subscription = CreateSubscription.call(plan: @plan, subscriber: @subscriber, token: @token)

          expect(subscription.plan).to eq @plan
          expect(subscription.subscriber).to eq @subscriber
          expect(subscription.stripe_token).to eq @token
        end

        it 'calls the activate subscription service' do
          expect_any_instance_of(Influx::Subscription).to receive(:activate_stripe_subscription)
          CreateSubscription.call(plan: @plan, subscriber: @subscriber, token: @token)
        end
      end
    end
  end
end
