/*
pixelplay gaming data profiling

profile the source tables before cleaning
*/


-- check table structure
SELECT
    TABLE_NAME,
    ORDINAL_POSITION,
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME IN ('orders', 'customer_info', 'products', 'region')
ORDER BY TABLE_NAME, ORDINAL_POSITION;


-- check row counts
SELECT
    'orders' AS table_name,
    COUNT(*) AS row_count
FROM orders

UNION ALL

SELECT
    'customer_info',
    COUNT(*)
FROM customer_info

UNION ALL

SELECT
    'products',
    COUNT(*)
FROM products

UNION ALL

SELECT
    'region',
    COUNT(*)
FROM region;



-- check missing order values
SELECT
    COUNT(*) AS total_rows,

    SUM(
        CASE
            WHEN order_id IS NULL
              OR TRIM(CAST(order_id AS VARCHAR(100))) = ''
            THEN 1
            ELSE 0
        END
    ) AS missing_order_id,

    SUM(
        CASE
            WHEN user_id IS NULL
              OR TRIM(CAST(user_id AS VARCHAR(100))) = ''
            THEN 1
            ELSE 0
        END
    ) AS missing_user_id,

    SUM(
        CASE
            WHEN product_id IS NULL
              OR TRIM(CAST(product_id AS VARCHAR(100))) = ''
            THEN 1
            ELSE 0
        END
    ) AS missing_product_id,

    SUM(
        CASE
            WHEN purchase_ts IS NULL
              OR TRIM(CAST(purchase_ts AS VARCHAR(100))) = ''
            THEN 1
            ELSE 0
        END
    ) AS missing_purchase_ts,

    SUM(
        CASE
            WHEN GBP_PRICE IS NULL
              OR TRIM(CAST(GBP_PRICE AS VARCHAR(100))) = ''
            THEN 1
            ELSE 0
        END
    ) AS missing_price

FROM orders;



-- check duplicate order ids
SELECT
    order_id,
    COUNT(*) AS row_count
FROM orders
WHERE order_id IS NOT NULL
  AND TRIM(CAST(order_id AS VARCHAR(100))) <> ''
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY row_count DESC, order_id;


-- count duplicate order ids
WITH duplicate_orders
AS
(
    SELECT
        order_id,
        COUNT(*) AS row_count
    FROM orders
    WHERE order_id IS NOT NULL
      AND TRIM(CAST(order_id AS VARCHAR(100))) <> ''
    GROUP BY order_id
    HAVING COUNT(*) > 1
)

SELECT
    COUNT(*) AS duplicated_order_ids,
    SUM(row_count) AS rows_using_duplicated_order_ids
FROM duplicate_orders;




-- check price quality
SELECT
    COUNT(*) AS total_rows,

    SUM(
        CASE
            WHEN GBP_PRICE IS NULL
              OR TRIM(CAST(GBP_PRICE AS VARCHAR(100))) = ''
            THEN 1
            ELSE 0
        END
    ) AS missing_price,

    SUM(
        CASE
            WHEN GBP_PRICE IS NOT NULL
             AND TRIM(CAST(GBP_PRICE AS VARCHAR(100))) <> ''
             AND TRY_CAST(GBP_PRICE AS DECIMAL(18, 2)) IS NULL
            THEN 1
            ELSE 0
        END
    ) AS invalid_price,

    SUM(
        CASE
            WHEN TRY_CAST(GBP_PRICE AS DECIMAL(18, 2)) < 0
            THEN 1
            ELSE 0
        END
    ) AS negative_price,

    SUM(
        CASE
            WHEN TRY_CAST(GBP_PRICE AS DECIMAL(18, 2)) = 0
            THEN 1
            ELSE 0
        END
    ) AS zero_price,

    SUM(
        CASE
            WHEN TRY_CAST(GBP_PRICE AS DECIMAL(18, 2)) > 0
            THEN 1
            ELSE 0
        END
    ) AS positive_price

FROM orders;




-- check date quality
WITH parsed_dates
AS
(
    SELECT
        order_id,

        COALESCE(
            TRY_CONVERT(DATETIME2(0), purchase_ts, 126),
            TRY_CONVERT(DATETIME2(0), purchase_ts, 120),
            TRY_CONVERT(DATETIME2(0), purchase_ts, 101),
            TRY_CONVERT(DATETIME2(0), purchase_ts, 103)
        ) AS purchase_date_parsed,

        COALESCE(
            TRY_CONVERT(DATETIME2(0), ship_ts, 126),
            TRY_CONVERT(DATETIME2(0), ship_ts, 120),
            TRY_CONVERT(DATETIME2(0), ship_ts, 101),
            TRY_CONVERT(DATETIME2(0), ship_ts, 103)
        ) AS ship_date_parsed,

        COALESCE(
            TRY_CONVERT(DATETIME2(0), refund_ts, 126),
            TRY_CONVERT(DATETIME2(0), refund_ts, 120),
            TRY_CONVERT(DATETIME2(0), refund_ts, 101),
            TRY_CONVERT(DATETIME2(0), refund_ts, 103)
        ) AS refund_date_parsed,

        purchase_ts,
        ship_ts,
        refund_ts

    FROM orders
)

SELECT
    COUNT(*) AS total_rows,

    SUM(
        CASE
            WHEN purchase_ts IS NULL
              OR TRIM(CAST(purchase_ts AS VARCHAR(100))) = ''
            THEN 1
            ELSE 0
        END
    ) AS missing_purchase_date,

    SUM(
        CASE
            WHEN purchase_ts IS NOT NULL
             AND TRIM(CAST(purchase_ts AS VARCHAR(100))) <> ''
             AND purchase_date_parsed IS NULL
            THEN 1
            ELSE 0
        END
    ) AS invalid_purchase_date,

    SUM(
        CASE
            WHEN ship_date_parsed IS NOT NULL
             AND purchase_date_parsed IS NOT NULL
             AND ship_date_parsed < purchase_date_parsed
            THEN 1
            ELSE 0
        END
    ) AS ship_before_purchase,

    SUM(
        CASE
            WHEN refund_date_parsed IS NOT NULL
             AND purchase_date_parsed IS NOT NULL
             AND refund_date_parsed < purchase_date_parsed
            THEN 1
            ELSE 0
        END
    ) AS refund_before_purchase

FROM parsed_dates;




-- review purchase platforms
SELECT
    purchase_platform,
    COUNT(*) AS row_count
FROM orders
GROUP BY purchase_platform
ORDER BY row_count DESC;




-- review marketing channels
SELECT
    marketing_channel,
    COUNT(*) AS row_count
FROM orders
GROUP BY marketing_channel
ORDER BY row_count DESC;



-- review account methods
SELECT
    account_creation_method,
    COUNT(*) AS row_count
FROM orders
GROUP BY account_creation_method
ORDER BY row_count DESC;




-- review country codes
SELECT
    country_code,
    COUNT(*) AS row_count
FROM orders
GROUP BY country_code
ORDER BY row_count DESC;




-- check product id consistency
SELECT
    product_id,
    COUNT(DISTINCT product_name) AS distinct_product_names
FROM orders
WHERE product_id IS NOT NULL
GROUP BY product_id
HAVING COUNT(DISTINCT product_name) > 1
ORDER BY distinct_product_names DESC;




-- check product name consistency
SELECT
    product_name,
    COUNT(DISTINCT product_id) AS distinct_product_ids
FROM orders
WHERE product_name IS NOT NULL
GROUP BY product_name
HAVING COUNT(DISTINCT product_id) > 1
ORDER BY distinct_product_ids DESC;




-- check customer missing values
SELECT
    COUNT(*) AS total_rows,

    SUM(
        CASE
            WHEN user_id IS NULL
              OR TRIM(CAST(user_id AS VARCHAR(100))) = ''
            THEN 1
            ELSE 0
        END
    ) AS missing_user_id,

    SUM(
        CASE
            WHEN age IS NULL
              OR TRIM(CAST(age AS VARCHAR(100))) = ''
            THEN 1
            ELSE 0
        END
    ) AS missing_age,

    SUM(
        CASE
            WHEN gender IS NULL
              OR TRIM(CAST(gender AS VARCHAR(100))) = ''
            THEN 1
            ELSE 0
        END
    ) AS missing_gender,

    SUM(
        CASE
            WHEN country_code IS NULL
              OR TRIM(CAST(country_code AS VARCHAR(100))) = ''
            THEN 1
            ELSE 0
        END
    ) AS missing_country_code

FROM customer_info;


-- check duplicate customers
SELECT
    user_id,
    COUNT(*) AS row_count
FROM customer_info
WHERE user_id IS NOT NULL
  AND TRIM(CAST(user_id AS VARCHAR(100))) <> ''
GROUP BY user_id
HAVING COUNT(*) > 1
ORDER BY row_count DESC, user_id;


-- check age quality
SELECT
    COUNT(*) AS total_rows,

    SUM(
        CASE
            WHEN age IS NULL
              OR TRIM(CAST(age AS VARCHAR(100))) = ''
            THEN 1
            ELSE 0
        END
    ) AS missing_age,

    SUM(
        CASE
            WHEN age IS NOT NULL
             AND TRIM(CAST(age AS VARCHAR(100))) <> ''
             AND TRY_CAST(age AS DECIMAL(5, 1)) IS NULL
            THEN 1
            ELSE 0
        END
    ) AS invalid_age_format,

    SUM(
        CASE
            WHEN TRY_CAST(age AS DECIMAL(5, 1)) < 13
              OR TRY_CAST(age AS DECIMAL(5, 1)) > 100
            THEN 1
            ELSE 0
        END
    ) AS age_outside_valid_range

FROM customer_info;


-- review gender values
SELECT
    gender,
    COUNT(*) AS row_count
FROM customer_info
GROUP BY gender
ORDER BY row_count DESC;



-- review loyalty tiers
SELECT
    loyalty_tier,
    COUNT(*) AS row_count
FROM customer_info
GROUP BY loyalty_tier
ORDER BY row_count DESC;



-- review customer segments
SELECT
    customer_segment,
    COUNT(*) AS row_count
FROM customer_info
GROUP BY customer_segment
ORDER BY row_count DESC;



-- review email opt-in
SELECT
    email_opt_in,
    COUNT(*) AS row_count
FROM customer_info
GROUP BY email_opt_in
ORDER BY row_count DESC;



-- review device values
SELECT
    device_preference,
    COUNT(*) AS row_count
FROM customer_info
GROUP BY device_preference
ORDER BY row_count DESC;



-- review income bands
SELECT
    income_band,
    COUNT(*) AS row_count
FROM customer_info
GROUP BY income_band
ORDER BY row_count DESC;



-- check product records
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT product_id) AS unique_product_ids,

    SUM(
        CASE
            WHEN product_id IS NULL
              OR TRIM(CAST(product_id AS VARCHAR(100))) = ''
            THEN 1
            ELSE 0
        END
    ) AS missing_product_id,

    SUM(
        CASE
            WHEN product_name IS NULL
              OR TRIM(CAST(product_name AS VARCHAR(200))) = ''
            THEN 1
            ELSE 0
        END
    ) AS missing_product_name,

    SUM(
        CASE
            WHEN base_price_gbp IS NULL
              OR TRIM(CAST(base_price_gbp AS VARCHAR(100))) = ''
            THEN 1
            ELSE 0
        END
    ) AS missing_base_price

FROM products;



-- check duplicate products
SELECT
    product_id,
    COUNT(*) AS row_count
FROM products
WHERE product_id IS NOT NULL
  AND TRIM(CAST(product_id AS VARCHAR(100))) <> ''
GROUP BY product_id
HAVING COUNT(*) > 1
ORDER BY row_count DESC, product_id;



-- review product categories
SELECT
    product_category,
    COUNT(*) AS product_count
FROM products
GROUP BY product_category
ORDER BY product_count DESC;



-- check region records
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT COUNTRY_CODE) AS unique_country_codes,

    SUM(
        CASE
            WHEN country_code IS NULL
              OR TRIM(CAST(country_code AS VARCHAR(100))) = ''
            THEN 1
            ELSE 0
        END
    ) AS missing_country_code,

    SUM(
        CASE
            WHEN region IS NULL
              OR TRIM(CAST(region AS VARCHAR(100))) = ''
            THEN 1
            ELSE 0
        END
    ) AS missing_region_name

FROM region;



-- check duplicate country codes
SELECT
    country_code,
    COUNT(*) AS row_count
FROM region
WHERE country_code IS NOT NULL
  AND TRIM(CAST(country_code AS VARCHAR(100))) <> ''
GROUP BY country_code
HAVING COUNT(*) > 1
ORDER BY row_count DESC, country_code;



-- review region values
SELECT
    region,
    COUNT(*) AS row_count
FROM region
GROUP BY region
ORDER BY row_count DESC;