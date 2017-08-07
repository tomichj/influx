module Influx
  class StartSubscription

    # Called by subscription.activate!
    # subscription.activate! sets state to active after this method completes
    def self.call(subscription)
      plan = subscription.plan
      subscriber = subscription.subscriber

      begin
        stripe_customer = create_or_load_stripe_customer(subscriber, subscription.stripe_token)

        stripe_subscription_params = { plan: plan.stripe_id }
        stripe_subscription_params[:trial_end] = subscription.trial_end if subscription.trial_end.present?
        stripe_subscription = stripe_customer.subscriptions.create(stripe_subscription_params)

        card = stripe_customer.sources.data.first
        record_card(subscription, card)

        subscription.stripe_customer_id = subscriber.stripe_customer_id
        subscription.stripe_id = stripe_subscription.id
        subscription.sync_with!(stripe_subscription)
        subscription.save!

      rescue Stripe::StripeError => e
        subscription.update_attributes(error: e.message)
        subscription.errors[:base] << e.message
        subscription.fail!
      end

      subscription
    end

    private

    def self.record_card(subscription, card)
      unless card.nil?
        subscription.assign_attributes(
          card_last4:          card.last4,
          card_expiration:     Date.new(card.exp_year, card.exp_month, 1),
          card_type:           card.respond_to?(:brand) ? card.brand : card.type,
        )
      end
    end

    def self.create_or_load_stripe_customer(subscriber, token)
      if subscriber.stripe_customer_id.blank?
        stripe_customer = Stripe::Customer.create(
          source: token,
          email: subscriber.email
        )
        subscriber.stripe_customer_id = stripe_customer.id
        subscriber.save!
      else
        stripe_customer = Stripe::Customer.retrieve(subscriber.stripe_customer_id)
      end
      stripe_customer
    end

  end
end
