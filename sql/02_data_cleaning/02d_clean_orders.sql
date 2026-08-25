/*
pixelplay gaming analytics
orders data cleaning

clean and standardise orders before modelling
*/
-- standardise raw order fields
WITH   cleaned_orders
AS     (SELECT NULLIF (LOWER(TRIM(USER_ID)), '') AS user_id_raw,
               NULLIF (LOWER(TRIM(ORDER_ID)), '') AS order_id,
               NULLIF (TRIM(PURCHASE_TS), '') AS purchase_ts_raw,
               NULLIF (TRIM(SHIP_TS), '') AS ship_ts_raw,
               NULLIF (TRIM(REFUND_TS), '') AS refund_ts_raw,
               CASE WHEN LOWER(TRIM(PRODUCT_NAME)) IN ('sony playstation 5 bundle', 'sony ps5 bundle') THEN 'Sony PlayStation 5 Bundle' WHEN LOWER(TRIM(PRODUCT_NAME)) IN ('27in 4k gaming monitor', '27inches 4k gaming monitor', '27 inches 4k gaming monitor', '27-inch 4k gaming monitor', '27" 4k gaming monitor') THEN '27in 4K Gaming Monitor' ELSE NULLIF (TRIM(PRODUCT_NAME), '') END AS product_name_raw,
               NULLIF (LOWER(TRIM(PRODUCT_ID)), '') AS product_id_raw,
               NULLIF (TRIM(GBP_PRICE), '') AS price_raw,
               NULLIF (TRIM(PRICE_QUALITY_FLAG), '') AS source_price_quality_flag,
               CASE WHEN LOWER(TRIM(PURCHASE_PLATFORM)) IN ('website', 'web') THEN 'Website' WHEN LOWER(TRIM(PURCHASE_PLATFORM)) IN ('mobile_app', 'mobile app', 'app') THEN 'Mobile app' WHEN PURCHASE_PLATFORM IS NULL
                                                                                                                                                                                               OR TRIM(PURCHASE_PLATFORM) = '' THEN 'Unknown' ELSE TRIM(PURCHASE_PLATFORM) END AS purchase_platform,
               CASE WHEN LOWER(TRIM(MARKETING_CHANNEL)) = 'direct' THEN 'Direct' WHEN LOWER(TRIM(MARKETING_CHANNEL)) = 'email' THEN 'Email' WHEN LOWER(TRIM(MARKETING_CHANNEL)) = 'paid search' THEN 'Paid Search' WHEN LOWER(TRIM(MARKETING_CHANNEL)) IN ('social media', 'social') THEN 'Social Media' WHEN LOWER(TRIM(MARKETING_CHANNEL)) = 'affiliate' THEN 'Affiliate' WHEN LOWER(TRIM(MARKETING_CHANNEL)) = 'organic search' THEN 'Organic Search' WHEN LOWER(TRIM(MARKETING_CHANNEL)) = 'influencer' THEN 'Influencer' ELSE 'Unknown' END AS marketing_channel,
               CASE WHEN LOWER(TRIM(ACCOUNT_CREATION_METHOD)) = 'desktop' THEN 'Desktop' WHEN LOWER(TRIM(ACCOUNT_CREATION_METHOD)) = 'mobile' THEN 'Mobile' WHEN LOWER(TRIM(ACCOUNT_CREATION_METHOD)) = 'guest checkout' THEN 'Guest Checkout' WHEN LOWER(TRIM(ACCOUNT_CREATION_METHOD)) = 'tablet' THEN 'Tablet' WHEN LOWER(TRIM(ACCOUNT_CREATION_METHOD)) = 'console' THEN 'Console' WHEN LOWER(TRIM(ACCOUNT_CREATION_METHOD)) = 'tv' THEN 'TV' ELSE 'Unknown' END AS account_creation_method,
               CASE WHEN COUNTRY_CODE IS NULL
                         OR TRIM(COUNTRY_CODE) = ''
                         OR UPPER(TRIM(COUNTRY_CODE)) IN ('ZZ', 'UNKNOWN', 'N/A') THEN 'UNKNOWN' ELSE UPPER(TRIM(COUNTRY_CODE)) END AS country_code
        FROM   orders),
-- convert mixed date formats and prices
       converted_orders
AS     (SELECT *,
               -- includes excel serial dates where needed
               CAST (COALESCE (TRY_CONVERT (DATETIME2, purchase_ts_raw, 23), TRY_CONVERT (DATETIME2, purchase_ts_raw, 120), TRY_CONVERT (DATETIME2, purchase_ts_raw, 121), TRY_CONVERT (DATETIME2, purchase_ts_raw, 101), TRY_CONVERT (DATETIME2, purchase_ts_raw, 103), TRY_CONVERT (DATETIME2, purchase_ts_raw, 110), CASE WHEN TRY_CAST (TRY_CAST (purchase_ts_raw AS DECIMAL (18, 4)) AS INT) BETWEEN 1 AND 60000 THEN DATEADD(DAY, TRY_CAST (TRY_CAST (purchase_ts_raw AS DECIMAL (18, 4)) AS INT), DATEFROMPARTS(1899, 12, 30)) END) AS DATE) AS purchase_date_parsed,
               CAST (COALESCE (TRY_CONVERT (DATETIME2, ship_ts_raw, 23), TRY_CONVERT (DATETIME2, ship_ts_raw, 120), TRY_CONVERT (DATETIME2, ship_ts_raw, 121), TRY_CONVERT (DATETIME2, ship_ts_raw, 101), TRY_CONVERT (DATETIME2, ship_ts_raw, 103), TRY_CONVERT (DATETIME2, ship_ts_raw, 110), CASE WHEN TRY_CAST (TRY_CAST (ship_ts_raw AS DECIMAL (18, 4)) AS INT) BETWEEN 1 AND 60000 THEN DATEADD(DAY, TRY_CAST (TRY_CAST (ship_ts_raw AS DECIMAL (18, 4)) AS INT), DATEFROMPARTS(1899, 12, 30)) END) AS DATE) AS ship_date_parsed,
               CAST (COALESCE (TRY_CONVERT (DATETIME2, refund_ts_raw, 23), TRY_CONVERT (DATETIME2, refund_ts_raw, 120), TRY_CONVERT (DATETIME2, refund_ts_raw, 121), TRY_CONVERT (DATETIME2, refund_ts_raw, 101), TRY_CONVERT (DATETIME2, refund_ts_raw, 103), TRY_CONVERT (DATETIME2, refund_ts_raw, 110), CASE WHEN TRY_CAST (TRY_CAST (refund_ts_raw AS DECIMAL (18, 4)) AS INT) BETWEEN 1 AND 60000 THEN DATEADD(DAY, TRY_CAST (TRY_CAST (refund_ts_raw AS DECIMAL (18, 4)) AS INT), DATEFROMPARTS(1899, 12, 30)) END) AS DATE) AS refund_date_parsed,
               CASE WHEN UPPER(TRIM(price_raw)) = 'FREE' THEN CAST (0.00 AS DECIMAL (10, 2)) ELSE TRY_CAST (REPLACE(REPLACE(price_raw, '£', ''), ',', '') AS DECIMAL (10, 2)) END AS product_price_gbp
        FROM   cleaned_orders),
-- match orders to cleaned reference tables
       matched_orders
AS     (SELECT o.*,
               -- recover product id from product name when possible
               COALESCE (product_by_id.product_id, product_by_name.product_id) AS product_id,
               COALESCE (product_by_id.product_name, product_by_name.product_name, o.product_name_raw) AS product_name,
               CASE WHEN product_by_id.product_id IS NOT NULL THEN 'Matched by Product ID' WHEN product_by_name.product_id IS NOT NULL THEN 'Recovered from Product Name' ELSE 'Unmatched Product' END AS product_match_status,
               CASE WHEN o.user_id_raw IS NULL THEN 'Missing User ID' WHEN customer_match.user_id IS NOT NULL THEN 'Matched Customer' ELSE 'Unmatched Customer' END AS customer_match_status,
               COALESCE (region_match.region_name, 'Unknown') AS region_name
        FROM   converted_orders AS o
               LEFT OUTER JOIN
               products_clean AS product_by_id
               ON o.product_id_raw = product_by_id.product_id
               LEFT OUTER JOIN
               products_clean AS product_by_name
               ON LOWER(o.product_name_raw) = LOWER(product_by_name.product_name)
               LEFT OUTER JOIN
               customers_clean AS customer_match
               ON o.user_id_raw = customer_match.user_id
               LEFT OUTER JOIN
               region_clean AS region_match
               ON o.country_code = region_match.country_code),
-- validate date sequences and repeated order ids
       validated_orders
AS     (SELECT *,
               -- invalid ship/refund dates are removed from analysis
               CASE WHEN purchase_date_parsed IS NOT NULL
                         AND ship_date_parsed < purchase_date_parsed THEN NULL ELSE ship_date_parsed END AS ship_date_clean,
               CASE WHEN purchase_date_parsed IS NOT NULL
                         AND refund_date_parsed < purchase_date_parsed THEN NULL ELSE refund_date_parsed END AS refund_date_clean,
               CASE WHEN order_id IS NULL THEN 0 ELSE COUNT(*) OVER (PARTITION BY order_id) END AS order_id_count
        FROM   matched_orders)
SELECT -- create final cleaned orders table
       IDENTITY (BIGINT, 1, 1) AS order_row_key,
       order_id,
       product_id,
       product_name,
       product_price_gbp,
       purchase_platform,
       marketing_channel,
       account_creation_method,
       country_code,
       region_name,
       product_match_status,
       customer_match_status,
       COALESCE (user_id_raw, 'UNKNOWN') AS user_id,
       purchase_date_parsed AS purchase_date,
       ship_date_clean AS ship_date,
       refund_date_clean AS refund_date,
       -- analysis flags
       CASE WHEN refund_date_clean IS NOT NULL THEN 'Yes' ELSE 'No' END AS is_refunded,
       CASE WHEN product_price_gbp > 0 THEN 'Yes' ELSE 'No' END AS include_in_revenue_analysis,
       CASE WHEN purchase_date_parsed IS NOT NULL THEN 'Yes' ELSE 'No' END AS include_in_date_analysis,
       -- data quality status fields
       CASE WHEN purchase_ts_raw IS NULL THEN 'Missing Purchase Date' WHEN purchase_date_parsed IS NULL THEN 'Invalid Purchase Date' ELSE 'Valid Purchase Date' END AS purchase_date_status,
       CASE WHEN ship_ts_raw IS NULL THEN 'Missing Ship Date' WHEN ship_date_parsed IS NULL THEN 'Invalid Ship Date' WHEN purchase_date_parsed IS NULL THEN 'Ship Date Not Validated' WHEN ship_date_parsed < purchase_date_parsed THEN 'Ship Before Purchase' ELSE 'Valid Ship Date' END AS ship_date_status,
       CASE WHEN refund_ts_raw IS NULL THEN 'Not Refunded' WHEN refund_date_clean IS NULL THEN 'Invalid Refund Date' WHEN purchase_date_parsed IS NULL THEN 'Refund Date Not Validated' WHEN refund_date_parsed < purchase_date_parsed THEN 'Refund Before Purchase' ELSE 'Valid Refund Date' END AS refund_date_status,
       CASE WHEN price_raw IS NULL THEN 'Missing Price' WHEN product_price_gbp IS NULL THEN 'Invalid Price' WHEN product_price_gbp < 0 THEN 'Negative Price' WHEN product_price_gbp = 0 THEN 'Free/Zero Price' ELSE 'Valid Price' END AS price_quality_status,
       CASE WHEN order_id_count > 1 THEN 'Yes' ELSE 'No' END AS duplicate_order_id_flag,
       CASE WHEN order_id IS NULL THEN 'Yes' ELSE 'No' END AS missing_order_id_flag,
       -- identify records that need further review
       CASE WHEN order_id IS NULL
                 OR purchase_date_parsed IS NULL
                 OR product_id IS NULL
                 OR product_price_gbp IS NULL
                 OR product_price_gbp < 0
                 OR customer_match_status <> 'Matched Customer'
                 OR region_name = 'Unknown'
                 OR (purchase_date_parsed IS NOT NULL
                     AND ship_date_parsed < purchase_date_parsed)
                 OR (purchase_date_parsed IS NOT NULL
                     AND refund_date_parsed < purchase_date_parsed) THEN 'Review' ELSE 'Clean' END AS data_quality_status,
       -- retain selected source fields for validation
       product_id_raw AS source_product_id,
       source_price_quality_flag
INTO   orders_clean
FROM   validated_orders;