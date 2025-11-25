# frozen_string_literal: true

module SalesTaxes
  module Models
    # Represents a receipt with line items and calculated totals
    class Receipt
      attr_reader :line_items

      def initialize(line_items:)
        @line_items = line_items
        freeze
      end

      def total_taxes
        line_items.sum(&:tax_amount)
      end

      def total
        line_items.sum(&:total_price)
      end
    end
  end
end
