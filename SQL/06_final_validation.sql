/* PixelPlay gaming final validation

final reconciliation and checks

cleaned tables:
orders_clean
customers_clean
products_clean
region_clean

reporting tables:
fact_orders
dim_customer
dim_product
dim_region
dim_date
*/

-- check final row counts
SELECT 'orders_clean' AS table_name,
       COUNT(*) AS row_count
FROM   orders_clean
UNION ALL
SELECT 'customers_clean',
       COUNT(*)
FROM   customers_clean
UNION ALL
SELECT 'products_clean',
       COUNT(*)
FROM   products_clean
UNION ALL
SELECT 'region_clean',
       COUNT(*)
FROM   region_clean
UNION ALL
SELECT 'fact_orders',
       COUNT(*)
FROM   fact_orders
UNION ALL
SELECT 'dim_customer',
       COUNT(*)
FROM   dim_customer
UNION ALL
SELECT 'dim_product',
       COUNT(*)
FROM   dim_product
UNION ALL
SELECT 'dim_region',
       COUNT(*)
FROM   dim_region
UNION ALL
SELECT 'dim_date',
       COUNT(*)
FROM   dim_date;


-- check fact row count
SELECT (SELECT COUNT(*)
        FROM   orders_clean) AS orders_clean_rows,
       (SELECT COUNT(*)
        FROM   fact_orders) AS fact_orders_rows,
       (SELECT COUNT(*)
        FROM   fact_orders) - (SELECT COUNT(*)
                                   FROM   orders_clean) AS row_difference;

-- check fact grain
SELECT COUNT(*) AS fact_rows,
       COUNT(DISTINCT order_key) AS unique_order_row_keys,
       COUNT(*) - COUNT(DISTINCT order_key) AS duplicate_order_row_keys
FROM   fact_orders;

-- check dimension keys
SELECT 'dim_customer' AS dimension_name,
       COUNT(*) AS row_count,
       COUNT(DISTINCT user_id) AS unique_business_keys,
       COUNT(*) - COUNT(DISTINCT user_id) AS duplicate_business_keys
FROM   dim_customer
UNION ALL
SELECT 'dim_product',
       COUNT(*),
       COUNT(DISTINCT product_id),
       COUNT(*) - COUNT(DISTINCT product_id)
FROM   dim_product
UNION ALL
SELECT 'dim_region',
       COUNT(*),
       COUNT(DISTINCT country_code),
       COUNT(*) - COUNT(DISTINCT country_code)
FROM   dim_region
UNION ALL
SELECT 'dim_date',
       COUNT(*),
       COUNT(DISTINCT date_key),
       COUNT(*) - COUNT(DISTINCT date_key)
FROM   dim_date;


-- check broken relationships
SELECT SUM(CASE WHEN c.customer_key IS NULL THEN 1 ELSE 0 END) AS missing_customer_keys,
       SUM(CASE WHEN p.product_key IS NULL THEN 1 ELSE 0 END) AS missing_product_keys,
       SUM(CASE WHEN r.region_key IS NULL THEN 1 ELSE 0 END) AS missing_region_keys,
       SUM(CASE WHEN pd.date_key IS NULL THEN 1 ELSE 0 END) AS missing_purchase_date_keys,
       SUM(CASE WHEN sd.date_key IS NULL THEN 1 ELSE 0 END) AS missing_ship_date_keys,
       SUM(CASE WHEN rd.date_key IS NULL THEN 1 ELSE 0 END) AS missing_refund_date_keys
FROM   fact_orders AS f
       LEFT JOIN
       dim_customer AS c
       ON f.customer_key = c.customer_key
       LEFT JOIN
       dim_product AS p
       ON f.product_key = p.product_key
       LEFT JOIN
       dim_region AS r
       ON f.region_key = r.region_key
       LEFT JOIN
       dim_date AS pd
       ON f.purchase_date_key = pd.date_key
       LEFT JOIN
       dim_date AS sd
       ON f.ship_date_key = sd.date_key
       LEFT JOIN
       dim_date AS rd
       ON f.refund_date_key = rd.date_key;

-- check revenue totals
WITH   clean_revenue
AS     (SELECT CAST (SUM(CASE WHEN UPPER(TRIM(CAST (include_in_revenue_analysis AS VARCHAR (10)))) IN ('YES', '1', 'TRUE') THEN COALESCE (product_price_gbp, 0) ELSE 0 END) AS DECIMAL (18, 2)) AS total_revenue_gbp
        FROM   dbo.orders_clean),
       fact_revenue
AS     (SELECT CAST (SUM(revenue_gbp) AS DECIMAL (18, 2)) AS total_revenue_gbp
        FROM   dbo.fact_orders)
SELECT c.total_revenue_gbp AS orders_clean_revenue_gbp,
       f.total_revenue_gbp AS fact_orders_revenue_gbp,
       CAST (f.total_revenue_gbp - c.total_revenue_gbp AS DECIMAL (18, 2)) AS revenue_difference_gbp
FROM   clean_revenue AS c CROSS JOIN fact_revenue AS f;

-- check refund totals
WITH   clean_refunds
AS     (SELECT SUM(CASE WHEN UPPER(TRIM(CAST (is_refunded AS VARCHAR (10)))) IN ('YES', '1', 'TRUE') THEN 1 ELSE 0 END) AS refunded_orders
        FROM   dbo.orders_clean),
       fact_refunds
AS     (SELECT SUM(CAST (refund_flag AS INT)) AS refunded_orders
        FROM   dbo.fact_orders)
SELECT c.refunded_orders AS orders_clean_refunded_orders,
       f.refunded_orders AS fact_orders_refunded_orders,
       f.refunded_orders - c.refunded_orders AS refund_difference
FROM   clean_refunds AS c CROSS JOIN fact_refunds AS f;

-- check revenue flags
SELECT 'orders_clean' AS dataset,
       SUM(CASE WHEN UPPER(TRIM(CAST (include_in_revenue_analysis AS VARCHAR (10)))) IN ('YES', '1', 'TRUE') THEN 1 ELSE 0 END) AS revenue_eligible_rows,
       SUM(CASE WHEN UPPER(TRIM(CAST (include_in_revenue_analysis AS VARCHAR (10)))) NOT IN ('YES', '1', 'TRUE') THEN 1 ELSE 0 END) AS revenue_excluded_rows
FROM   orders_clean
UNION ALL
SELECT 'fact_orders',
       SUM(CASE WHEN revenue_analysis_flag = 1 THEN 1 ELSE 0 END),
       SUM(CASE WHEN revenue_analysis_flag = 0 THEN 1 ELSE 0 END)
FROM   fact_orders;

-- check date flags
SELECT 'orders_clean' AS dataset,
       SUM(CASE WHEN UPPER(TRIM(CAST (include_in_date_analysis AS VARCHAR (10)))) IN ('YES', '1', 'TRUE') THEN 1 ELSE 0 END) AS date_eligible_rows,
       SUM(CASE WHEN UPPER(TRIM(CAST (include_in_date_analysis AS VARCHAR (10)))) NOT IN ('YES', '1', 'TRUE') THEN 1 ELSE 0 END) AS date_excluded_rows
FROM   orders_clean
UNION ALL
SELECT 'fact_orders',
       SUM(CASE WHEN date_analysis_flag = 1 THEN 1 ELSE 0 END),
       SUM(CASE WHEN date_analysis_flag = 0 THEN 1 ELSE 0 END)
FROM   fact_orders;

-- check unknown members
SELECT SUM(CASE WHEN customer_key = 0 THEN 1 ELSE 0 END) AS unknown_customer_orders,
       SUM(CASE WHEN product_key = 0 THEN 1 ELSE 0 END) AS unknown_product_orders,
       SUM(CASE WHEN region_key = 0 THEN 1 ELSE 0 END) AS unknown_region_orders,
       SUM(CASE WHEN purchase_date_key = 0 THEN 1 ELSE 0 END) AS unknown_purchase_date_orders,
       SUM(CASE WHEN ship_date_key = 0 THEN 1 ELSE 0 END) AS unknown_ship_date_orders,
       SUM(CASE WHEN refund_date_key = 0 THEN 1 ELSE 0 END) AS unknown_refund_date_orders
FROM   fact_orders;

-- check product matches
SELECT   product_match_status,
         COUNT(*) AS order_count
FROM   fact_orders
GROUP BY product_match_status
ORDER BY order_count DESC;

-- check customer matches
SELECT   customer_match_status,
         COUNT(*) AS order_count
FROM     fact_orders
GROUP BY customer_match_status
ORDER BY order_count DESC;

-- check date key consistency
SELECT SUM(CASE WHEN date_analysis_flag = 0
                     AND purchase_date_key <> 0 THEN 1 ELSE 0 END) AS excluded_rows_with_valid_purchase_key,
       SUM(CASE WHEN date_analysis_flag = 1
                     AND purchase_date_key = 0 THEN 1 ELSE 0 END) AS included_rows_with_unknown_purchase_key
FROM   fact_orders;

-- compare final kpis with power bi
SELECT COUNT(*) AS total_orders,
       COUNT(DISTINCT CASE WHEN customer_key <> 0 THEN customer_key END) AS total_customers,
       CAST (SUM(revenue_gbp) AS DECIMAL (18, 2)) AS total_revenue_gbp,
       CAST (SUM(revenue_gbp) / NULLIF (SUM(CASE WHEN revenue_analysis_flag = 1 THEN 1 ELSE 0 END), 0) AS DECIMAL (18, 2)) AS average_order_value_gbp,
       SUM(CAST (refund_flag AS INT)) AS refunded_orders,
       CAST (100.0 * SUM(CAST (refund_flag AS INT)) / NULLIF (COUNT(*), 0) AS DECIMAL (6, 2)) AS refund_rate_pct,
       SUM(CASE WHEN revenue_analysis_flag = 0 THEN 1 ELSE 0 END) AS orders_excluded_from_revenue,
       SUM(CASE WHEN date_analysis_flag = 0 THEN 1 ELSE 0 END) AS orders_excluded_from_date_analysis
FROM  fact_orders;

-- final pass or fail checks
WITH     validation_results
AS       (SELECT 'Fact row count matches orders_clean' AS validation_check,
                 CASE WHEN (SELECT COUNT(*)
                            FROM   fact_orders) = (SELECT COUNT(*)
                                                       FROM   orders_clean) THEN 'PASS' ELSE 'FAIL' END AS result
          UNION ALL
          SELECT 'order_key is unique',
                 CASE WHEN (SELECT COUNT(*)
                            FROM   fact_orders) = (SELECT COUNT(DISTINCT order_key)
                                                       FROM   fact_orders) THEN 'PASS' ELSE 'FAIL' END
          UNION ALL
          SELECT 'No missing customer keys',
                 CASE WHEN NOT EXISTS (SELECT 1
                                       FROM   fact_orders AS f
                                              LEFT JOIN
                                              dim_customer AS c
                                              ON f.customer_key = c.customer_key
                                       WHERE  c.customer_key IS NULL) THEN 'PASS' ELSE 'FAIL' END
          UNION ALL
          SELECT 'No missing product keys',
                 CASE WHEN NOT EXISTS (SELECT 1
                                       FROM   fact_orders AS f
                                              LEFT JOIN
                                              dim_product AS p
                                              ON f.product_key = p.product_key
                                       WHERE  p.product_key IS NULL) THEN 'PASS' ELSE 'FAIL' END
          UNION ALL
          SELECT 'No missing region keys',
                 CASE WHEN NOT EXISTS (SELECT 1
                                       FROM   fact_orders AS f
                                              LEFT JOIN
                                              dim_region AS r
                                              ON f.region_key = r.region_key
                                       WHERE  r.region_key IS NULL) THEN 'PASS' ELSE 'FAIL' END
          UNION ALL
          SELECT 'No unknown product orders',
                 CASE WHEN (SELECT COUNT(*)
                            FROM   fact_orders
                            WHERE  product_key = 0) = 0 THEN 'PASS' ELSE 'FAIL' END)
SELECT   validation_check,
         result
FROM     validation_results
ORDER BY CASE WHEN result = 'FAIL' THEN 1 ELSE 2 END, validation_check;