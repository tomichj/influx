require 'spec_helper'

module Influx
  describe EventSubscriptionUpdated do
    describe '#call' do
      it 'synchronizes stripe to subscription' do
        subscription = create(:subscription)
        expect_any_instance_of(Influx::Subscription).to receive(:sync_with!)
        event = StripeMock.mock_webhook_event('customer.subscription.updated', id: subscription.stripe_id)
        Influx::EventSubscriptionUpdated.call(event)
      end
    end
  end
end
