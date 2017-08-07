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
      subscription = Influx::Subscription.new do |s|
        s.subscriber = subscriber
        s.amount = plan.amount
        s.plan = plan
        s.email = subscriber.email
        s.stripe_token = token
        s.trial_end = options[:trial_end] if options[:trial_end].present?
      end
      subscription.save
      subscription
    end
  end
end
