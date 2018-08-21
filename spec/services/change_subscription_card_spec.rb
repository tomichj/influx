require 'spec_helper'

module Influx
  module Services
    describe ChangeSubscriptionCard do
      describe '#call' do
        before do
          token         = StripeMock.generate_card_token({})
          @subscription = create(:subscription, stripe_token: token)
          @subscription.plan.create_stripe_plan
          @subscription.activate_stripe_subscription
        end

        context 'with new valid card source token' do
          before do
            @token = StripeMock.generate_card_token({ last4: '4444', exp_year: '2022', exp_month: '11', brand: 'JCB' })
            ChangeSubscriptionCard.call(subscription: @subscription, new_token: @token)
          end

          it 'updates the card' do
            @subscription.reload
            expect(@subscription.card_last4).to eq '4444'
            expect(@subscription.card_expiration).to eq Date.new(2022, 11, 1)
            expect(@subscription.card_type).to eq 'JCB'
          end

          it 'changes the stripe_token' do
            expect(@subscription.reload.stripe_token).to eq @token
          end
        end
      end
    end
  end
end
