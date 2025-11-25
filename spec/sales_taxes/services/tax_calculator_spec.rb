# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SalesTaxes::Services::TaxCalculator do
  let(:exempt_product) do
    SalesTaxes::Models::Product.new(
      name: 'book',
      base_price: 12.49,
      imported: false,
      category: :book
    )
  end

  let(:non_exempt_product) do
    SalesTaxes::Models::Product.new(
      name: 'music CD',
      base_price: 14.99,
      imported: false,
      category: :other
    )
  end

  let(:imported_exempt_product) do
    SalesTaxes::Models::Product.new(
      name: 'imported box of chocolates',
      base_price: 10.00,
      imported: true,
      category: :food
    )
  end

  let(:imported_non_exempt_product) do
    SalesTaxes::Models::Product.new(
      name: 'imported bottle of perfume',
      base_price: 47.50,
      imported: true,
      category: :other
    )
  end

  describe '.calculate_basic_tax' do
    it 'returns 0 for exempt products' do
      tax = described_class.calculate_basic_tax(exempt_product)
      expect(tax).to eq(0.0)
    end

    it 'calculates 10% tax for non-exempt products' do
      # 14.99 * 0.10 = 1.499, rounds up to 1.50
      tax = described_class.calculate_basic_tax(non_exempt_product)
      expect(tax).to eq(1.50)
    end

    it 'returns 0 for imported exempt products' do
      tax = described_class.calculate_basic_tax(imported_exempt_product)
      expect(tax).to eq(0.0)
    end

    it 'calculates 10% tax for imported non-exempt products' do
      # 47.50 * 0.10 = 4.75, already rounded
      tax = described_class.calculate_basic_tax(imported_non_exempt_product)
      expect(tax).to eq(4.75)
    end
  end

  describe '.calculate_import_duty' do
    it 'returns 0 for non-imported products' do
      duty = described_class.calculate_import_duty(exempt_product)
      expect(duty).to eq(0.0)
    end

    it 'calculates 5% duty for imported exempt products' do
      # 10.00 * 0.05 = 0.50, already rounded
      duty = described_class.calculate_import_duty(imported_exempt_product)
      expect(duty).to eq(0.50)
    end

    it 'calculates 5% duty for imported non-exempt products' do
      # 47.50 * 0.05 = 2.375, rounds up to 2.40
      duty = described_class.calculate_import_duty(imported_non_exempt_product)
      expect(duty).to eq(2.40)
    end
  end

  describe '.calculate_tax' do
    it 'returns 0 for exempt non-imported products' do
      tax = described_class.calculate_tax(exempt_product)
      expect(tax).to eq(0.0)
    end

    it 'returns basic tax for non-exempt non-imported products' do
      tax = described_class.calculate_tax(non_exempt_product)
      expect(tax).to eq(1.50)
    end

    it 'returns import duty for exempt imported products' do
      tax = described_class.calculate_tax(imported_exempt_product)
      expect(tax).to eq(0.50)
    end

    it 'returns both taxes for non-exempt imported products' do
      # Basic: 47.50 * 0.10 = 4.75
      # Import: 47.50 * 0.05 = 2.375 → 2.40
      # Total: 4.75 + 2.40 = 7.15
      tax = described_class.calculate_tax(imported_non_exempt_product)
      expect(tax).to eq(7.15)
    end
  end

  describe '.calculate_line_tax' do
    it 'multiplies product tax by quantity' do
      # Product tax: 1.50
      # Quantity: 2
      # Line tax: 3.00
      line_tax = described_class.calculate_line_tax(non_exempt_product, 2)
      expect(line_tax).to eq(3.00)
    end

    it 'handles quantity of 1' do
      line_tax = described_class.calculate_line_tax(non_exempt_product, 1)
      expect(line_tax).to eq(1.50)
    end
  end

  describe 'edge cases' do
    let(:zero_price_product) do
      SalesTaxes::Models::Product.new(name: 'free item', base_price: 0.0, imported: false, category: :other)
    end

    let(:expensive_product) do
      SalesTaxes::Models::Product.new(name: 'expensive item', base_price: 1000.00, imported: true, category: :other)
    end

    it 'handles zero price' do
      tax = described_class.calculate_tax(zero_price_product)
      expect(tax).to eq(0.0)
    end

    it 'handles large prices' do
      # Basic: 1000 * 0.10 = 100.00
      # Import: 1000 * 0.05 = 50.00
      # Total: 150.00
      tax = described_class.calculate_tax(expensive_product)
      expect(tax).to eq(150.00)
    end
  end
end
