# frozen_string_literal: true

module SalesTaxes
  module Models
    # Represents a purchasable product with immutable attributes
    class Product
      attr_reader :name, :base_price, :imported, :category

      EXEMPT_CATEGORIES = %i[book food medical].freeze

      def initialize(name:, base_price:, imported:, category:)
        @name = name
        @base_price = base_price
        @imported = imported
        @category = category
        freeze
      end

      def exempt?
        EXEMPT_CATEGORIES.include?(category)
      end
    end
  end
end
