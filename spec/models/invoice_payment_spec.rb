require 'spec_helper'

module Influx
  describe InvoicePayment do
    describe 'events' do
      it 'fires finished event on finish' do
        invoice = build(:invoice_payment)
        expect(Influx.configuration).to receive(:instrument).with('influx.invoice.payment.finished', invoice)
        invoice.finish!
      end
      it 'fires failed event on fail' do
        invoice = build(:invoice_payment)
        expect(Influx.configuration).to receive(:instrument).with('influx.invoice.payment.failed', invoice)
        invoice.fail!
      end
    end
  end
end
