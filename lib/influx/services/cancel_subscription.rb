module Influx
  module Services
    #
    # Cancel the Stripe subscription and mark the Influx::Subscription cancelled.
    #
    class CancelSubscription
      include Influx::Services::Service

      # @param subscription [Influx::Subscription]
      # @param options [Hash] includes :at_period_end
      def initialize(subscription:, options: {})
        @subscription = subscription
        @options      = options
      end

      def call
        stripe_customer     = Stripe::Customer.retrieve(@subscription.stripe_customer_id)
        stripe_subscription = stripe_customer.subscriptions.retrieve(@subscription.stripe_id)
        stripe_subscription.delete(@options) if stripe_subscription

        if @options[:at_period_end] == true
          @subscription.update_attributes(cancel_at_period_end: true)
        else
          # Cancel immediately
          @subscription.cancel!
        end
      end
    end
  end
end
