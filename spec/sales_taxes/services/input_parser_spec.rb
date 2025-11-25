# frozen_string_literal: true

require 'spec_helper'
require 'sales_taxes'

RSpec.describe SalesTaxes::Services::InputParser do
  describe '.parse_line' do
    context 'with standard format' do
      it 'parses a simple book' do
        result = described_class.parse_line('1 book at 12.49')

        expect(result).to eq(
          quantity: 1,
          name: 'book',
          price: '12.49',
          imported: false,
          category: :book
        )
      end

      it 'parses a music CD' do
        result = described_class.parse_line('1 music CD at 14.99')

        expect(result).to eq(
          quantity: 1,
          name: 'music CD',
          price: '14.99',
          imported: false,
          category: :other
        )
      end

      it 'parses a chocolate bar' do
        result = described_class.parse_line('1 chocolate bar at 0.85')

        expect(result).to eq(
          quantity: 1,
          name: 'chocolate bar',
          price: '0.85',
          imported: false,
          category: :food
        )
      end
    end

    context 'with "at" in product name' do
      it 'finds the last occurrence of " at "' do
        result = described_class.parse_line('1 item at the store at 10.00')

        expect(result).to eq(
          quantity: 1,
          name: 'item at the store',
          price: '10.00',
          imported: false,
          category: :other
        )
      end
    end

    context 'with imported products' do
      it 'detects imported box of chocolates' do
        result = described_class.parse_line('1 imported box of chocolates at 10.00')

        expect(result).to eq(
          quantity: 1,
          name: 'imported box of chocolates',
          price: '10.00',
          imported: true,
          category: :food
        )
      end

      it 'detects imported bottle of perfume' do
        result = described_class.parse_line('1 imported bottle of perfume at 47.50')

        expect(result).to eq(
          quantity: 1,
          name: 'imported bottle of perfume',
          price: '47.50',
          imported: true,
          category: :other
        )
      end

      it 'does not detect "imported" in the middle of product name' do
        result = described_class.parse_line('1 book about imported goods at 15.00')

        expect(result).to eq(
          quantity: 1,
          name: 'book about imported goods',
          price: '15.00',
          imported: false,
          category: :book
        )
      end
    end

    context 'with category detection' do
      it 'detects books' do
        result = described_class.parse_line('2 book at 12.49')
        expect(result[:category]).to eq(:book)
      end

      it 'detects food (chocolate)' do
        result = described_class.parse_line('1 chocolate bar at 0.85')
        expect(result[:category]).to eq(:food)
      end

      it 'detects food (chocolates)' do
        result = described_class.parse_line('1 box of chocolates at 10.00')
        expect(result[:category]).to eq(:food)
      end

      it 'detects medical (pills)' do
        result = described_class.parse_line('1 packet of headache pills at 9.75')
        expect(result[:category]).to eq(:medical)
      end

      it 'defaults to other for perfume' do
        result = described_class.parse_line('1 bottle of perfume at 18.99')
        expect(result[:category]).to eq(:other)
      end
    end

    context 'with malformed input' do
      it 'returns nil for empty string' do
        result = described_class.parse_line('')
        expect(result).to be_nil
      end

      it 'returns nil for nil input' do
        result = described_class.parse_line(nil)
        expect(result).to be_nil
      end

      it 'returns nil for missing price' do
        result = described_class.parse_line('1 book')
        expect(result).to be_nil
      end

      it 'returns nil for missing " at "' do
        result = described_class.parse_line('1 book 12.49')
        expect(result).to be_nil
      end

      it 'returns nil for invalid price format' do
        result = described_class.parse_line('1 book at abc')
        expect(result).to be_nil
      end

      it 'returns nil for missing quantity' do
        result = described_class.parse_line('book at 12.49')
        expect(result).to be_nil
      end
    end

    context 'with quantities greater than 1' do
      it 'parses quantity correctly' do
        result = described_class.parse_line('2 book at 12.49')
        expect(result[:quantity]).to eq(2)
      end

      it 'parses large quantities' do
        result = described_class.parse_line('100 chocolate bar at 0.85')
        expect(result[:quantity]).to eq(100)
      end
    end
  end
end
