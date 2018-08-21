module Influx

  #
  # Cancel the Stripe subscription and mark the Influx::Subscription cancelled.
  #
  class CancelSubscription
    include Influx::Service

    # @param [Influx::Subscription]
    def initialize(subscription:, options: {})
      @subscription = subscription
      @options = options
    end

    def call
      stripe_customer = Stripe::Customer.retrieve(@subscription.stripe_customer_id)
      stripe_subscription = stripe_customer.subscriptions.retrieve(@subscription.stripe_id)
      stripe_subscription.delete(@options) if stripe_subscription
      #@subscription.ended_at = Time.current
      #@subscription.cancel!

      if @options[:at_period_end] == true
        # Store that the subscription will be canceled at the end of the billing period
        @subscription.update_attributes(cancel_at_period_end: true)
      else
        # Cancel the subscription immediately
        @subscription.cancel!
      end
    end
  end
end
