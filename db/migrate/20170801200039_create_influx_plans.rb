include Influx::MigrationHelpers

class CreateInfluxPlans < base_migration()
  def change
    create_table :influx_plans do |t|
      t.string :stripe_id
      t.string :name,               limit: 250
      t.integer :amount
      t.string :interval,           limit: 250
      t.integer :interval_count
      t.integer :trial_period_days

      t.timestamps
    end

    add_index 'influx_plans', ['stripe_id'], name: 'index_influx_plans_on_stripe_id', using: :btree
  end
end
