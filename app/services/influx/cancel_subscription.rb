module Influx
  class CancelSubscription
    def call(subscription, options = {})
      stripe_subscription = Stripe::Subscription.retrieve(subscription.stripe_id)
      subscription.delete
    end
  end
end
