module Influx
  class CreatePlan
    def self.call(options={})
      plan = Influx::Plan.new(options)

      if !plan.valid?
        return plan
      end

      begin
        plan.create_stripe_plan
      rescue Stripe::StripeError => e
        plan.errors[:base] << e.message
        return plan
      end

      plan.save
      return plan
    end
  end
end
