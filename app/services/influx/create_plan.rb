module Influx
  class CreatePlan
    def self.call(plan)
      begin
        return Stripe::Plan.retrieve(plan.stripe_id)
      rescue Stripe::InvalidRequestError
        # fall through
      end

      Stripe::Plan.create(
        id:                plan.stripe_id,
        amount:            plan.amount,
        interval:          plan.interval,
        name:              plan.name,
        interval_count:    plan.interval_count,
        currency:          Influx.configuration.default_currency,
        trial_period_days: plan.trial_period_days
        )
    end
  end
end
