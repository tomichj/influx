module Influx
  class CreateStripePlan
    def self.call(plan)

      # Try to load Stripe's notion of the plan if it already exists.
      begin
        return Stripe::Plan.retrieve(plan.stripe_id)
      rescue Stripe::InvalidRequestError
        # fall through
      end

      # Otherwise, create the plan.
      Stripe::Plan.create(
          id: plan.stripe_id,
          name: plan.name,
          amount: plan.amount,
          currency: Influx.configuration.default_currency,
          interval: plan.interval,
          interval_count: plan.interval_count,
          trial_period_days: plan.trial_period_days,
      )
    end
  end
end
