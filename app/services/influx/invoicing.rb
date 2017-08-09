module Influx
  module Invoicing
    extend ActiveSupport::Concern

    def invoice_for(stripe_invoice)
      subscription = Influx::Subscription.find_by!(stripe_id: stripe_invoice.subscription)
      sync_to_stripe_subscription(subscription, stripe_invoice)

      invoice = create_invoice(subscription, stripe_invoice)
      update_invoice_with_charge(invoice)

      invoice
    end

    private

    def sync_to_stripe_subscription(subscription, stripe_invoice)
      stripe_subscription = Stripe::Customer.retrieve(subscription.stripe_customer_id).
        subscriptions.retrieve(stripe_invoice.subscription)
      subscription.sync_with!(stripe_subscription)
    end

    def create_invoice(subscription, stripe_invoice)
      Influx::InvoicePayment.new do |s|
        s.subscription = subscription
        s.plan = subscription.plan
        s.subscriber = subscription.subscriber
        s.email = subscription.email
        s.amount = stripe_invoice.total
        s.currency = stripe_invoice.currency
      end
    end

    def update_invoice_with_charge(invoice)
      stripe_charge = Stripe::Charge.retrieve(stripe_invoice.charge)

      invoice.error      = stripe_charge.failure_message
      invoice.stripe_id  = stripe_charge.id
      invoice.card_type  = stripe_charge.source.brand
      invoice.card_last4 = stripe_charge.source.last4

      if stripe_charge.respond_to?(:fee)
        invoice.fee_amount = stripe_charge.fee
      elsif !stripe_charge.balance_transaction.nil?
        balance = Stripe::BalanceTransaction.retrieve(stripe_charge.balance_transaction)
        invoice.fee_amount = balance.fee
      end
    end

  end
end
