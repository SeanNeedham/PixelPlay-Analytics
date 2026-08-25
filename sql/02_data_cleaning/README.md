# Data Cleaning

The raw PixelPlay datasets were cleaned and standardised in SQL Server before being used to build the reporting model.

The original source tables were retained unchanged. Each script creates a separate cleaned table that is used by later stages of the project.

## Run Order

1. `02a_clean_regions.sql`
2. `02b_clean_products.sql`
3. `02c_clean_customers.sql`
4. `02d_clean_orders.sql`

## Cleaned Tables Created

- `region_clean`
- `products_clean`
- `customers_clean`
- `orders_clean`

## Cleaning Approach

The scripts cover:

- standardising categorical values
- validating and converting dates
- handling invalid or missing values
- identifying invalid date sequences
- standardising customer and product information
- matching records across source tables
- creating analysis eligibility and data-quality flags
- deduplicating records where required

Records were retained where they remained useful for analysis rather than automatically deleting every incomplete row.

Post-cleaning checks are available in:

`03_post_cleaning_validation.sql`