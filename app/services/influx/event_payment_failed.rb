module Influx

  #
  # Record a failed payment.
  #
  # event name: 'invoice.payment_failed'
  #
  class EventPaymentFailed
    include Influx::Invoicing

    def initialize(event)
      @event = event
    end

    def call
      stripe_invoice = @event.data.object
      return unless stripe_invoice.charge

      invoice = invoice_for(stripe_invoice)
      invoice.save!
      invoice.fail!
    end
  end
end
