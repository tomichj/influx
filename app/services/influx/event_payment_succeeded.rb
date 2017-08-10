module Influx

  #
  # Record a successful payment.
  #
  # Event name: 'invoice.payment_succeeded'
  #
  class EventPaymentSucceeded
    include Influx::Service
    include Influx::Invoicing

    def initialize(event)
      @event = event
    end

    def call
      stripe_invoice = @event.data.object
      return unless stripe_invoice.charge

      invoice = invoice_for(stripe_invoice)
      invoice.save!
      invoice.finish!
      invoice
    end
  end
end
