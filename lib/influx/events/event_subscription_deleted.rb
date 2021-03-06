module Influx
  module Events
    #
    # Handles a notification from Stripe that the user has canceled their subscription.
    #
    # Event name: 'customer.subscription.deleted'
    #
    class EventSubscriptionDeleted
      include Influx::Services::Service
      include Influx::Events::Invoicing

      def initialize(event)
        @event = event
      end

      def call
        stripe_subscription = @event.data.object
        subscription        = Influx::Subscription.find_by!(stripe_id: stripe_subscription.id)
        subscription.cancel! if subscription.may_cancel?
      end
    end
  end
end
