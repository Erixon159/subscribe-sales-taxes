# frozen_string_literal: true

require 'spec_helper'
require 'sales_taxes'

RSpec.describe SalesTaxes::Services::Formatter do
  describe '.format' do
    let(:product1) do
      SalesTaxes::Models::Product.new(
        name: 'book',
        base_price: '12.49',
        imported: false,
        category: :book
      )
    end

    let(:product2) do
      SalesTaxes::Models::Product.new(
        name: 'music CD',
        base_price: '14.99',
        imported: false,
        category: :other
      )
    end

    let(:line_item1) do
      SalesTaxes::Models::LineItem.new(
        product: product1,
        quantity: 2,
        tax_amount: 0.0,
        total_price: 24.98
      )
    end

    let(:line_item2) do
      SalesTaxes::Models::LineItem.new(
        product: product2,
        quantity: 1,
        tax_amount: 1.50,
        total_price: 16.49
      )
    end

    let(:receipt) do
      SalesTaxes::Models::Receipt.new(line_items: [line_item1, line_item2])
    end

    it 'formats line items with quantity, name, and price' do
      result = described_class.format(receipt)

      expect(result).to include('2 book: 24.98')
      expect(result).to include('1 music CD: 16.49')
    end

    it 'formats all prices with exactly 2 decimal places' do
      result = described_class.format(receipt)

      # Check that all prices have 2 decimal places
      prices = result.scan(/\d+\.\d+/)
      expect(prices).to all(match(/\d+\.\d{2}/))
    end

    it 'includes Sales Taxes line with correct total' do
      result = described_class.format(receipt)

      expect(result).to include('Sales Taxes: 1.50')
    end

    it 'includes Total line with correct grand total' do
      result = described_class.format(receipt)

      expect(result).to include('Total: 41.47')
    end

    it 'matches the complete expected format' do
      result = described_class.format(receipt)

      expected = <<~RECEIPT.strip
        2 book: 24.98
        1 music CD: 16.49
        Sales Taxes: 1.50
        Total: 41.47
      RECEIPT

      expect(result).to eq(expected)
    end

    context 'with single line item' do
      let(:single_receipt) do
        SalesTaxes::Models::Receipt.new(line_items: [line_item1])
      end

      it 'formats correctly' do
        result = described_class.format(single_receipt)

        expected = <<~RECEIPT.strip
          2 book: 24.98
          Sales Taxes: 0.00
          Total: 24.98
        RECEIPT

        expect(result).to eq(expected)
      end
    end

    context 'with prices requiring rounding in display' do
      let(:product3) do
        SalesTaxes::Models::Product.new(
          name: 'chocolate bar',
          base_price: '0.85',
          imported: false,
          category: :food
        )
      end

      let(:line_item3) do
        SalesTaxes::Models::LineItem.new(
          product: product3,
          quantity: 1,
          tax_amount: 0.0,
          total_price: 0.85
        )
      end

      let(:receipt_with_cents) do
        SalesTaxes::Models::Receipt.new(line_items: [line_item3])
      end

      it 'displays prices with 2 decimal places' do
        result = described_class.format(receipt_with_cents)

        expect(result).to include('1 chocolate bar: 0.85')
        expect(result).to include('Sales Taxes: 0.00')
        expect(result).to include('Total: 0.85')
      end
    end
  end

  describe '.format_line_item' do
    let(:product) do
      SalesTaxes::Models::Product.new(
        name: 'imported bottle of perfume',
        base_price: '27.99',
        imported: true,
        category: :other
      )
    end

    let(:line_item) do
      SalesTaxes::Models::LineItem.new(
        product: product,
        quantity: 1,
        tax_amount: 4.20,
        total_price: 32.19
      )
    end

    it 'formats with quantity, name, and total price' do
      result = described_class.format_line_item(line_item)

      expect(result).to eq('1 imported bottle of perfume: 32.19')
    end
  end

  describe '.format_price' do
    it 'formats with exactly 2 decimal places' do
      expect(described_class.format_price(10.5)).to eq('10.50')
      expect(described_class.format_price(10.00)).to eq('10.00')
      expect(described_class.format_price(10.123)).to eq('10.12')
      expect(described_class.format_price(0.85)).to eq('0.85')
    end
  end
end
