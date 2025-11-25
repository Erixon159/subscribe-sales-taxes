# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SalesTaxes::Models::Receipt do
  let(:book_product) do
    SalesTaxes::Models::Product.new(
      name: 'book',
      base_price: 12.49,
      imported: false,
      category: :book
    )
  end

  let(:cd_product) do
    SalesTaxes::Models::Product.new(
      name: 'music CD',
      base_price: 14.99,
      imported: false,
      category: :other
    )
  end

  let(:book_line_item) do
    SalesTaxes::Models::LineItem.new(
      product: book_product,
      quantity: 2,
      tax_amount: 0.00,
      total_price: 24.98
    )
  end

  let(:cd_line_item) do
    SalesTaxes::Models::LineItem.new(
      product: cd_product,
      quantity: 1,
      tax_amount: 1.50,
      total_price: 16.49
    )
  end

  describe '#total_taxes' do
    it 'returns the sum of all line item tax amounts' do
      receipt = described_class.new(line_items: [book_line_item, cd_line_item])
      expect(receipt.total_taxes).to eq(1.50)
    end

    it 'returns 0 for empty receipt' do
      receipt = described_class.new(line_items: [])
      expect(receipt.total_taxes).to eq(0)
    end
  end

  describe '#total' do
    it 'returns the sum of all line item total prices' do
      receipt = described_class.new(line_items: [book_line_item, cd_line_item])
      expect(receipt.total).to eq(41.47)
    end

    it 'returns 0 for empty receipt' do
      receipt = described_class.new(line_items: [])
      expect(receipt.total).to eq(0)
    end
  end
end
