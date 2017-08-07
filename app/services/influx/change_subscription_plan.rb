module Influx
  class ChangeSubscriptionPlan
    def self.call(subscription, new_plan)

      # add instrumentation for the change of plan
      # old_plan = subscription.plan

      begin
        stripe_sub = fetch_stripe_subscription(subscription)
        stripe_sub.plan = new_plan.stripe_id
        # deal with prorating and coupons some day
        stripe_sub.save

        subscription.cancel_at_period_end = false
        subscription.plan = plan
        subscription.save!

      rescue RuntimeError, Stripe::StripeError => e
        subscription.errors[:base] << e.message
      end

      subscription
    end

    def self.fetch_stripe_subscription(subscription)
      customer = Stripe::Customer.retrieve(subscription.stripe_customer_id)
      customer.subscriptions.retrieve(subscription.stripe_id)
    end
  end
end