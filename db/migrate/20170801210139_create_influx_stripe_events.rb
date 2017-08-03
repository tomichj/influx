include Influx::MigrationHelpers

class CreateInfluxStripeEvents < base_migration()
  def change
    create_table :influx_stripe_events do |t|
      t.string   :stripe_id, index: true
      t.timestamps
    end
  end
end
