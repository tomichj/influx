require 'spec_helper'

module Influx
  module Services

    describe ActivateStripePlan do
      describe '#call' do
        it 'creates the stripe plan' do
          plan = create(:plan)
          expect(Stripe::Plan).to receive(:create)
          ActivateStripePlan.call(plan: plan)
        end

        it 'skips creating a stripe plan if one already exists with that ID' do
          plan = create(:plan)
          plan.create_stripe_plan
          expect(Stripe::Plan).to_not receive(:create)
          ActivateStripePlan.call(plan: plan)
        end

      end
    end
  end
end
