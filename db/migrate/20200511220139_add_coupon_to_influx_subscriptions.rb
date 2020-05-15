include Influx::MigrationHelpers

class AddCouponToInfluxSubscriptions < migration_base_class()
  def change
    add_column :influx_subscriptions, :coupon, :string
  end
end
