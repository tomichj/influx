require 'spec_helper'

module Influx
  module Events
    describe EventPaymentSucceeded do
      describe '#call' do
        before(:each) do
          token         = StripeMock.generate_card_token({})
          @subscription = create(:subscription, stripe_token: token)
          Influx::Services::ActivateStripePlan.call(plan: @subscription.plan)
          Influx::Services::ActivateStripeSubscription.call(subscription: @subscription)
        end

        it 'does nothing if invoice has no charge' do
          event = StripeMock.mock_webhook_event('invoice.payment_succeeded',
                                                subscription: @subscription.stripe_id, charge: nil)
          expect { EventPaymentSucceeded.call(event) }.to change { InvoicePayment.count }.by(0)
        end

        it 'creates an influx invoice payment with no fee or balance transaction' do
          stripe_customer = Stripe::Customer.retrieve(@subscription.stripe_customer_id)
          stripe_charge   = Stripe::Charge.create(amount: 100, currency: 'usd', customer: stripe_customer.id)
          allow(stripe_charge).to receive(:balance_transaction).and_return(nil)
          expect(Stripe::Charge).to receive(:retrieve).and_return(stripe_charge)
          event = StripeMock.mock_webhook_event('invoice.payment_succeeded',
                                                subscription: @subscription.stripe_id, charge: stripe_charge)
          expect { EventPaymentSucceeded.call(event) }.to change { InvoicePayment.count }.by(1)
        end

        it 'creates an influx invoice payment with a fee' do
          stripe_customer = Stripe::Customer.retrieve(@subscription.stripe_customer_id)
          stripe_charge   = Stripe::Charge.create(amount: 100, currency: 'usd', customer: stripe_customer.id)
          allow(stripe_charge).to receive(:fee).and_return(1000)
          expect(Stripe::Charge).to receive(:retrieve).and_return(stripe_charge)
          event = StripeMock.mock_webhook_event('invoice.payment_succeeded',
                                                subscription: @subscription.stripe_id, charge: stripe_charge)
          expect { EventPaymentSucceeded.call(event) }.to change { InvoicePayment.count }.by(1)
        end

        it 'sets subscription start and end' do
          stripe_customer = Stripe::Customer.retrieve(@subscription.stripe_customer_id)
          stripe_charge   = Stripe::Charge.create(amount: 100, currency: 'usd', customer: stripe_customer.id)
          allow(stripe_charge).to receive(:balance_transaction).and_return(nil)
          expect(Stripe::Charge).to receive(:retrieve).and_return(stripe_charge)
          event = StripeMock.mock_webhook_event('invoice.payment_succeeded',
                                                subscription: @subscription.stripe_id, charge: stripe_charge)
          EventPaymentSucceeded.call(event)
          invoice = InvoicePayment.first
          expect(invoice.period_start).to be_present
          expect(invoice.period_end).to be_present
        end
      end
    end
  end
end
