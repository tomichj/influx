module Influx

  #
  # Activate a Stripe::Subscription for the given Influx Subscription.
  #
  # The Stripe::Customer (subscriber) is loaded or created as a side affect.
  #
  class ActivateStripeSubscription
    include Influx::Service

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
        @subscription.activate
        @subscription.started_at = Time.current
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
      stripe_subscription_params = {
        plan: @subscription.plan.stripe_id,
        quantity: 1
      }
      stripe_subscription_params[:trial_end] = @subscription.trial_end.to_i if @subscription.trial_end.present?
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
    end

    def create_or_load_stripe_customer
      stripe_customer = if @subscriber.stripe_customer_id.blank?
                          create_stripe_customer
                        else
                          load_stripe_customer
                        end
      stripe_customer_source(stripe_customer)
      stripe_customer
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

    def stripe_customer_source(stripe_customer)
      unless stripe_customer.try(:deleted)
        if stripe_customer.default_source.nil? && @token.present?
          stripe_customer.source = @subscription.stripe_token
          stripe_customer.save
        end
      end
    end
  end
end
