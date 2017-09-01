require 'spec_helper'

module Influx
  describe InvoicePayment do
    describe 'events' do
      it 'fires finished event on finish' do
        invoice = build(:invoice_payment)
        expect(Influx.configuration).to receive(:instrument).with('influx.invoice.payment.succeeded', invoice)
        invoice.finish!
      end
      it 'fires failed event on fail' do
        invoice = build(:invoice_payment)
        expect(Influx.configuration).to receive(:instrument).with('influx.invoice.payment.failed', invoice)
        invoice.fail!
      end
    end

    describe '#uuid' do
      it 'has a uuid' do
        invoice = build(:invoice_payment, uuid: nil)
        invoice.save!
        expect(invoice.reload.uuid).to_not be_nil
      end
      it 'reloads the uuid on collision' do
        first_uuid = create(:invoice_payment).uuid
        expect(SecureRandom).to receive(:uuid).and_return(first_uuid, 'all sweet')
        invoice = build(:invoice_payment)
        invoice.save
        expect(invoice.uuid).to eq 'all sweet'
      end
      it 'uuid not generated when validations fail' do
        invoice = build(:invoice_payment, uuid: nil)
        invoice.email = nil
        invoice.save
        expect(invoice.uuid).to be_nil
      end
    end

    describe '#state' do
      it 'can change from pending to finished' do
        invoice = create(:invoice_payment, state: 'pending')
        invoice.save!
        invoice.finish!
        expect(invoice.reload.finished?).to be_truthy
      end
    end
  end
end
