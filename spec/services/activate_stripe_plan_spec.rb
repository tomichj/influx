require 'spec_helper'

module Influx
  describe ActivateStripePlan do
    describe '#call' do
      it 'creates the stripe account' do
        plan = create(:plan)
        expect(Stripe::Plan).to receive(:create)
        Influx::ActivateStripePlan.call(plan: plan)
      end

      it 'skips creating a stripe plan if one already exists with that ID' do
        plan = create(:plan)
        plan.create_stripe_plan
        expect(Stripe::Plan).to_not receive(:create)
        Influx::ActivateStripePlan.call(plan: plan)
      end

    end
  end
end
