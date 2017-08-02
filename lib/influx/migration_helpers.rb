module Influx
  module MigrationHelpers
    def base_migration
      if Rails.version >= '5.0.0'
        'ActiveRecord::Migration[4.2]'.constantize
      else
       'ActiveRecord::Migration'.constantize
      end
    end
  end
end
