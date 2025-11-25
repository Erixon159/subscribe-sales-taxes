# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SalesTaxes::Models::LineItem do
  let(:product) do
    SalesTaxes::Models::Product.new(
      name: 'book',
      base_price: 12.49,
      imported: false,
      category: :book
    )
  end

  describe 'attribute storage' do
    let(:line_item) do
      described_class.new(
        product: product,
        quantity: 2,
        tax_amount: 0.00,
        total_price: 24.98
      )
    end

    it 'stores the product' do
      expect(line_item.product).to eq(product)
    end

    it 'stores the quantity' do
      expect(line_item.quantity).to eq(2)
    end

    it 'stores the tax amount' do
      expect(line_item.tax_amount).to eq(0.00)
    end

    it 'stores the total price' do
      expect(line_item.total_price).to eq(24.98)
    end
  end

  describe 'immutability' do
    let(:line_item) do
      described_class.new(
        product: product,
        quantity: 1,
        tax_amount: 1.50,
        total_price: 16.49
      )
    end

    it 'freezes the line item instance' do
      expect(line_item).to be_frozen
    end

    it 'does not allow modification of attributes' do
      expect { line_item.instance_variable_set(:@quantity, 99) }.to raise_error(FrozenError)
    end
  end
end
