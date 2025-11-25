# frozen_string_literal: true

module SalesTaxes
  module Services
    # Formats a receipt into the required output format
    class Formatter
      # Formats a receipt into a string
      def self.format(receipt)
        lines = receipt.line_items.map do |line_item|
          format_line_item(line_item)
        end

        # Add summary lines
        lines << "Sales Taxes: #{format_price(receipt.total_taxes)}"
        lines << "Total: #{format_price(receipt.total)}"

        lines.join("\n")
      end

      def self.format_line_item(line_item)
        "#{line_item.quantity} #{line_item.product.name}: #{format_price(line_item.total_price)}"
      end

      def self.format_price(price)
        Kernel.format('%.2f', price)
      end
    end
  end
end
