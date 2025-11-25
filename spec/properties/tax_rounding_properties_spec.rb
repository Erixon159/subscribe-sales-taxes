# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Tax Rounding Properties' do
  # Feature: sales-taxes, Property 5: Tax Rounding Always Rounds Up
  # Validates: Requirements 2.3, 3.3, 4.1
  describe 'Property 5: Tax Rounding Always Rounds Up' do
    it 'always rounds up to the nearest 0.05 for random tax amounts' do
      # Generate 100 random tax amounts between 0.01 and 100.00
      100.times do
        amount = rand(0.01..100.00)
        rounded = SalesTaxes::Services::TaxCalculator.round_up_to_nearest_nickel(amount)

        # Verify it's a multiple of 0.05
        expect((rounded / BigDecimal('0.05')) % 1).to eq(0)

        # Verify it rounds up (rounded >= original)
        expect(rounded).to be >= BigDecimal(amount.to_s)

        # Verify it's the nearest 0.05 (not more than 0.05 away)
        expect(rounded - BigDecimal(amount.to_s)).to be < BigDecimal('0.05')
      end
    end

    it 'handles edge cases correctly' do
      # Already rounded amounts stay the same
      expect(SalesTaxes::Services::TaxCalculator.round_up_to_nearest_nickel(0.05)).to eq(BigDecimal('0.05'))
      expect(SalesTaxes::Services::TaxCalculator.round_up_to_nearest_nickel(0.10)).to eq(BigDecimal('0.10'))
      expect(SalesTaxes::Services::TaxCalculator.round_up_to_nearest_nickel(1.00)).to eq(BigDecimal('1.00'))

      # Amounts just above round up
      expect(SalesTaxes::Services::TaxCalculator.round_up_to_nearest_nickel(0.01)).to eq(BigDecimal('0.05'))
      expect(SalesTaxes::Services::TaxCalculator.round_up_to_nearest_nickel(0.5625)).to eq(BigDecimal('0.60'))
      expect(SalesTaxes::Services::TaxCalculator.round_up_to_nearest_nickel(0.99)).to eq(BigDecimal('1.00'))
    end
  end
end
