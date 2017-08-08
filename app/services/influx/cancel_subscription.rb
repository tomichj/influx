module Influx
  class CancelSubscription
    include Influx::Service

    # Cancel the Stripe subscription and mark the Influx::Subscription cancelled.
    #
    # @param [Influx::Subscription]
    def initialize(subscription:)
      @subscription = subscription
    end

    def call
      stripe_subscription = Stripe::Subscription.retrieve(@subscription.stripe_id)
      stripe_subscription.delete if stripe_subscription
      @subscription.cancel!
    end
  end
end
