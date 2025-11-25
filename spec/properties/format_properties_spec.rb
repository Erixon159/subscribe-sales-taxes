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

  describe 'End-to-End Calculation Accuracy' do
    it 'verifies receipt totals match sum of line items' do
      100.times do
        num_lines = rand(1..5)
        input_lines = num_lines.times.map do
          quantity = rand(1..10)
          categories = %i[book food medical other]
          category = categories.sample
          imported = [true, false].sample
          price = (rand(1..10_000) / 100.0).round(2)

          product_name = case category
                         when :book
                           imported ? 'imported book' : 'book'
                         when :food
                           imported ? 'imported box of chocolates' : 'chocolate bar'
                         when :medical
                           imported ? 'imported packet of pills' : 'packet of headache pills'
                         else
                           imported ? 'imported bottle of perfume' : 'bottle of perfume'
                         end

          "#{quantity} #{product_name} at #{format('%.2f', price)}"
        end

        # Process through the full pipeline
        receipt = SalesTaxes::Services::ReceiptBuilder.build_from_input(input_lines)
        line_items = receipt.line_items

        # Verify sum of line item totals equals receipt total
        expected_total = line_items.sum(&:total_price)
        expect(receipt.total).to be_within(0.01).of(expected_total)

        # Verify sum of line item taxes equals receipt total taxes
        expected_taxes = line_items.sum(&:tax_amount)
        expect(receipt.total_taxes).to be_within(0.01).of(expected_taxes)
      end
    end
  end
end
