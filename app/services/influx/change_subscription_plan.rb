module Influx

  #
  # Change the plan for a subscription.
  #
  class ChangeSubscriptionPlan
    include Influx::Service

    # @param [Influx::Subscription]
    # @param [Influx::Plan]
    def initialize(subscription:, new_plan:, coupon: nil)
      @subscription = subscription
      @new_plan     = new_plan
      @coupon       = coupon
    end

    def call
      # add instrumentation for the change of plan
      # old_plan = subscription.plan

      begin
        stripe_sub = fetch_stripe_subscription
        stripe_sub.plan = @new_plan.stripe_id
        stripe_sub.coupon = @coupon if @coupon.present?
        stripe_sub.save

        @subscription.cancel_at_period_end = false
        @subscription.plan = @new_plan
        @subscription.save!
      rescue RuntimeError, Stripe::StripeError => e
        @subscription.errors[:base] << e.message
      end

      @subscription
    end

    private

    # @return [Stripe::Subscription]
    def fetch_stripe_subscription
      stripe_customer_id = @subscription.subscriber.stripe_customer_id
      stripe_customer = Stripe::Customer.retrieve(stripe_customer_id)
      stripe_customer.subscriptions.retrieve(@subscription.stripe_id)
    end
  end
end
