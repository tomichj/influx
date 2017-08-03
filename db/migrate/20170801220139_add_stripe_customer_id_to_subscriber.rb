include Influx::MigrationHelpers

class AddStripeCustomerIdToSubscriber < base_migration()
  def change
    add_column Influx.configuration.subscriber_plural, :stripe_customer_id, :string, limit: 191
    add_index Influx.configuration.subscriber_plural, :stripe_customer_id
  end
end

