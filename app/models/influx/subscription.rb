module Influx
  class Subscription < ActiveRecord::Base
    belongs_to :plan, class_name: 'Influx::Plan', as: :plan, dependent: :restrict_with_exception
    belongs_to Influx.configuration.subscriber_singular

    def sync_with!(stripe_sub)
      self.current_period_start = Time.at(stripe_sub.current_period_start)
      self.current_period_end   = Time.at(stripe_sub.current_period_end)
      self.ended_at             = Time.at(stripe_sub.ended_at) if stripe_sub.ended_at
      self.trial_start          = Time.at(stripe_sub.trial_start) if stripe_sub.trial_start
      self.trial_end            = Time.at(stripe_sub.trial_end) if stripe_sub.trial_end
      self.canceled_at          = Time.at(stripe_sub.canceled_at) if stripe_sub.canceled_at
      self.stripe_status        = stripe_sub.status
      self.cancel_at_period_end = stripe_sub.cancel_at_period_end

      self.save!
      self
    end
  end
end
