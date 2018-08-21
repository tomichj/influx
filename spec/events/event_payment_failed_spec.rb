require 'spec_helper'

module Influx
  module Events
    describe EventPaymentFailed do
      describe '#call' do
        before(:each) do
          token         = StripeMock.generate_card_token({})
          @subscription = create(:subscription, stripe_token: token)
          Influx::Services::ActivateStripePlan.call(plan: @subscription.plan)
          Influx::Services::ActivateStripeSubscription.call(subscription: @subscription)
        end

        context 'no fee or balance transaction' do
          before(:each) do
            stripe_customer = Stripe::Customer.retrieve(@subscription.stripe_customer_id)
            stripe_charge   = Stripe::Charge.create(amount:          100,
                                                    currency:        'usd',
                                                    failure_message: 'Failed! OMG!',
                                                    customer:        stripe_customer.id)
            allow(stripe_charge).to receive(:balance_transaction).and_return(nil)
            expect(Stripe::Charge).to receive(:retrieve).and_return(stripe_charge)
            @event = StripeMock.mock_webhook_event('invoice.payment_succeeded',
                                                   subscription: @subscription.stripe_id, charge: stripe_charge)
          end

          it 'creates an invoice' do
            expect { EventPaymentFailed.call(@event) }.to change { InvoicePayment.count }.by(1)
          end

          it 'creates an invoice with failed status' do
            invoice = EventPaymentFailed.call(@event)
            expect(invoice.errored?).to be true
          end

          it 'creates an invoice with an error message' do
            invoice = EventPaymentFailed.call(@event)
            expect(invoice.error).to eq 'Failed! OMG!'
          end
        end
      end
    end
  end
end
