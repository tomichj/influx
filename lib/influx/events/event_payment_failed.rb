module Influx
  module Events
    #
    # Record a failed payment.
    #
    # event name: 'invoice.payment_failed'
    #
    class EventPaymentFailed
      include Influx::Services::Service
      include Influx::Events::Invoicing

      def initialize(event)
        @event = event
      end

      def call
        stripe_invoice = @event.data.object
        return unless stripe_invoice.charge

        invoice = invoice_for(stripe_invoice)
        invoice.save!
        invoice.fail!
        invoice
      end
    end
  end
end
