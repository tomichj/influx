module Influx

  #
  # Behavior used by invoicing events.
  #
  module Invoicing
    extend ActiveSupport::Concern

    def invoice_for(stripe_invoice)
      subscription = Influx::Subscription.find_by!(stripe_id: stripe_invoice.subscription)
      sync_to_stripe_subscription(subscription, stripe_invoice)

      invoice = create_invoice(subscription, stripe_invoice)
      update_invoice_with_subscription_period(invoice, stripe_invoice)
      update_invoice_with_charge(invoice, stripe_invoice)

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
        s.payment_at = Time.at(stripe_invoice.date) if stripe_invoice.date
      end
    end

    def update_invoice_with_subscription_period(invoice, stripe_invoice)
      subscription_line = stripe_invoice.lines.find{|line_item| line_item.type == 'subscription'}
      start_at = subscription_line.period[:start] if subscription_line
      end_at = subscription_line.period[:end] if subscription_line
      invoice.period_start = Time.at(start_at) if start_at
      invoice.period_end   = Time.at(end_at) if end_at
    end

    def update_invoice_with_charge(invoice, stripe_invoice)
      stripe_charge = Stripe::Charge.retrieve(stripe_invoice.charge)
      invoice.error           = stripe_charge.failure_message
      invoice.stripe_id       = stripe_charge.id
      invoice.card_type       = stripe_charge.source.brand
      invoice.card_last4      = stripe_charge.source.last4
      invoice.card_expiration = Date.parse("#{stripe_charge.source.exp_year}/#{stripe_charge.source.exp_month}/1")

      Rails.logger.info "CARD EXPIRATION INFO, YEAR/MONTH: #{stripe_charge.source.exp_year}/#{stripe_charge.source.exp_month}"

      if stripe_charge.respond_to?(:fee)
        invoice.fee_amount = stripe_charge.fee
      elsif !stripe_charge.balance_transaction.nil?
        balance = Stripe::BalanceTransaction.retrieve(stripe_charge.balance_transaction)
        invoice.fee_amount = balance.fee
      end
    end
  end
end
