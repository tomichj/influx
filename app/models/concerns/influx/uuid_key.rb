require 'active_support/concern'
require 'securerandom'

module Influx
  module UuidKey
    extend ActiveSupport::Concern
    
    included do
      before_create :populate_uuid
    end

    def populate_uuid
      self.uuid = generate_uuid
    end

    def generate_uuid
      loop do
        token = SecureRandom.uuid
        Rails.logger.info "!!!!!!!!!!!! token: #{token}"
        break token unless self.class.where(uuid: token).exists?
      end
    end
  end
end
