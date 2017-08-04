module Influx
  class CreateSubscription
    # plan - Influx::Plan to sign up for
    # subscriber - the entity subscribing to the plan
    # token - token from stripe
    def self.call(plan, subscriber, token)
      # subscription = Influx::Subscription.new(plan: plan, subscriber: subscriber)
      subscription = Influx::Subscription.new do |s|
        s.plan = plan
        s.email = subscriber.email
        s.g
      end

      begin
        if subscriber.stripe_customer_id.blank?
          stripe_customer = Stripe::Customer.create(
            source: token,
            email: subscriber.email,
            plan: plan.stripe_id
          )
          subscriber.stripe_customer_id = stripe_customer.id
          subscriber.save!
        else
          stripe_customer = Stripe::Customer.retrieve(user.stripe_customer_id)
        end

        stripe_sub = stripe_customer.subscriptions.create(plan: plan.stripe_id)

        subscription.stripe_id = stripe_sub.id
        subscription.sync_with!(stripe_sub)
        subscription.save!
      rescue Stripe::StripeError => e
        subscription.errors[:base] << e.message
      end

      subscription
    end
  end
end
