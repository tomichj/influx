module Influx
  module Services
    #
    # Activate a plan on Stripe, or fetch the plan from Stripe if it's already been created there.
    #
    class ActivateStripePlan
      include Influx::Services::Service

      # @param [Influx::Plan]
      def initialize(plan:)
        @plan = plan
      end

      def call
        begin
          # Try to load Stripe's notion of the plan if it already exists.
          return Stripe::Plan.retrieve(@plan.stripe_id)
        rescue Stripe::InvalidRequestError
          # Stripe plan doesn't exists yet, that's ok, let it fall through
        end

        # Create the plan.
        Stripe::Plan.create(
          {
            id:                @plan.stripe_id,
            name:              @plan.name,
            amount:            @plan.amount,
            currency:          Influx.configuration.default_currency,
            interval:          @plan.interval,
            interval_count:    @plan.interval_count,
            trial_period_days: @plan.trial_period_days
          })
      end
    end
  end
end
