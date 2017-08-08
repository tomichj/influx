require 'spec_helper'

module Influx
  describe CancelSubscription do
    let(:token){ StripeMock.generate_card_token({}) }
    describe '#call' do
      before(:each) do
        @subscription = create(:subscription, plan: plan, stripe_token: token)
        ActivateStripeSubscription(@subscription)
      end

      it 'cancels the subscription immediately' do
        CancelSubscription.call(@subscription)
        expect(@subscription.reload.state).to eq 'canceled'
      end

    end
  end
end
