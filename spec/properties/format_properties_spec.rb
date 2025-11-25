# frozen_string_literal: true

require 'spec_helper'
require 'sales_taxes'

RSpec.describe 'Format Properties' do
  describe 'Receipt Format Completeness' do
    it 'formats receipts with all required components' do
      100.times do
        # Generate random line items
        num_items = rand(1..5)
        line_items = num_items.times.map do
          categories = %i[book food medical other]
          product = SalesTaxes::Models::Product.new(
            name: "product_#{rand(1000)}",
            base_price: (rand(1..10_000) / 100.0).to_s,
            imported: [true, false].sample,
            category: categories.sample
          )

          SalesTaxes::Models::LineItem.new(
            product: product,
            quantity: rand(1..10),
            tax_amount: (rand(0..500) / 100.0),
            total_price: (rand(100..10_000) / 100.0)
          )
        end

        receipt = SalesTaxes::Models::Receipt.new(line_items: line_items)
        formatted = SalesTaxes::Services::Formatter.format(receipt)

        # Verify all line items are present
        line_items.each do |item|
          expect(formatted).to include(item.product.name)
          expect(formatted).to include(item.quantity.to_s)
        end

        # Verify all prices have exactly 2 decimal places
        prices = formatted.scan(/\d+\.\d+/)
        expect(prices).not_to be_empty
        prices.each do |price|
          expect(price).to match(/^\d+\.\d{2}$/)
        end

        # Verify "Sales Taxes:" line is present
        expect(formatted).to include('Sales Taxes:')

        # Verify "Total:" line is present
        expect(formatted).to include('Total:')

        # Verify the formatted output contains the correct number of lines
        # (num_items + 2 for Sales Taxes and Total)
        lines = formatted.split("\n")
        expect(lines.length).to eq(num_items + 2)
      end
    end
  end
end
