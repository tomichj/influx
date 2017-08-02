include Influx::MigrationHelpers

class CreateInfluxSubscriptions < base_migration()
  def change
    create_table :influx_subscriptions do |t|
      t.references :influx_plans

      t.timestamp :start

      t.string :subscriber_type
      t.integer :subscriber_id

      t.boolean :cancel_at_period_end

      t.timestamp :current_period_start
      t.timestamp :current_period_end
      t.timestamp :ended_at
      t.timestamp :trial_start
      t.timestamp :trial_end
      t.timestamp :canceled_at

      t.string   :stripe_id
      t.string   :stripe_token
      t.string   :card_last4
      t.date     :card_expiration
      t.string   :card_type
      t.text     :error
      t.string   :state
      t.string   :email

      t.timestamps
    end

  end
end
