module Influx

  #
  # Handles a notification from Stripe that the user has canceled their subscription.
  #
  # event name: 'customer.subscription.deleted'
  #
  class EventSubscriptionDeleted
    include Influx::Service

    def initialize(event)
      @event = event
    end

    def call
      stripe_subscription = @event.data.object
      subscription = Influx::Subscription.find_by!(stripe_id: stripe_subscription.id)
      subscription.cancel! if subscription.may_cancel?
    end
  end
end
