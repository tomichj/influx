include Influx::MigrationHelpers

class CreateInfluxSubscriptions < base_migration()
  def change
    create_table :influx_subscriptions do |t|
      t.references :influx_plan, index: true, null: false

      t.integer :subscriber_id, null: false
      t.string :stripe_customer_id
      t.string :email

      t.timestamp :start
      t.boolean   :cancel_at_period_end
      t.timestamp :current_period_start
      t.timestamp :current_period_end
      t.timestamp :ended_at
      t.timestamp :trial_start
      t.timestamp :trial_end
      t.timestamp :canceled_at

      t.string :stripe_status
      t.string :stripe_id
      t.string :stripe_token
      t.string :card_last4
      t.date   :card_expiration
      t.string :card_type
      t.text   :error


      t.timestamps
    end

    add_foreign_key :influx_subscriptions, :influx_plans
  end
end
