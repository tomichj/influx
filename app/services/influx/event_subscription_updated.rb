module Influx

  #
  # A customer's subscription was updated by Stripe.
  #
  # Event name: 'customer.subscription.updated'
  #
  class EventSubscriptionUpdated
    include Influx::Service

    def initialize(event)
      @event = event
    end

    def call
      stripe_subscription = @event.data.object
      subscription = Influx::Subscription.find_by!(stripe_id: stripe_subscription.id)
      subscription.sync_with!(stripe_subscription)
    end
  end
end
