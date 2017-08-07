require 'spec_helper'

module Influx
  describe CreateStripePlan do
    describe '#call' do
      it 'skips creating a stripe plan if one already exists with that ID' do
        plan = create(:influx_plan)
        plan.create_stripe_plan
        expect(Stripe::Plan).to_not receive(:create)
        Influx::CreateStripePlan.call(plan)
      end
    end
  end
end
