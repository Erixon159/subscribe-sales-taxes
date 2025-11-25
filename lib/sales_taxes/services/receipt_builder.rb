# frozen_string_literal: true

require 'bigdecimal'

module SalesTaxes
  module Services
    # Builds a receipt from input lines by orchestrating parsing, tax calculation, and line item creation
    class ReceiptBuilder
      # Processes input lines and returns a complete receipt
      def self.build_from_input(input_lines)
        line_items = input_lines.filter_map do |line|
          build_line_item(line)
        end

        Models::Receipt.new(line_items: line_items)
      end

      # Builds a single line item from an input line
      def self.build_line_item(line)
        parsed = InputParser.parse_line(line)
        return nil unless parsed

        product = Models::Product.new(
          name: parsed[:name],
          base_price: parsed[:price],
          imported: parsed[:imported],
          category: parsed[:category]
        )

        base_price = BigDecimal(product.base_price.to_s)
        tax_amount = TaxCalculator.calculate_line_tax(product, parsed[:quantity])
        total_price = (base_price * parsed[:quantity]) + tax_amount

        Models::LineItem.new(
          product: product,
          quantity: parsed[:quantity],
          tax_amount: tax_amount,
          total_price: total_price
        )
      end
    end
  end
end
