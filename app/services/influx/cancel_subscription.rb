module Influx
  class CancelSubscription
    def call(subscription, options = {})
      stripe_subscription = Stripe::Subscription.retrieve(subscription.stripe_id)
      stripe_subscription.delete
      subscription.cancel!
    end
  end
end
