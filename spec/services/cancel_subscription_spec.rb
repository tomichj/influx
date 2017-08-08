require 'spec_helper'

module Influx
  describe CancelSubscription do
    let(:token){ StripeMock.generate_card_token({}) }
    describe '#call' do
      it 'cancels' do
        plan = create(:influx_plan)
        subscriber = create(:subscriber)
        @subscription = create(:subscription, subscriber: subscriber, plan: plan, stripe_token: token)
        Influx::ActivateStripeSubscription.call(subscripton: @subscription)
        puts @subscription.inspect
      end
    end
  end
end