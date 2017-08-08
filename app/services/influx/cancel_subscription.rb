module Influx
  class CancelSubscription
    include Influx::Service

    def initialize(subscription:)
      @subscription = subscription
    end

    def call
      stripe_subscription = Stripe::Subscription.retrieve(@subscription.stripe_id)
      stripe_subscription.delete
      @subscription.cancel!
    end
  end
end
