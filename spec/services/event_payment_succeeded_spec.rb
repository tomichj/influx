require 'spec_helper'

module Influx
  describe EventPaymentSucceeded do

    describe '#call' do
      before(:each) do
        token = StripeMock.generate_card_token({})
        @subscription = create(:subscription, stripe_token: token)
        ActivateStripePlan.call(plan: @subscription.plan)
        ActivateStripeSubscription.call(subscription: @subscription)
      end

      it 'does nothing if invoice has no charge' do
        event = StripeMock.mock_webhook_event('invoice.payment_succeeded',
                                              subscription: @subscription.stripe_id, charge: nil)
        expect{EventPaymentSucceeded.call(event)}.to change { InvoicePayment.count }.by(0)
      end

      it 'creates an influx invoice payment with no fee or balance transaction' do
        stripe_customer = Stripe::Customer.retrieve(@subscription.stripe_customer_id)
        stripe_charge = Stripe::Charge.create(amount: 100, currency: 'usd', customer: stripe_customer.id)
        allow(stripe_charge).to receive(:balance_transaction).and_return(nil)
        expect(Stripe::Charge).to receive(:retrieve).and_return(stripe_charge)
        event = StripeMock.mock_webhook_event('invoice.payment_succeeded',
                                              subscription: @subscription.stripe_id, charge: stripe_charge)
        expect{EventPaymentSucceeded.call(event)}.to change { InvoicePayment.count }.by(1)
      end

      it 'creates an influx invoice payment with a fee' do
        puts @subscription.inspect
        stripe_customer = Stripe::Customer.retrieve(@subscription.stripe_customer_id)
        stripe_charge = Stripe::Charge.create(amount: 100, currency: 'usd', customer: stripe_customer.id)
        allow(stripe_charge).to receive(:fee).and_return(1000)
        expect(Stripe::Charge).to receive(:retrieve).and_return(stripe_charge)
        event = StripeMock.mock_webhook_event('invoice.payment_succeeded',
                                              subscription: @subscription.stripe_id, charge: stripe_charge)
        expect{EventPaymentSucceeded.call(event)}.to change { InvoicePayment.count }.by(1)
      end


      it 'creates an influx invoice payment with a balance transaction' do
        stripe_customer = Stripe::Customer.retrieve(@subscription.stripe_customer_id)
        stripe_charge = Stripe::Charge.create(amount: 100, currency: 'usd', customer: stripe_customer.id)
        expect(Stripe::BalanceTransaction).to receive(:retrieve).and_return(OpenStruct.new( amount: 100, fee: 2.34, currency: 'usd' ))
        event = StripeMock.mock_webhook_event('invoice.payment_succeeded',
                                              subscription: @subscription.stripe_id, charge: stripe_charge)
        expect{EventPaymentSucceeded.call(event)}.to change { InvoicePayment.count }.by(1)
      end

    end
  end
end
