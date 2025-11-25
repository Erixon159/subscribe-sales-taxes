# frozen_string_literal: true

require 'bigdecimal'

module SalesTaxes
  module Services
    # Stateless service for calculating sales taxes with proper rounding
    #
    # Note: For a more complex domain (location-based taxes, dynamic rules,
    # tax combinations), this class can evolve into a set of TaxRule objects.
    # For this assignment's simplicity, a unified calculator avoids over-engineering.
    class TaxCalculator
      BASIC_TAX_RATE = BigDecimal('0.10')
      IMPORT_DUTY_RATE = BigDecimal('0.05')
      NICKEL = BigDecimal('0.05')

      def self.round_up_to_nearest_nickel(amount)
        amount_bd = BigDecimal(amount.to_s)
        (amount_bd / NICKEL).ceil * NICKEL
      end

      def self.calculate_basic_tax(product)
        return BigDecimal('0') if product.exempt?

        base_price_bd = BigDecimal(product.base_price.to_s)
        round_up_to_nearest_nickel(base_price_bd * BASIC_TAX_RATE)
      end

      def self.calculate_import_duty(product)
        return BigDecimal('0') unless product.imported

        base_price_bd = BigDecimal(product.base_price.to_s)
        round_up_to_nearest_nickel(base_price_bd * IMPORT_DUTY_RATE)
      end

      def self.calculate_total_tax(product)
        calculate_basic_tax(product) + calculate_import_duty(product)
      end

      def self.calculate_line_tax(product, quantity)
        calculate_total_tax(product) * quantity
      end
    end
  end
end
