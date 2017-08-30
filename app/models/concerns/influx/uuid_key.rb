require 'active_support/concern'
require 'securerandom'

module Influx
  module UuidKey
    extend ActiveSupport::Concern
    
    included do
      before_save :populate_uuid
      validates_uniqueness_of :uuid
    end

    def populate_uuid
      if new_record?
        while !valid? || self.uuid.nil?
          self.uuid = SecureRandom.uuid
        end
      end
    end
  end
end
