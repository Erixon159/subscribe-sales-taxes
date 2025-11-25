# frozen_string_literal: true

module SalesTaxes
  module Models
    # Represents a line on a receipt with product, quantity, and calculated values
    class LineItem
      attr_reader :product, :quantity, :tax_amount, :total_price

      def initialize(product:, quantity:, tax_amount:, total_price:)
        @product = product
        @quantity = quantity
        @tax_amount = tax_amount
        @total_price = total_price
        freeze
      end
    end
  end
end
