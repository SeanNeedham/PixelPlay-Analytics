# Dataset


## Source files

- `orders.csv` — transactional orders, dates, prices, channels and refund information
- `customers.csv` — customer demographics, segments, loyalty tiers and email opt-in
- `products.csv` — product names, categories and pricing information
- `regions.csv` — country and regional classifications

The files in `raw/` have been retained in their original form.

Data profiling, cleaning and validation were completed in SQL Server. Cleaned outputs are not stored separately because they can be recreated using the scripts in the `/sql` folder
.