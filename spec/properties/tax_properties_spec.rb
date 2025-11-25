# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Tax Calculation Properties' do
  describe 'Exempt Products Have Zero Basic Tax' do
    it 'always returns zero basic tax for exempt products' do
      exempt_categories = %i[book food medical]

      100.times do
        category = exempt_categories.sample
        price = rand(0.01..1000.00)
        imported = [true, false].sample

        product = SalesTaxes::Models::Product.new(
          name: "test #{category}",
          base_price: price,
          imported: imported,
          category: category
        )

        basic_tax = SalesTaxes::Services::TaxCalculator.calculate_basic_tax(product)
        expect(basic_tax).to eq(0.0), "Expected 0 basic tax for #{category} at $#{price}, got #{basic_tax}"
      end
    end
  end

  describe 'Tax Percentages Are Correct' do
    it 'applies correct tax percentages for all product combinations' do
      categories = %i[book food medical other]

      100.times do
        category = categories.sample
        price = rand(0.01..1000.00)
        imported = [true, false].sample

        product = SalesTaxes::Models::Product.new(
          name: 'test product',
          base_price: price,
          imported: imported,
          category: category
        )

        basic_tax = SalesTaxes::Services::TaxCalculator.calculate_basic_tax(product)
        import_duty = SalesTaxes::Services::TaxCalculator.calculate_import_duty(product)

        # Verify basic tax is 10% (rounded) for non-exempt, 0 for exempt
        if product.exempt?
          expect(basic_tax).to eq(0.0)
        else
          expected_basic = BigDecimal(price.to_s) * BigDecimal('0.10')
          rounded_basic = SalesTaxes::Services::TaxCalculator.round_up_to_nearest_nickel(expected_basic)
          expect(basic_tax).to eq(rounded_basic.to_f)
        end

        # Verify import duty is 5% (rounded) for imported, 0 otherwise
        if imported
          expected_import = BigDecimal(price.to_s) * BigDecimal('0.05')
          rounded_import = SalesTaxes::Services::TaxCalculator.round_up_to_nearest_nickel(expected_import)
          expect(import_duty).to eq(rounded_import.to_f)
        else
          expect(import_duty).to eq(0.0)
        end
      end
    end
  end

  describe 'Individual Tax Component Rounding' do
    it 'rounds each tax component individually before summing' do
      100.times do
        price = rand(0.01..1000.00)

        # Create imported non-exempt product (has both taxes)
        product = SalesTaxes::Models::Product.new(
          name: 'imported perfume',
          base_price: price,
          imported: true,
          category: :other
        )

        basic_tax = SalesTaxes::Services::TaxCalculator.calculate_basic_tax(product)
        import_duty = SalesTaxes::Services::TaxCalculator.calculate_import_duty(product)
        total_tax = SalesTaxes::Services::TaxCalculator.calculate_total_tax(product)

        # Verify total equals sum of individually rounded components
        expect(total_tax).to eq(basic_tax + import_duty)

        # Verify each component is properly rounded to nearest 0.05
        basic_bd = BigDecimal(basic_tax.to_s)
        import_bd = BigDecimal(import_duty.to_s)
        expect((basic_bd / BigDecimal('0.05')) % 1).to eq(0)
        expect((import_bd / BigDecimal('0.05')) % 1).to eq(0)
      end
    end
  end
end
