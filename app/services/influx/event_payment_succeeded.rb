module Influx

  #
  # Record a successful payment.
  #
  # Event name: 'invoice.payment_succeeded'
  #
  class EventPaymentSucceeded
    include Influx::Invoicing
    include Influx::Service

    def initialize(event)
      @event = event
    end

    def call
      stripe_invoice = @event.data.object
      return unless stripe_invoice.charge

      invoice = invoice_for(stripe_invoice)
      invoice.save!
      invoice.finish!
    end
  end
end