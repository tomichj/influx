module Influx

  #
  # Create an Influx::Subscription and activate it's corresponding Stripe subscription.
  #
  class CreateSubscription
    include Influx::Service

    #
    # Consider splitting into creation of the Influx::Subscription and then
    # queuing up a Job to fire off the subscription request to Stripe.
    #
    # plan: Influx::Plan to subscribe to. Plan must already exist in stripe.
    # subscriber: the model subscribing to the plan.
    # token: token for payment source, from stripe
    # options:
    #   trial_end - end date of trial, as a Time
    def initialize(plan:, subscriber:, token:, coupon: nil, options: {})
      @plan = plan
      @subscriber = subscriber
      @token = token
      @coupon = coupon
      @options = options
    end


    def call
      subscription = Influx::Subscription.new do |s|
        s.subscriber = @subscriber
        s.amount = @plan.amount
        s.plan = @plan
        s.email = @subscriber.email
        s.stripe_token = @token
        s.trial_end = @options[:trial_end] if @options[:trial_end].present?
        s.coupon = @coupon
      end
      subscription.save
      subscription.activate_stripe_subscription
      subscription
    end
  end
end
