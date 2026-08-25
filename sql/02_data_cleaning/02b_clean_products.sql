/*
pixelplay gaming analytics
products data cleaning

clean and standardise product data before modelling
*/
-- standardise product fields
WITH   cleaned_products
AS     (SELECT CASE WHEN LOWER(TRIM(PRODUCT_ID)) = '8d0d' THEN 'e682' ELSE NULLIF (LOWER(TRIM(PRODUCT_ID)), '') END AS product_id,
               CASE WHEN LOWER(TRIM(PRODUCT_NAME)) IN ('sony playstation 5 bundle', 'sony ps5 bundle') THEN 'Sony PlayStation 5 Bundle' WHEN LOWER(TRIM(PRODUCT_NAME)) IN ('27in 4k gaming monitor', '27inches 4k gaming monitor', '27" 4k gaming monitor') THEN '27in 4K Gaming Monitor' ELSE TRIM(PRODUCT_NAME) END AS product_name,
               TRIM(PRODUCT_CATEGORY) AS product_category,
               CAST (BASE_PRICE_GBP AS DECIMAL (10, 2)) AS base_price_gbp,
               CAST (NULLIF (TRIM(LAUNCH_YEAR), '') AS INT) AS launch_year,
               NULLIF (TRIM(NOTES), '') AS notes
        FROM   products),
-- rank duplicate product records
       ranked_products
AS     (SELECT product_id,
               product_name,
               product_category,
               base_price_gbp,
               launch_year,
               notes,
               ROW_NUMBER() OVER (PARTITION BY product_id ORDER BY CASE WHEN LOWER(COALESCE (notes, '')) LIKE '%legacy%'
                                                                             OR LOWER(COALESCE (notes, '')) LIKE '%variant%' THEN 1 ELSE 0 END, CASE WHEN product_id IS NULL THEN 1 ELSE 0 END, CASE WHEN base_price_gbp IS NULL THEN 1 ELSE 0 END, CASE WHEN launch_year IS NULL THEN 1 ELSE 0 END) AS row_number
        FROM   cleaned_products
        -- exclude records without a usable product id
        WHERE  product_id IS NOT NULL)
SELECT -- create final cleaned product table
       product_id,
       product_name,
       product_category,
       base_price_gbp,
       launch_year,
       notes,
       -- data quality status
       CASE WHEN product_name IS NULL THEN 'Missing Product Name' WHEN base_price_gbp IS NULL THEN 'Missing Base Price' WHEN launch_year IS NULL THEN 'Missing Launch Year' ELSE 'Complete' END AS data_quality_status
INTO   products_clean
FROM   ranked_products
WHERE  row_number = 1;