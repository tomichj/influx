include Influx::MigrationHelpers

class AddStripeCustomerIdToSubscriber < migration_base_class()
  def change
    add_column Influx.configuration.subscriber_plural, :stripe_customer_id, :string, limit: 191
    add_index Influx.configuration.subscriber_plural, :stripe_customer_id
  end
end

