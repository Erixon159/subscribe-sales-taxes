# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SalesTaxes::Models::Product do
  describe '#exempt?' do
    it 'returns true for books' do
      product = described_class.new(name: 'book', base_price: 12.49, imported: false, category: :book)
      expect(product.exempt?).to be true
    end

    it 'returns true for food' do
      product = described_class.new(name: 'chocolate', base_price: 0.85, imported: false, category: :food)
      expect(product.exempt?).to be true
    end

    it 'returns true for medical products' do
      product = described_class.new(name: 'pills', base_price: 9.75, imported: false, category: :medical)
      expect(product.exempt?).to be true
    end

    it 'returns false for other categories' do
      product = described_class.new(name: 'perfume', base_price: 18.99, imported: false, category: :other)
      expect(product.exempt?).to be false
    end
  end

  describe 'immutability' do
    let(:product) { described_class.new(name: 'book', base_price: 12.49, imported: false, category: :book) }

    it 'freezes the product instance' do
      expect(product).to be_frozen
    end

    it 'does not allow modification of attributes' do
      expect { product.instance_variable_set(:@base_price, 99.99) }.to raise_error(FrozenError)
    end
  end
end
