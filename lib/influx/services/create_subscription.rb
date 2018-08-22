module Influx
  module Services
    #
    # Create an Influx::Subscription and activate it's corresponding Stripe subscription.
    #
    class CreateSubscription
      include Influx::Services::Service

      #
      # Create a subscription.
      #
      # @param plan [Influx::Plan] to subscribe to. Plan must already exist in stripe.
      # @param subscriber [Influx::Subscriber] the model (aka user) subscribing to the plan.
      # @param token [Stripe Token] token for payment source, from stripe
      # @param options [Hash] :trial_end, the end date of trial, in Unix time (DateTime.to_i)
      def initialize(plan:, subscriber:, token:, options: {})
        @plan       = plan
        @subscriber = subscriber
        @token      = token
        @options    = options
      end

      def call
        subscription = Influx::Subscription.new do |s|
          s.subscriber   = @subscriber
          s.amount       = @plan.amount
          s.plan         = @plan
          s.email        = @subscriber.email
          s.stripe_token = @token
          s.trial_end    = @options[:trial_end] if @options[:trial_end].present?
        end
        subscription.save
        subscription.activate_stripe_subscription
        subscription
      end
    end
  end
end
