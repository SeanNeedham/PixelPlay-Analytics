/*
pixelplay gaming analytics
orders fact table

create the fact table from cleaned order data
*/
-- remove old table
DROP TABLE IF EXISTS fact_orders;

-- create fact table
SELECT -- use cleaned row key
       o.order_row_key AS order_key,
       -- keep source order id
       o.order_id,
       o.purchase_platform,
       o.marketing_channel,
       o.account_creation_method,
       -- add dimension keys
       COALESCE (c.customer_key, 0) AS customer_key,
       COALESCE (p.product_key, 0) AS product_key,
       COALESCE (r.region_key, 0) AS region_key,
       COALESCE (pd.date_key, 0) AS purchase_date_key,
       COALESCE (sd.date_key, 0) AS ship_date_key,
       COALESCE (rd.date_key, 0) AS refund_date_key,
       -- add numeric measures
       o.product_price_gbp,
       CAST (CASE WHEN o.include_in_revenue_analysis = 'Yes' THEN COALESCE (o.product_price_gbp, 0) ELSE 0 END AS DECIMAL (18, 2)) AS revenue_gbp,
       CAST (1 AS TINYINT) AS order_count,
       -- add numeric flags
       CAST (CASE WHEN o.is_refunded = 'Yes' THEN 1 ELSE 0 END AS TINYINT) AS refund_flag,
       CAST (CASE WHEN o.include_in_revenue_analysis = 'Yes' THEN 1 ELSE 0 END AS TINYINT) AS revenue_analysis_flag,
       CAST (CASE WHEN o.include_in_date_analysis = 'Yes' THEN 1 ELSE 0 END AS TINYINT) AS date_analysis_flag,
       -- keep quality fields
       o.purchase_date_status,
       o.ship_date_status,
       o.refund_date_status,
       o.price_quality_status,
       o.duplicate_order_id_flag,
       o.missing_order_id_flag,
       o.product_match_status,
       o.customer_match_status,
       o.data_quality_status,
       o.source_product_id,
       o.source_price_quality_flag
INTO   fact_orders
FROM   orders_clean AS o
       LEFT OUTER JOIN
       dim_customer AS c
       ON o.user_id = c.user_id
       LEFT OUTER JOIN
       dim_product AS p
       ON o.product_id = p.product_id
       LEFT OUTER JOIN
       dim_region AS r
       ON o.country_code = r.country_code
       LEFT OUTER JOIN
       dim_date AS pd
       ON o.purchase_date = pd.date_value
       LEFT OUTER JOIN
       dim_date AS sd
       ON o.ship_date = sd.date_value
       LEFT OUTER JOIN
       dim_date AS rd
       ON o.refund_date = rd.date_value;
