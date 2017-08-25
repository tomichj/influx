require 'active_support/concern'

module Influx

  #
  #
  #
  module Subscriber
    extend ActiveSupport::Concern

    included do
      has_many :subscriptions, class_name: 'Influx::Subscription', foreign_key: 'subscriber_id'
      has_many :invoice_payments, class_name: 'Influx::InvoicePayment', foreign_key: 'subscriber_id'
      scope :most_recent, -> { order('created_at desc').limit(1).first }
    end
  end
end
