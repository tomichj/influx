module Influx
  module Services
    #
    # Extend a trial.
    #
    class ChangeSubscriptionTrial
      include Influx::Services::Service

      # @param subscription [Influx::Subscription]
      # @param trial_end [Integer] of unix time to end trial at.
      def initialize(subscription:, trial_end:)
        @subscription = subscription
        @trial_end = trial_end
      end

      def call
        begin
          stripe_sub = update_stripe_subscription
          @subscription.sync_with! stripe_sub
        rescue Stripe::StripeError => e
          @subscription.errors[:base] << e.message
        end
        @subscription
      end

      private

      def update_stripe_subscription
        stripe_customer            = Stripe::Customer.retrieve(@subscription.subscriber.stripe_customer_id)
        stripe_subscription        = stripe_customer.subscriptions.retrieve(@subscription.stripe_id)
        stripe_subscription.trial_end = @trial_end
        stripe_subscription.save
      end
    end
  end
end
