# frozen_string_literal: true

module SalesTaxes
  module Services
    # Parses input lines into structured product data
    class InputParser
      # Keywords that indicate product categories
      # Note: For a better product categorization, we could use a small LLM running as a service
      BOOK_KEYWORDS = %w[book].freeze
      FOOD_KEYWORDS = %w[chocolate chocolates bar].freeze
      MEDICAL_KEYWORDS = %w[pills pill].freeze

      # Parses a single input line into structured data
      def self.parse_line(line)
        return nil if line.nil? || line.strip.empty?

        # Find the last occurrence of " at " to handle product names containing "at"
        last_at_index = line.rindex(' at ')
        return nil unless last_at_index

        # Extract parts
        before_at = line[0...last_at_index].strip
        after_at = line[(last_at_index + 4)..].strip

        # Parse quantity (first word before "at")
        match = before_at.match(/^(\d+)\s+(.+)$/)
        return nil unless match

        quantity = match[1].to_i
        product_name = match[2].strip

        # Validate price format and keep as string to avoid precision loss
        return nil unless after_at.match?(/^\d+(\.\d+)?$/)

        price = after_at
        imported = product_name.include?('imported')
        category = infer_category(product_name)

        {
          quantity: quantity,
          name: product_name,
          price: price,
          imported: imported,
          category: category
        }
      rescue ArgumentError, TypeError
        nil
      end

      # Infers product category from product name keywords
      def self.infer_category(product_name)
        name_lower = product_name.downcase

        return :book if BOOK_KEYWORDS.any? { |keyword| name_lower.include?(keyword) }
        return :food if FOOD_KEYWORDS.any? { |keyword| name_lower.include?(keyword) }
        return :medical if MEDICAL_KEYWORDS.any? { |keyword| name_lower.include?(keyword) }

        :other
      end
    end
  end
end
