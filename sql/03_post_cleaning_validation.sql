/*
pixelplay gaming - data validation

validation on the cleaned tables:
orders_clean
customers_clean
products_clean
region_clean
*/

-- check row counts
SELECT 'Raw Orders' AS dataset,
       COUNT(*) AS row_count
FROM   orders
UNION ALL
SELECT 'Clean Orders',
       COUNT(*)
FROM   orders_clean
UNION ALL
SELECT 'Raw Customers',
       COUNT(*)
FROM   customer_info
UNION ALL
SELECT 'Clean Customers',
       COUNT(*)
FROM   customers_clean
UNION ALL
SELECT 'Raw Products',
       COUNT(*)
FROM   products
UNION ALL
SELECT 'Clean Products',
       COUNT(*)
FROM   products_clean
UNION ALL
SELECT 'Raw Regions',
       COUNT(*)
FROM   region
UNION ALL
SELECT 'Clean Regions',
       COUNT(*)
FROM   region_clean;

GO

-- check unique order row keys
SELECT COUNT(*) AS total_order_rows,
       COUNT(DISTINCT order_row_key) AS unique_order_row_keys,
       COUNT(*) - COUNT(DISTINCT order_row_key) AS duplicate_order_row_keys
FROM   orders_clean;

GO

-- check for duplicate order row keys
SELECT   order_row_key,
         COUNT(*) AS row_count
FROM     orders_clean
GROUP BY order_row_key
HAVING   COUNT(*) > 1
ORDER BY row_count DESC;

-- check customer keys
SELECT   user_id,
         COUNT(*) AS row_count
FROM     customers_clean
WHERE    user_id IS NOT NULL
GROUP BY user_id
HAVING   COUNT(*) > 1
ORDER BY row_count DESC;

-- check product keys
SELECT   product_id,
         COUNT(*) AS row_count
FROM     products_clean
WHERE    product_id IS NOT NULL
GROUP BY product_id
HAVING   COUNT(*) > 1
ORDER BY row_count DESC;

-- check region keys
SELECT   country_code,
         COUNT(*) AS row_count
FROM     region_clean
WHERE    country_code IS NOT NULL
GROUP BY country_code
HAVING   COUNT(*) > 1
ORDER BY row_count DESC;

-- check missing keys
SELECT COUNT(*) AS total_orders,
       SUM(CASE WHEN order_id IS NULL
                     OR TRIM(CAST(order_id AS VARCHAR(100))) = '' THEN 1 ELSE 0 END) AS missing_order_id,
       SUM(CASE WHEN user_id IS NULL
                     OR TRIM(CAST(user_id AS VARCHAR(100))) = '' THEN 1 ELSE 0 END) AS missing_user_id,
       SUM(CASE WHEN product_id IS NULL
                     OR TRIM(CAST(product_id AS VARCHAR(100))) = '' THEN 1 ELSE 0 END) AS missing_product_id
FROM   orders_clean;

-- check product matches
SELECT   product_match_status,
         COUNT(*) AS order_count,
         CAST(100.0 * COUNT(*) / SUM(COUNT(*)) OVER () AS DECIMAL(6, 2)) AS pct_of_orders
FROM     orders_clean
GROUP BY product_match_status
ORDER BY order_count DESC;

-- check for unmatched products
SELECT COUNT(*) AS unmatched_product_rows
FROM   orders_clean AS o
       LEFT OUTER JOIN products_clean AS p
       ON o.product_id = p.product_id
WHERE  p.product_id IS NULL;

-- review unmatched products
SELECT   o.source_product_id,
         o.product_id,
         o.product_name,
         o.product_match_status,
         COUNT(*) AS order_count
FROM     orders_clean AS o
         LEFT OUTER JOIN products_clean AS p
         ON o.product_id = p.product_id
WHERE    p.product_id IS NULL
GROUP BY o.source_product_id,
         o.product_id,
         o.product_name,
         o.product_match_status
ORDER BY order_count DESC;

-- check customer matches
SELECT   customer_match_status,
         COUNT(*) AS order_count,
         CAST(100.0 * COUNT(*) / SUM(COUNT(*)) OVER () AS DECIMAL(6, 2)) AS pct_of_orders
FROM     orders_clean
GROUP BY customer_match_status
ORDER BY order_count DESC;

-- check for unmatched customers
SELECT COUNT(*) AS unmatched_customer_rows
FROM   orders_clean AS o
       LEFT OUTER JOIN customers_clean AS c
       ON o.user_id = c.user_id
WHERE  c.user_id IS NULL;

-- check price quality
SELECT   price_quality_status,
         COUNT(*) AS order_count,
         CAST(100.0 * COUNT(*) / SUM(COUNT(*)) OVER () AS DECIMAL(6, 2)) AS pct_of_orders
FROM     orders_clean
GROUP BY price_quality_status
ORDER BY order_count DESC;

-- check revenue flags
SELECT   include_in_revenue_analysis,
         COUNT(*) AS order_count,
         CAST(SUM(COALESCE(product_price_gbp, 0)) AS DECIMAL(18, 2)) AS order_value_gbp
FROM     orders_clean
GROUP BY include_in_revenue_analysis
ORDER BY include_in_revenue_analysis DESC;

-- check included revenue rows
SELECT COUNT(*) AS invalid_rows_included_in_revenue
FROM   orders_clean
WHERE  UPPER(TRIM(CAST(include_in_revenue_analysis AS VARCHAR(10)))) IN ('YES', '1', 'TRUE')
       AND (product_price_gbp IS NULL
            OR product_price_gbp <= 0);

-- check purchase dates
SELECT   purchase_date_status,
         COUNT(*) AS order_count,
         CAST(100.0 * COUNT(*) / SUM(COUNT(*)) OVER () AS DECIMAL(6, 2)) AS pct_of_orders
FROM     orders_clean
GROUP BY purchase_date_status
ORDER BY order_count DESC;

-- check date analysis flags
SELECT   include_in_date_analysis,
         COUNT(*) AS order_count
FROM     orders_clean
GROUP BY include_in_date_analysis
ORDER BY include_in_date_analysis DESC;

-- check included date rows
SELECT COUNT(*) AS invalid_rows_included_in_date_analysis
FROM   orders_clean
WHERE  UPPER(TRIM(CAST(include_in_date_analysis AS VARCHAR(10)))) IN ('YES', '1', 'TRUE')
       AND purchase_date IS NULL;

-- review excluded date rows
SELECT   purchase_date_status,
         COUNT(*) AS excluded_order_count
FROM     orders_clean
WHERE    UPPER(TRIM(CAST(include_in_date_analysis AS VARCHAR(10)))) NOT IN ('YES', '1', 'TRUE')
GROUP BY purchase_date_status
ORDER BY excluded_order_count DESC;

-- check shipping dates
SELECT   ship_date_status,
         COUNT(*) AS order_count
FROM     orders_clean
GROUP BY ship_date_status
ORDER BY order_count DESC;

-- check shipping sequence
SELECT COUNT(*) AS remaining_ship_before_purchase
FROM   orders_clean
WHERE  ship_date IS NOT NULL
       AND purchase_date IS NOT NULL
       AND ship_date < purchase_date;

-- check refund dates
SELECT   refund_date_status,
         COUNT(*) AS order_count
FROM     orders_clean
GROUP BY refund_date_status
ORDER BY order_count DESC;

-- check refund sequence
SELECT COUNT(*) AS remaining_refund_before_purchase
FROM   orders_clean
WHERE  refund_date IS NOT NULL
       AND purchase_date IS NOT NULL
       AND refund_date < purchase_date;

-- review refund flags
SELECT   is_refunded,
         COUNT(*) AS order_count
FROM     orders_clean
GROUP BY is_refunded
ORDER BY order_count DESC;

-- check duplicate order ids
SELECT   duplicate_order_id_flag,
         COUNT(*) AS order_count
FROM     orders_clean
GROUP BY duplicate_order_id_flag
ORDER BY order_count DESC;

-- check missing order ids
SELECT   missing_order_id_flag,
         COUNT(*) AS order_count
FROM     orders_clean
GROUP BY missing_order_id_flag
ORDER BY order_count DESC;

-- check age range
SELECT COUNT(*) AS invalid_age_rows
FROM   customers_clean
WHERE  age IS NOT NULL
       AND (age < 13
            OR age > 100);

-- review age bands
SELECT   age_band,
         COUNT(*) AS customer_count
FROM     customers_clean
GROUP BY age_band
ORDER BY customer_count DESC;

-- review email opt-in
SELECT   email_opt_in,
         COUNT(*) AS customer_count
FROM     customers_clean
GROUP BY email_opt_in
ORDER BY customer_count DESC;

-- review customer segments
SELECT   customer_segment,
         COUNT(*) AS customer_count
FROM     customers_clean
GROUP BY customer_segment
ORDER BY customer_count DESC;

-- review loyalty tiers
SELECT   loyalty_tier,
         COUNT(*) AS customer_count
FROM     customers_clean
GROUP BY loyalty_tier
ORDER BY customer_count DESC;

-- review product categories
SELECT   product_category,
         COUNT(*) AS product_count
FROM     products_clean
GROUP BY product_category
ORDER BY product_count DESC;

-- check product prices
SELECT COUNT(*) AS invalid_product_base_prices
FROM   products_clean
WHERE  base_price_gbp IS NOT NULL
       AND base_price_gbp < 0;

-- review regions
SELECT   region_name,
         COUNT(*) AS country_count
FROM     region_clean
GROUP BY region_name
ORDER BY country_count DESC;

-- review unknown regions
SELECT   country_code,
         region_name
FROM     region_clean
WHERE    region_name = 'Unknown'
         OR country_code = 'UNKNOWN'
ORDER BY country_code;

-- review overall data quality
SELECT   data_quality_status,
         COUNT(*) AS order_count,
         CAST(100.0 * COUNT(*) / SUM(COUNT(*)) OVER () AS DECIMAL(6, 2)) AS pct_of_orders
FROM     orders_clean
GROUP BY data_quality_status
ORDER BY order_count DESC;