module Influx
  class ActivateStripeSubscription
    include Influx::Service

    # Called by subscription.activate!
    # subscription.activate! sets state to active after this method completes
    def initialize(subscription:)
      @subscription = subscription
      @subscriber = @subscription.subscriber
      @token = @subscription.stripe_token
    end

    def call
      begin
        stripe_customer = create_or_load_stripe_customer
        stripe_subscription = create_stripe_subscription(stripe_customer)
        card = stripe_customer.sources.data.first
        update_influx_subscription(stripe_subscription, card)
        @subscription.save!
      rescue Stripe::StripeError => e
        @subscription.update_attributes(error: e.message)
        @subscription.errors[:base] << e.message
        @subscription.fail!
      end
      @subscription
    end

    private

    def create_stripe_subscription(stripe_customer)
      stripe_subscription_params = { plan: @subscription.plan.stripe_id }
      stripe_subscription_params[:trial_end] = @subscription.trial_end if @subscription.trial_end.present?
      stripe_customer.subscriptions.create(stripe_subscription_params)
    end

    def update_influx_subscription(stripe_subscription, card)
      unless card.nil?
        @subscription.assign_attributes(
          card_last4:          card.last4,
          card_expiration:     Date.new(card.exp_year, card.exp_month, 1),
          card_type:           card.respond_to?(:brand) ? card.brand : card.type,
        )
      end
      @subscription.stripe_customer_id = @subscriber.stripe_customer_id
      @subscription.stripe_id = stripe_subscription.id
      @subscription.sync_with!(stripe_subscription)
      @subscription.activate
    end

    def create_or_load_stripe_customer
      if @subscriber.stripe_customer_id.blank?
        create_stripe_customer
      else
        load_stripe_customer
      end
    end

    def create_stripe_customer
      stripe_customer = Stripe::Customer.create(source: @token, email: @subscriber.email)
      @subscriber.stripe_customer_id = stripe_customer.id
      @subscriber.save!
      stripe_customer
    end

    def load_stripe_customer
      Stripe::Customer.retrieve(@subscriber.stripe_customer_id)
    end
  end
end
