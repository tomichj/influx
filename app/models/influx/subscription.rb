require 'aasm'

module Influx

  #
  # A subscription, requires a plan and a subscriber.
  #
  # Can be in several states:
  # * pending - Stripe subscription not yet started
  # * active - Stripe subscription is started
  # * canceled - Stripe subscription is canceled
  # * errorred - attempted to start Stripe subscription, but it failed
  #
  # The following events are fired:
  # * influx.subscription.active - when account is activated
  # * influx.subscription.cancel - when account is canceled
  # * influx.subscription.fail - when an error occurs processing the subscription
  #
  class Subscription < ActiveRecord::Base
    include AASM

    belongs_to :plan, class_name: 'Influx::Plan', foreign_key: 'influx_plan_id'
    belongs_to :subscriber, class_name: Influx.configuration.subscriber

    has_many :invoices, class_name: 'Influx::InvoicePayment'

    validates_presence_of :plan
    validates_presence_of :subscriber
    validates_presence_of :email


    aasm column: 'state' do
      state :pending, initial: true
      state :active
      state :canceled
      state :errored

      event :activate, after: :instrument_activate do
        transitions from: :pending, to: :active
      end

      event :cancel, after: :instrument_canceled do
        transitions from: :active, to: :canceled
      end

      event :fail, after: :instrument_failed do
        transitions from: :pending, to: :errored
      end
    end

    def is_trial?
      stripe_status == 'trialing'
    end

    def trial_expired?
      return false unless stripe_status == 'trialing'
      trial_end < Time.now
    end

    def card_info?
      card_last4 && card_type && card_expiration
    end

    # Update the subscription's notion of itself with the info from Stripe.
    def sync_with!(stripe_subscription)
      self.current_period_start = Time.at(stripe_subscription.current_period_start)
      self.current_period_end   = Time.at(stripe_subscription.current_period_end)
      self.ended_at             = Time.at(stripe_subscription.ended_at) if stripe_subscription.ended_at
      self.trial_start          = Time.at(stripe_subscription.trial_start) if stripe_subscription.trial_start
      self.trial_end            = Time.at(stripe_subscription.trial_end) if stripe_subscription.trial_end
      self.canceled_at          = Time.at(stripe_subscription.canceled_at) if stripe_subscription.canceled_at
      self.stripe_status        = stripe_subscription.status
      self.cancel_at_period_end = stripe_subscription.cancel_at_period_end
      self.amount               = stripe_subscription.plan.amount
      # Support for discounts is added to stripe-ruby-mock in v2.2.0, 84f08eb
      self.coupon               = stripe_subscription.discount && stripe_subscription.discount.coupon.id if stripe_subscription.respond_to?(:discount)

      self.save!
      self
    end

    def activate_stripe_subscription
      Influx::ActivateStripeSubscription.call(subscription: self)
    end

    private

    def instrument_activate
      Influx.configuration.instrument('influx.subscription.active', self)
    end

    def instrument_canceled
      Influx.configuration.instrument('influx.subscription.cancel', self)
    end

    def instrument_failed
      Influx.configuration.instrument('influx.subscription.fail', self)
    end

  end
end
