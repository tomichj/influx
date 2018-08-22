module Influx
  module Services
    #
    # Change the plan for a subscription.
    #
    class ChangeSubscriptionPlan
      include Influx::Services::Service

      # @param subscription [Influx::Subscription]
      # @param new_plan [Influx::Plan]
      # @param trial_end [Integer] of unix time to end trial at.
      def initialize(subscription:, new_plan:, trial_end: nil)
        @subscription = subscription
        @new_plan     = new_plan
        @trial_end    = trial_end
      end

      def call
        begin
          stripe_sub           = retrieve_stripe_subscription
          stripe_sub.plan      = @new_plan.stripe_id
          stripe_sub.trial_end = @trial_end if @trial_end.present?
          # deal with prorating and coupons some day
          stripe_sub.save

          @subscription.cancel_at_period_end = false
          @subscription.plan                 = @new_plan
          @subscription.save!
        rescue RuntimeError, Stripe::StripeError => e
          @subscription.errors[:base] << e.message
        end

        @subscription.instrument_plan_changed
        @subscription
      end


      def retrieve_stripe_subscription
        stripe_customer_id = @subscription.subscriber.stripe_customer_id
        stripe_customer    = Stripe::Customer.retrieve(stripe_customer_id)
        stripe_customer.subscriptions.retrieve(@subscription.stripe_id)
      end
    end
  end
end
