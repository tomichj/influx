require 'aasm'

module Influx

  #
  # A subscription.
  #
  # Can be in several states:
  # * pending
  # * active
  # * canceled
  # * errorred
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

    validates_presence_of :plan
    validates_presence_of :subscriber

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

    # Update the subscription's notion of itself with the info from Stripe.
    def sync_with!(stripe_subscription)
      self.current_period_start = Time.at(stripe_subscription.current_period_start)
      self.current_period_end   = Time.at(stripe_subscription.current_period_end)
      self.started_at           = Time.at(stripe_subscription.start) if stripe_subscription.start
      self.ended_at             = Time.at(stripe_subscription.ended_at) if stripe_subscription.ended_at
      self.trial_start          = Time.at(stripe_subscription.trial_start) if stripe_subscription.trial_start
      self.trial_end            = Time.at(stripe_subscription.trial_end) if stripe_subscription.trial_end
      self.canceled_at          = Time.at(stripe_subscription.canceled_at) if stripe_subscription.canceled_at
      self.stripe_status        = stripe_subscription.status
      self.cancel_at_period_end = stripe_subscription.cancel_at_period_end
      self.save!
      self
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
