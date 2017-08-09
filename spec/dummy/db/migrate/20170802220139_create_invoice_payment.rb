include Influx::MigrationHelpers

class CreateInvoicePayment < migration_base_class()
  def change
    create_table :influx_invoice_payment do |t|
      t.string   'email', limit: 191
      t.integer  'subscriber_id'
      t.integer  'subscription_id'
      t.integer  'plan_id'
      t.integer  'amount'
      t.integer  'fee_amount'
      t.string   'currency'
      t.datetime 'created_at'
      t.datetime 'updated_at'
      t.string   'state'
      t.string   'stripe_id'
      t.string   'stripe_token'
      t.string   'card_last4'
      t.date     'card_expiration'
      t.string   'card_type'
      t.text     'error'
      t.text     'customer_address'
      t.text     'business_address'
      t.timestamps
    end

    add_index 'influx_invoice_payment', 'subscription_id'
    add_index 'influx_invoice_payment', 'email'
  end
end
