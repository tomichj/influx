module Influx
  class CreateSubscription
    def self.call(plan, subscriber, token)
      subscription = Subscription.new(
        plan: plan,
        subscriber: subscriber
      )

      begin
        stripe_sub = nil
        if subscriber.stripe_customer_id.blank?
          customer = Stripe::Customer.create(
            source: token,
            email: subscriber.email,
            plan: plan.stripe_id
          )
          subscriber.stripe_customer_id = customer.id
          subscriber.save!
          stripe_sub = customer.subscriptions.first
        else
          customer = Stripe::Customer.retrieve(user.stripe_customer_id)
          stripe_sub = customer.subscriptions.create(
            plan: plan.stripe_id
          )
        end

        subscription.stripe_id = stripe_sub.id
        subscription.save!
      rescue Stripe::StripeError => e
        subscription.errors[:base] << e.message
      end

      subscription
    end
  end
end