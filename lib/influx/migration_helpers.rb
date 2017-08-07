module Influx
  module MigrationHelpers
    def migration_base_class
      if Rails.version >= '5.0.0'
        ActiveRecord::Migration[4.2]
      else
        ActiveRecord::Migration
      end
    end
  end
end
