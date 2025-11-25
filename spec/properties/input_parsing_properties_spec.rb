# frozen_string_literal: true

require 'spec_helper'
require 'sales_taxes'

RSpec.describe 'Input Parsing Properties' do
  describe 'Input Parsing Completeness' do
    it 'extracts all five components from valid input lines' do
      100.times do
        # Generate random valid input
        quantity = rand(1..100)
        categories = %i[book food medical other]
        category = categories.sample
        imported = [true, false].sample
        price = (rand(1..10_000) / 100.0).round(2)

        # Generate product name based on category
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

        input_line = "#{quantity} #{product_name} at #{format('%.2f', price)}"
        result = SalesTaxes::Services::InputParser.parse_line(input_line)

        # Verify all five components are extracted
        expect(result).not_to be_nil
        expect(result[:quantity]).to eq(quantity)
        expect(result[:name]).to eq(product_name)
        expect(result[:price]).to eq(format('%.2f', price))
        expect(result[:imported]).to eq(imported)
        expect(result[:category]).to be_a(Symbol)
        expect(%i[book food medical other]).to include(result[:category])
      end
    end
  end

  describe 'Invalid Input Resilience' do
    it 'handles invalid inputs gracefully without crashing' do
      100.times do
        # Generate various types of invalid input
        invalid_input = case rand(0..6)
                        when 0
                          ''
                        when 1
                          '   ' # Whitespace only
                        when 2
                          'book at 12.49' # Missing quantity
                        when 3
                          '1 book 12.49' # Missing "at"
                        when 4
                          '1 book at' # Missing price
                        when 5
                          '1 book at abc' # Invalid price
                        when 6
                          'random text without structure'
                        end

        # Parse should not crash and should return nil
        expect { SalesTaxes::Services::InputParser.parse_line(invalid_input) }.not_to raise_error
        result = SalesTaxes::Services::InputParser.parse_line(invalid_input)
        expect(result).to be_nil
      end
    end
  end
end
