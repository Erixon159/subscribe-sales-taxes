# Sales Taxes Calculator

A Ruby command-line application that calculates sales taxes for retail purchases and generates formatted receipts.

## Overview

This application applies two types of taxes:
- **Basic Sales Tax**: 10% on all goods except books, food, and medical products
- **Import Duty**: 5% on all imported goods

Tax amounts are rounded up to the nearest $0.05, and each tax component is rounded individually before summing.

## Requirements

**Option 1: With Docker (Recommended)**
- Docker and Docker Compose

**Option 2: Without Docker**
- Ruby 3.4
- Bundler

## Quick Start

### Option 1: Using Docker

**Build the Docker Image:**
```bash
docker-compose build
```

**Run the Application:**

*Interactive Mode:*
```bash
docker-compose run --rm app
```

Enter items one per line in the format: `quantity product_name at price`

Press Enter on an empty line to finish and see the receipt.

*From a File:*
```bash
docker-compose run --rm app ruby bin/sales_taxes spec/fixtures/input1.txt
```

*Piped Input:*
```bash
echo -e "2 book at 12.49\n1 music CD at 14.99\n1 chocolate bar at 0.85\n" | docker-compose run --rm app ruby bin/sales_taxes
```

### Option 2: Without Docker

**Install Dependencies:**
```bash
bundle install
```

**Run the Application:**

*Interactive Mode:*
```bash
ruby bin/sales_taxes
```

*From a File:*
```bash
ruby bin/sales_taxes spec/fixtures/input1.txt
```

*Piped Input:*
```bash
echo -e "2 book at 12.49\n1 music CD at 14.99\n1 chocolate bar at 0.85\n" | ruby bin/sales_taxes
```

## Example

**Input:**
```
2 book at 12.49
1 music CD at 14.99
1 chocolate bar at 0.85
```

**Output:**
```
2 book: 24.98
1 music CD: 16.49
1 chocolate bar: 0.85
Sales Taxes: 1.50
Total: 42.32
```

## Running Tests

### With Docker

**All Tests:**
```bash
docker-compose run --rm app rspec
```

**Specific Test Suite:**
```bash
docker-compose run --rm app rspec spec/integration/
docker-compose run --rm app rspec spec/properties/
docker-compose run --rm app rspec spec/sales_taxes/
```

### Without Docker

**All Tests:**
```bash
bundle exec rspec
```

**Specific Test Suite:**
```bash
bundle exec rspec spec/integration/
bundle exec rspec spec/properties/
bundle exec rspec spec/sales_taxes/
```

**Test Coverage:**
- 77 total tests
- Unit tests for all models and services
- Property-based tests (100+ iterations each)
- Integration tests with valid and invalid inputs

## Code Quality

### With Docker

**Run Rubocop:**
```bash
docker-compose run --rm app rubocop
```

**Auto-fix Issues:**
```bash
docker-compose run --rm app rubocop -A
```

### Without Docker

**Run Rubocop:**
```bash
bundle exec rubocop
```

**Auto-fix Issues:**
```bash
bundle exec rubocop -A
```

## Architecture

The application follows clean architecture principles with clear separation of concerns:

### Models
- **Product**: Immutable value object representing a purchasable item
- **LineItem**: Receipt line with product, quantity, taxes, and total
- **Receipt**: Aggregates line items with tax and total calculations

### Services
- **InputParser**: Parses text input into structured data
- **TaxCalculator**: Calculates taxes with proper rounding (uses BigDecimal for precision)
- **ReceiptBuilder**: Orchestrates parsing, tax calculation, and line item creation
- **Formatter**: Converts receipts to formatted output

### Design Decisions
- **BigDecimal throughout**: Avoids floating-point precision errors
- **Immutable models**: Thread-safe value objects
- **Stateless services**: Pure functions for predictability
- **String price storage**: Preserves precision until calculation

## Project Structure

```
.
├── bin/
│   └── sales_taxes          # CLI entry point
├── lib/
│   ├── sales_taxes.rb       # Main module with process() method
│   └── sales_taxes/
│       ├── models/          # Domain objects
│       │   ├── product.rb
│       │   ├── line_item.rb
│       │   └── receipt.rb
│       └── services/        # Business logic
│           ├── input_parser.rb
│           ├── tax_calculator.rb
│           ├── receipt_builder.rb
│           └── formatter.rb
├── spec/
│   ├── fixtures/            # Test input files
│   ├── integration/         # End-to-end tests
│   ├── properties/          # Property-based tests
│   └── sales_taxes/         # Unit tests
├── Dockerfile
├── docker-compose.yml
└── README.md
```

## Development

The project uses:
- **RSpec** for testing
- **Rubocop** for code quality
- **BigDecimal** for precise decimal arithmetic
- **Docker** for consistent environment

## Testing Philosophy

The application uses three complementary testing approaches:

1. **Unit Tests**: Verify specific examples and edge cases
2. **Property-Based Tests**: Verify universal rules across random inputs (100+ iterations)
3. **Integration Tests**: Verify complete end-to-end flow with known examples

This provides comprehensive coverage: unit tests catch concrete bugs, property tests verify general correctness, and integration tests ensure the system works end-to-end.

## License

This is a coding exercise project.
