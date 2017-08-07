require 'aasm'

module Influx
  class Subscription < ActiveRecord::Base
    include AASM

    validates_presence_of :plan
    validates_presence_of :subscriber

    belongs_to :plan, class_name: 'Influx::Plan', foreign_key: 'influx_plan_id'
    belongs_to :subscriber, class_name: Influx.configuration.subscriber

    aasm column: 'state' do
      state :pending, initial: true
      state :active
      state :cancelled
      state :errored

      event :activate, after: :start_subscription do
        transitions from: :pending, to: :active
      end

      event :cancel do
        transitions from: :active, to: :canceled
      end

      event :fail do
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

    def start_subscription
      Influx::StartSubscription.call(self)
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
      self.save!
      self
    end
  end
end
