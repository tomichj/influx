module Influx
  module Services
    #
    # Activate a Stripe::Subscription for the given Influx Subscription.
    #
    # The Stripe::Customer (subscriber) is loaded or created as a side affect.
    #
    class ActivateStripeSubscription
      include Influx::Services::Service

      # @param subscription [Influx::Subscription]
      def initialize(subscription:)
        @subscription = subscription
        @subscriber   = @subscription.subscriber
        @token        = @subscription.stripe_token
      end

      def call
        begin
          stripe_customer = create_or_retrieve_stripe_customer
          set_stripe_customer_source(stripe_customer)
          stripe_subscription = create_stripe_subscription(stripe_customer)
          payment_method      = stripe_customer.sources.data.first
          record_payment_method(payment_method)
          @subscription.stripe_customer_id = @subscriber.stripe_customer_id
          @subscription.stripe_id          = stripe_subscription.id
          @subscription.sync_with!(stripe_subscription)
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

      def create_or_retrieve_stripe_customer
        if @subscriber.stripe_customer_id.blank?
          create_stripe_customer
        else
          retrieve_stripe_customer
        end
      end

      def create_stripe_customer
        stripe_customer                = Stripe::Customer.create(source: @token, email: @subscriber.email)
        @subscriber.stripe_customer_id = stripe_customer.id
        @subscriber.save!
        stripe_customer
      end

      def retrieve_stripe_customer
        Stripe::Customer.retrieve(@subscriber.stripe_customer_id)
      end

      def set_stripe_customer_source(stripe_customer)
        return if stripe_customer.try(:deleted)
        return unless stripe_customer.default_source.nil? && @token.present?
        stripe_customer.source = @token
        stripe_customer.save
      end

      def create_stripe_subscription(stripe_customer)
        stripe_subscription_params             = {
          plan:     @subscription.plan.stripe_id,
          quantity: 1
        }
        stripe_subscription_params[:trial_end] = @subscription.trial_end.to_i if @subscription.trial_end.present?
        stripe_customer.subscriptions.create(stripe_subscription_params)
      end

      def record_payment_method(payment_method)
        if payment_method.is_a? Stripe::Card
          @subscription.assign_attributes(
            card_last4:      payment_method.last4,
            card_expiration: Date.new(payment_method.exp_year, payment_method.exp_month, 1),
            card_type:       payment_method.respond_to?(:brand) ? payment_method.brand : payment_method.type,
          )
        elsif payment_method.is_a? Stripe::BankAccount
          @subscription.assign_attributes(
            card_last4:      payment_method.last4,
            card_expiration: Date.today + 365,
            card_type:       payment_method.bank_name
          )
        end
      end
    end
  end
end
