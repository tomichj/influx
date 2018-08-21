module Influx
  module Services
    #
    # Create an Influx::Plan, and the corresponding Stripe plan.
    #
    # If the Influx plan is created but Stripe fails,
    # the errors will be set on the returned Influx::Plan.
    #
    # Example:
    #   Influx::CreatePlan.call(stripe_id: 'test_plan', name: 'The Test Plan', amount: 5000, interval: 'month',
    #                           interval_count: 1, trial_period_days: 0, published: false)
    #
    class CreatePlan
      include Influx::Services::Service

      def initialize(params = {})
        @params = params
      end

      # @return [Influx::Plan]
      def call
        plan = Influx::Plan.new(@params)

        if !plan.valid?
          return plan
        end

        begin
          plan.create_stripe_plan
        rescue Stripe::StripeError => e
          Rails.logger.info "Exception creating stripe plan from influx plan. plan:#{plan.inspect} exception:#{e.inspect}"
          plan.errors[:base] << e.message
          return plan
        end

        plan.save
        plan
      end
    end
  end
end

# plan = Influx::CreatePlan.call(stripe_id: 'test_plan', name: 'The Test Plan', amount: 5000, interval: 'month', interval_count: 1, trial_period_days: 0, published: false)
