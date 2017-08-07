require 'spec_helper'

module Influx
  describe CreatePlan do
    let(:stripe_helper) { StripeMock.create_test_helper }
    let(:token) { StripeMock.generate_card_token({}) }

    describe "#call" do
      before :each do
        @influx_plan = create(:influx_plan)
      end

      it 'loads plan' do
        plan = Stripe::Plan.retrieve(@influx_plan.stripe_id)
        puts plan.inspect
      end
    end

  end
end

#
# describe Influx::CreatePlan do
# end
#