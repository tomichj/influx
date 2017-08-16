include Influx::MigrationHelpers

class CreateInvoicePayments < migration_base_class()
  def change
    create_table :influx_invoice_payments do |t|
      t.string   'email', limit: 191
      t.integer  'subscriber_id'
      t.integer  'subscription_id'
      t.integer  'plan_id'
      t.integer  'amount'
      t.integer  'fee_amount'
      t.string   'currency'
      t.string   'state'
      t.string   'stripe_id'
      t.string   'card_last4'
      t.date     'card_expiration'
      t.string   'card_type'
      t.text     'error'
      t.timestamps
    end

    add_index 'influx_invoice_payments', 'subscription_id'
    add_index 'influx_invoice_payments', 'email'
  end
end
