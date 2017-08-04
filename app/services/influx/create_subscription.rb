module Influx
  class CreateSubscription

    # Create a subscription.
    #
    # Consider splitting into creation of the Influx::Subscription and then
    # queuing up a Job to fire off the subscription request to Stripe.
    #
    # plan - Influx::Plan to sign up for
    # subscriber - the entity subscribing to the plan
    # token - token from stripe
    def self.call(plan, subscriber, token, options = {})
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
          stripe_customer = Stripe::Customer.retrieve(subscriber.stripe_customer_id)
        end

        stripe_sub_params = {
          plan: plan.stripe_id
        }
        stripe_sub_params[:trial_end] = options[:trial_end] if options[:trial_end].present?
        stripe_sub = stripe_customer.subscriptions.create(stripe_sub_params)


        subscription = Influx::Subscription.new do |s|
          s.subscriber = subscriber
          s.plan = plan
          s.email = subscriber.email
          s.stripe_token = token
          s.stripe_customer_id = subscriber.stripe_customer_id
          s.amount = plan.amount
        end

        card = stripe_customer.sources.data.first
        unless card.nil?
          subscription.assign_attributes(
            card_last4:          card.last4,
            card_expiration:     Date.new(card.exp_year, card.exp_month, 1),
            card_type:           card.respond_to?(:brand) ? card.brand : card.type,
          )
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
