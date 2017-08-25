require 'active_support/concern'

module Influx

  #
  # Subscriber supports a single subscription. For use with simple SaaS applications.
  # Applications requiring multiple subscriptions can easily implement this,
  # but with `has_many :subscriptions...` instead of has_one.
  module Subscriber
    extend ActiveSupport::Concern

    included do
      has_one :subscription, class_name: 'Influx::Subscription', foreign_key: 'subscriber_id'
      has_many :invoice_payments, class_name: 'Influx::InvoicePayment', foreign_key: 'subscriber_id'
    end

    def subscription_active?
      subscription.present? && subscription.active?
    end

    def subscription_errored?
      subscription.present? && subscription.errored?
    end

    def subscription_canceled?
      subscription.present? && subscription.subscription_canceled?
    end
  end
end
