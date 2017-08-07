module Influx
  class CreatePlan
    def self.call(options={})
      plan = Influx::Plan.new(options)
      puts "initial plan: #{plan.inspect}"

      if !plan.valid?
        return plan
      end

      puts 'influx plan is valid'

      begin
        plan.create_stripe_plan
      rescue Stripe::StripeError => e
        puts 'error creating stripe plan'
        plan.errors[:base] << e.message
        return plan
      end

      puts 'created or loaded stripe plan'
      plan.save
      return plan
    end
  end
end

# plan = Influx::CreatePlan.call(stripe_id: 'test_plan', name: 'The Test Plan', amount: 5000, interval: 'month', interval_count: 1, trial_period_days: 30, published: false)
