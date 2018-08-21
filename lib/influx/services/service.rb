require 'active_support/concern'

module Influx
  module Services
    module Service
      extend ActiveSupport::Concern

      class_methods do
        def call(*args)
          new(*args).call
        end
      end
    end
  end
end
