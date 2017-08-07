# $LOAD_PATH.unshift(File.dirname(__FILE__))

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../dummy/config/environment', __FILE__)
require 'rspec/rails'
require 'factory_girl_rails'
require 'stripe_mock'

ENV['STRIPE_SECRET_KEY'] = 'sk_testing12345'
ENV['STRIPE_PUBLISHABLE_KEY'] = 'pk_test12345'

Dir[Rails.root.join("../support/**/*.rb")].each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.mock_with :rspec
  config.use_transactional_fixtures = true
  config.infer_base_class_for_anonymous_controllers = false
  config.order = 'random'
  config.infer_spec_type_from_file_location!
  config.include FactoryGirl::Syntax::Methods

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:each) do
    StripeMock.start
  end

  config.after(:each) do
    StripeMock.stop
  end
end
