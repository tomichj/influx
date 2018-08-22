module Influx
  module Services
    class ChangeSubscriptionCard
      include Influx::Services::Service

      # @param subscription [Influx::Subscription]
      # @param new_token [Stripe Token]
      def initialize(subscription:, new_token:)
        @subscription = subscription
        @subscriber   = @subscription.subscriber
        @new_token    = new_token
      end

      def call
        begin
          update_stripe_subscription
          update_influx_subscription
        rescue Stripe::StripeError => e
          @subscription.errors[:base] << e.message
        end
        @subscription
      end

      private

      def update_stripe_subscription
        stripe_customer            = Stripe::Customer.retrieve(@subscriber.stripe_customer_id)
        stripe_subscription        = stripe_customer.subscriptions.retrieve(@subscription.stripe_id)
        stripe_subscription.source = @new_token
        stripe_subscription.save
      end

      def update_influx_subscription
        stripe_customer = Stripe::Customer.retrieve(@subscription.stripe_customer_id)
        card            = stripe_customer.sources.retrieve(stripe_customer.default_source)
        @subscription.update_attributes(
          card_type:       card.brand,
          card_last4:      card.last4,
          card_expiration: Date.parse("#{card.exp_year}/#{card.exp_month}/1"),
          stripe_token:    @new_token
        )
        @subscription.save!
      end
    end
  end
end
