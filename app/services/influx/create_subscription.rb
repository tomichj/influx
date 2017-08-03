module Influx
  class CreateSubscription
    def self.call(plan, subscriber, token)
      subscription = Influx::Subscription.new(
        plan: plan,
        subscriber: subscriber
      )

      begin
        stripe_sub = nil
        if subscriber.stripe_customer_id.blank?
          # creates the customer AND it's subscription
          stripe_customer = Stripe::Customer.create(
            source: token,
            email: subscriber.email,
            plan: plan.stripe_id
          )
          subscriber.stripe_customer_id = stripe_customer.id
          subscriber.save!
          stripe_sub = stripe_customer.subscriptions.first
        else
          stripe_customer = Stripe::Customer.retrieve(user.stripe_customer_id)
          stripe_sub = stripe_customer.subscriptions.create(plan: plan.stripe_id)
        end

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
