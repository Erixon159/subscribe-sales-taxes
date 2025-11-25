# frozen_string_literal: true

# Main module for the Sales Taxes application
module SalesTaxes
  # Main application entry point
  def self.process(input_lines)
    receipt = Services::ReceiptBuilder.build_from_input(input_lines)
    Services::Formatter.format(receipt)
  end
end

# Require all models
require_relative 'sales_taxes/models/product'
require_relative 'sales_taxes/models/line_item'
require_relative 'sales_taxes/models/receipt'

# Require all services
require_relative 'sales_taxes/services/tax_calculator'
require_relative 'sales_taxes/services/input_parser'
require_relative 'sales_taxes/services/formatter'
require_relative 'sales_taxes/services/receipt_builder'
