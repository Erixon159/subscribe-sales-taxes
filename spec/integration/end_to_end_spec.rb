# frozen_string_literal: true

require 'spec_helper'
require 'sales_taxes'

RSpec.describe 'End-to-End Integration' do
  describe 'Input 1' do
    it 'produces the correct output for the first example' do
      input_lines = [
        '2 book at 12.49',
        '1 music CD at 14.99',
        '1 chocolate bar at 0.85'
      ]

      output = SalesTaxes.process(input_lines)

      expected_output = <<~OUTPUT.strip
        2 book: 24.98
        1 music CD: 16.49
        1 chocolate bar: 0.85
        Sales Taxes: 1.50
        Total: 42.32
      OUTPUT

      expect(output).to eq(expected_output)
    end
  end

  describe 'Input 2' do
    it 'produces the correct output for the second example' do
      input_lines = [
        '1 imported box of chocolates at 10.00',
        '1 imported bottle of perfume at 47.50'
      ]

      output = SalesTaxes.process(input_lines)

      expected_output = <<~OUTPUT.strip
        1 imported box of chocolates: 10.50
        1 imported bottle of perfume: 54.65
        Sales Taxes: 7.65
        Total: 65.15
      OUTPUT

      expect(output).to eq(expected_output)
    end
  end

  describe 'Input 3' do
    it 'produces the correct output for the third example' do
      input_lines = [
        '1 imported bottle of perfume at 27.99',
        '1 bottle of perfume at 18.99',
        '1 packet of headache pills at 9.75',
        '3 imported boxes of chocolates at 11.25'
      ]

      output = SalesTaxes.process(input_lines)

      expected_output = <<~OUTPUT.strip
        1 imported bottle of perfume: 32.19
        1 bottle of perfume: 20.89
        1 packet of headache pills: 9.75
        3 imported boxes of chocolates: 35.55
        Sales Taxes: 7.90
        Total: 98.38
      OUTPUT

      expect(output).to eq(expected_output)
    end
  end

  describe 'File Input' do
    it 'reads and processes input from file 1' do
      input_lines = File.readlines('spec/fixtures/input1.txt')
      output = SalesTaxes.process(input_lines)

      expected_output = <<~OUTPUT.strip
        2 book: 24.98
        1 music CD: 16.49
        1 chocolate bar: 0.85
        Sales Taxes: 1.50
        Total: 42.32
      OUTPUT

      expect(output).to eq(expected_output)
    end

    it 'reads and processes input from file 2' do
      input_lines = File.readlines('spec/fixtures/input2.txt')
      output = SalesTaxes.process(input_lines)

      expected_output = <<~OUTPUT.strip
        1 imported box of chocolates: 10.50
        1 imported bottle of perfume: 54.65
        Sales Taxes: 7.65
        Total: 65.15
      OUTPUT

      expect(output).to eq(expected_output)
    end

    it 'reads and processes input from file 3' do
      input_lines = File.readlines('spec/fixtures/input3.txt')
      output = SalesTaxes.process(input_lines)

      expected_output = <<~OUTPUT.strip
        1 imported bottle of perfume: 32.19
        1 bottle of perfume: 20.89
        1 packet of headache pills: 9.75
        1 imported box of chocolates: 11.85
        Sales Taxes: 6.70
        Total: 74.68
      OUTPUT

      expect(output).to eq(expected_output)
    end
  end

  describe 'Invalid Input Handling' do
    it 'gracefully handles invalid input lines by skipping them' do
      input_lines = File.readlines('spec/fixtures/invalid_input.txt')
      output = SalesTaxes.process(input_lines)

      # Should only process the valid lines (2 book, 1 music CD, 1 chocolate bar)
      expected_output = <<~OUTPUT.strip
        2 book: 24.98
        1 music CD: 16.49
        1 chocolate bar: 0.85
        Sales Taxes: 1.50
        Total: 42.32
      OUTPUT

      expect(output).to eq(expected_output)
    end

    it 'handles empty input gracefully' do
      output = SalesTaxes.process([])

      expected_output = <<~OUTPUT.strip
        Sales Taxes: 0.00
        Total: 0.00
      OUTPUT

      expect(output).to eq(expected_output)
    end

    it 'handles input with only invalid lines' do
      input_lines = [
        'this is not valid',
        'neither is this',
        '',
        '   '
      ]
      output = SalesTaxes.process(input_lines)

      expected_output = <<~OUTPUT.strip
        Sales Taxes: 0.00
        Total: 0.00
      OUTPUT

      expect(output).to eq(expected_output)
    end
  end
end
