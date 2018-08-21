require 'spec_helper'

module Influx
  module Events
    describe EventSubscriptionUpdated do
      describe '#call' do
        before(:each) do
          @subscription = create(:subscription)
          @event        = StripeMock.mock_webhook_event('customer.subscription.updated', id: @subscription.stripe_id)
        end

        it 'synch_with! stripe to subscription' do
          expect_any_instance_of(Influx::Subscription).to receive(:sync_with!)
          EventSubscriptionUpdated.call(@event)
        end
      end
    end
  end
end
