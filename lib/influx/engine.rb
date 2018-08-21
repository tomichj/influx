#
# https://content.pivotal.io/blog/leave-your-migrations-in-your-rails-engines
#
module Influx
  class Engine < ::Rails::Engine
    isolate_namespace Influx

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_bot, dir: 'spec/factories'
    end

    initializer :append_migrations do |app|
      unless app.root.to_s.match root.to_s
        config.paths["db/migrate"].expanded.each do |expanded_path|
          app.config.paths["db/migrate"] << expanded_path
          ActiveRecord::Migrator.migrations_paths << expanded_path
        end
      end
    end

    initializer :configure_subscription_listeners do |app|
      Influx.configure do |config|
        config.subscribe 'invoice.payment_failed',        Influx::Events::EventPaymentFailed
        config.subscribe 'invoice.payment_succeeded',     Influx::Events::EventPaymentSucceeded
        config.subscribe 'customer.subscription.deleted', Influx::Events::EventSubscriptionDeleted
        config.subscribe 'customer.subscription.updated', Influx::Events::EventSubscriptionUpdated
      end
    end
  end
end
