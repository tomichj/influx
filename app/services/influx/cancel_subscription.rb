module Influx

  #
  # Cancel the Stripe subscription and mark the Influx::Subscription cancelled.
  #
  class CancelSubscription
    include Influx::Service

    # @param [Influx::Subscription]
    def initialize(subscription:)
      @subscription = subscription
    end

    def call
      stripe_customer = Stripe::Customer.retrieve(@subscription.stripe_customer_id)
      stripe_subscription = stripe_customer.subscriptions.retrieve(@subscription.stripe_id)
      stripe_subscription.delete if stripe_subscription
      @subscription.cancel!
    end
  end
end
