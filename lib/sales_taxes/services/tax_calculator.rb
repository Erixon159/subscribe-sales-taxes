# frozen_string_literal: true

require 'bigdecimal'

module SalesTaxes
  module Services
    # Stateless service for calculating sales taxes with proper rounding
    #
    # Uses BigDecimal for precise decimal arithmetic to avoid floating point errors.
    #
    # Note: For a more complex domain (location-based taxes, dynamic rules,
    # tax combinations), this class can evolve into a set of TaxRule objects.
    # For this assignment's simplicity, a unified calculator avoids over-engineering.
    class TaxCalculator
      BASIC_TAX_RATE = BigDecimal('0.10')
      IMPORT_DUTY_RATE = BigDecimal('0.05')
      NICKEL = BigDecimal('0.05')

      # Rounds tax amount up to the nearest 0.05
      # Examples: 0.5625 → 0.60, 0.01 → 0.05, 0.05 → 0.05
      def self.round_up_to_nearest_nickel(amount)
        amount_bd = BigDecimal(amount.to_s)
        (amount_bd / NICKEL).ceil * NICKEL
      end

      # Calculates basic sales tax (10% for non-exempt products)
      def self.calculate_basic_tax(product)
        return BigDecimal('0') if product.exempt?

        base_price_bd = BigDecimal(product.base_price.to_s)
        round_up_to_nearest_nickel(base_price_bd * BASIC_TAX_RATE)
      end

      # Calculates import duty (5% for imported products)
      def self.calculate_import_duty(product)
        return BigDecimal('0') unless product.imported

        base_price_bd = BigDecimal(product.base_price.to_s)
        round_up_to_nearest_nickel(base_price_bd * IMPORT_DUTY_RATE)
      end

      # Calculates total tax for a product (rounds each component individually)
      def self.calculate_total_tax(product)
        calculate_basic_tax(product) + calculate_import_duty(product)
      end

      # Calculates total tax for a line item (product tax * quantity)
      def self.calculate_line_tax(product, quantity)
        calculate_total_tax(product) * quantity
      end
    end
  end
end
