require 'active_support/concern'

module Influx

  # The client subscriber class should include this concern.
  module Subscriber
    extend ActiveSupport::Concern

    included do
      has_many :subscriptions, class_name: 'Influx::Subscription', foreign_key: 'subscriber_id'
      has_many :invoice_payments, class_name: 'Influx::InvoicePayment', foreign_key: 'subscriber_id'
    end
  end
end
