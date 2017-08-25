module Influx
  module PriceHelper

    # Format an amount from Stripe as a currency.
    # Example:
    #   <td><%= formatted_price(@subscription.amount) %></td>
    #
    def formatted_price(amount, opts = {})
      number_to_currency((amount || 0) / 100.0, opts)
    end
  end
end
