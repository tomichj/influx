require 'spec_helper'

module Influx
  module Events
    describe EventSubscriptionDeleted do
      describe '#call' do
        it 'cancels the subscription stripe reports as deleted' do
          subscription = create(:subscription, state: 'active')
          event        = StripeMock.mock_webhook_event('customer.subscription.deleted', id: subscription.stripe_id)
          expect { EventSubscriptionDeleted.call(event) }.
            to change { subscription.reload.state }.from('active').to('canceled')
        end
      end
    end
  end
end
