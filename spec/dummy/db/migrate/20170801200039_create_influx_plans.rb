include Influx::MigrationHelpers

class CreateInfluxPlans < migration_base_class()
  def change
    create_table :influx_plans do |t|
      t.string :stripe_id
      t.string :name,               limit: 250
      t.integer :amount
      t.string :interval,           limit: 250
      t.integer :interval_count
      t.integer :trial_period_days
      t.boolean :published

      t.timestamps
    end

    add_index :influx_plans, :stripe_id
  end
end
