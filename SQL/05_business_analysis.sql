/* Q1: How are revenue and order volumes performing over time? */

SELECT   DATEFROMPARTS(YEAR(d.date_value), MONTH(d.date_value), 1) AS month_start,
         COUNT(*) AS total_orders,
         COUNT(DISTINCT CASE WHEN f.customer_key <> 0 THEN f.customer_key END) AS total_customers,
         CAST (SUM(CASE WHEN f.revenue_analysis_flag = 1 THEN f.product_price_gbp ELSE 0 END) AS DECIMAL (18, 2)) AS total_revenue_gbp,
         CAST (SUM(CASE WHEN f.revenue_analysis_flag = 1 THEN f.product_price_gbp ELSE 0 END) / NULLIF (SUM(CASE WHEN f.revenue_analysis_flag = 1 THEN 1 ELSE 0 END), 0) AS DECIMAL (18, 2)) AS average_order_value_gbp
FROM     fact_orders AS f
         INNER JOIN
         dim_date AS d
         ON f.purchase_date_key = d.date_key
WHERE    f.date_analysis_flag = 1
GROUP BY DATEFROMPARTS(YEAR(d.date_value), MONTH(d.date_value), 1)
ORDER BY month_start;


/* Q2: Which products and product categories generate the most revenue and orders? */

WITH     product_performance
AS       (SELECT   p.product_category,
                   p.product_name,
                   COUNT(*) AS total_orders,
                   SUM(CASE WHEN f.revenue_analysis_flag = 1 THEN f.product_price_gbp ELSE 0 END) AS total_revenue_gbp,
                   SUM(CASE WHEN f.revenue_analysis_flag = 1 THEN 1 ELSE 0 END) AS revenue_eligible_orders
          FROM     fact_orders AS f
                   INNER JOIN
                   dim_product AS p
                   ON f.product_key = p.product_key
          WHERE    p.product_key <> 0
          GROUP BY p.product_category, p.product_name)
SELECT   product_category,
         product_name,
         total_orders,
         CAST (total_revenue_gbp AS DECIMAL (18, 2)) AS total_revenue_gbp,
         CAST (total_revenue_gbp / NULLIF (revenue_eligible_orders, 0) AS DECIMAL (18, 2)) AS average_order_value_gbp,
         CAST (100.0 * total_revenue_gbp / NULLIF (SUM(total_revenue_gbp) OVER (), 0) AS DECIMAL (6, 2)) AS revenue_contribution_pct
FROM     product_performance
ORDER BY total_revenue_gbp DESC, total_orders DESC;


/* Q3: Which customer segments contribute the greatest value to the business? */

WITH     demographic_performance
AS       (SELECT   'Age Band' AS demographic_type,
                   c.age_band AS demographic_segment,
                   COUNT(*) AS total_orders,
                   COUNT(DISTINCT CASE WHEN f.customer_key <> 0 THEN f.customer_key END) AS total_customers,
                   SUM(CASE WHEN f.revenue_analysis_flag = 1 THEN f.product_price_gbp ELSE 0 END) AS total_revenue_gbp,
                   SUM(CASE WHEN f.revenue_analysis_flag = 1 THEN 1 ELSE 0 END) AS revenue_eligible_orders
          FROM     fact_orders AS f
                   INNER JOIN
                   dim_customer AS c
                   ON f.customer_key = c.customer_key
          WHERE    c.customer_key <> 0
          GROUP BY c.age_band
          UNION ALL
          SELECT   'Gender',
                   c.gender,
                   COUNT(*),
                   COUNT(DISTINCT CASE WHEN f.customer_key <> 0 THEN f.customer_key END),
                   SUM(CASE WHEN f.revenue_analysis_flag = 1 THEN f.product_price_gbp ELSE 0 END),
                   SUM(CASE WHEN f.revenue_analysis_flag = 1 THEN 1 ELSE 0 END)
          FROM     fact_orders AS f
                   INNER JOIN
                   dim_customer AS c
                   ON f.customer_key = c.customer_key
          WHERE    c.customer_key <> 0
          GROUP BY c.gender
          UNION ALL
          SELECT   'Income Band',
                   c.income_band,
                   COUNT(*),
                   COUNT(DISTINCT CASE WHEN f.customer_key <> 0 THEN f.customer_key END),
                   SUM(CASE WHEN f.revenue_analysis_flag = 1 THEN f.product_price_gbp ELSE 0 END),
                   SUM(CASE WHEN f.revenue_analysis_flag = 1 THEN 1 ELSE 0 END)
          FROM     fact_orders AS f
                   INNER JOIN
                   dim_customer AS c
                   ON f.customer_key = c.customer_key
          WHERE    c.customer_key <> 0
          GROUP BY c.income_band)
SELECT   demographic_type,
         demographic_segment,
         total_orders,
         total_customers,
         CAST (total_revenue_gbp AS DECIMAL (18, 2)) AS total_revenue_gbp,
         CAST (total_revenue_gbp / NULLIF (revenue_eligible_orders, 0) AS DECIMAL (18, 2)) AS average_order_value_gbp,
         CAST (total_revenue_gbp / NULLIF (total_customers, 0) AS DECIMAL (18, 2)) AS revenue_per_customer_gbp
FROM     demographic_performance
ORDER BY demographic_type, total_revenue_gbp DESC;


/* Q4: How does performance vary across regions and markets? */

SELECT   f.marketing_channel,
         f.purchase_platform,
         COUNT(*) AS total_orders,
         COUNT(DISTINCT CASE WHEN f.customer_key <> 0 THEN f.customer_key END) AS total_customers,
         CAST (SUM(CASE WHEN f.revenue_analysis_flag = 1 THEN f.product_price_gbp ELSE 0 END) AS DECIMAL (18, 2)) AS total_revenue_gbp,
         CAST (SUM(CASE WHEN f.revenue_analysis_flag = 1 THEN f.product_price_gbp ELSE 0 END) / NULLIF (SUM(CASE WHEN f.revenue_analysis_flag = 1 THEN 1 ELSE 0 END), 0) AS DECIMAL (18, 2)) AS average_order_value_gbp,
         CAST (100.0 * SUM(CASE WHEN f.refund_flag = 1 THEN 1 ELSE 0 END) / NULLIF (COUNT(*), 0) AS DECIMAL (6, 2)) AS refund_rate_pct
FROM     fact_orders AS f
GROUP BY f.marketing_channel, f.purchase_platform
ORDER BY total_revenue_gbp DESC, total_orders DESC;


/* Q5: Where are refunds concentrated, and which products or customer groups have the highest refund rates?
*/

SELECT   p.product_category,
         p.product_name,
         COUNT(*) AS total_orders,
         SUM(CASE WHEN f.refund_flag = 1 THEN 1 ELSE 0 END) AS refunded_orders,
         CAST (100.0 * SUM(CASE WHEN f.refund_flag = 1 THEN 1 ELSE 0 END) / NULLIF (COUNT(*), 0) AS DECIMAL (6, 2)) AS refund_rate_pct,
         CAST (SUM(CASE WHEN f.refund_flag = 1
                             AND f.revenue_analysis_flag = 1 THEN f.product_price_gbp ELSE 0 END) AS DECIMAL (18, 2)) AS refunded_revenue_gbp,
         CAST (SUM(CASE WHEN f.revenue_analysis_flag = 1 THEN f.product_price_gbp ELSE 0 END) AS DECIMAL (18, 2)) AS total_revenue_gbp
FROM     fact_orders AS f
         INNER JOIN
         dim_product AS p
         ON f.product_key = p.product_key
WHERE    p.product_key <> 0
GROUP BY p.product_category, p.product_name
ORDER BY refunded_revenue_gbp DESC, refund_rate_pct DESC;


 /*  Q6: What trends and patterns can be identified to support future commercial decision-making? */

WITH     country_year_performance
AS       (SELECT   r.region_name,
                   r.country_code,
                   YEAR(d.date_value) AS calendar_year,
                   COUNT(*) AS total_orders,
                   COUNT(DISTINCT CASE WHEN f.customer_key <> 0 THEN f.customer_key END) AS total_customers,
                   SUM(CASE WHEN f.revenue_analysis_flag = 1 THEN f.product_price_gbp ELSE 0 END) AS total_revenue_gbp,
                   SUM(CASE WHEN f.revenue_analysis_flag = 1 THEN 1 ELSE 0 END) AS revenue_eligible_orders,
                   SUM(CASE WHEN f.refund_flag = 1 THEN 1 ELSE 0 END) AS refunded_orders
          FROM     fact_orders AS f
                   INNER JOIN
                   dim_region AS r
                   ON f.region_key = r.region_key
                   INNER JOIN
                   dim_date AS d
                   ON f.purchase_date_key = d.date_key
          WHERE    f.date_analysis_flag = 1
                   AND r.region_key <> 0
          GROUP BY r.region_name, r.country_code, YEAR(d.date_value)),
         country_comparison
AS       (SELECT region_name,
                 country_code,
                 calendar_year,
                 total_orders,
                 total_customers,
                 total_revenue_gbp,
                 revenue_eligible_orders,
                 refunded_orders,
                 LAG(total_revenue_gbp) OVER (PARTITION BY country_code ORDER BY calendar_year) AS previous_year_revenue_gbp,
                 ROW_NUMBER() OVER (PARTITION BY country_code ORDER BY calendar_year DESC) AS latest_year_rank
          FROM   country_year_performance)
SELECT   region_name,
         country_code,
         calendar_year AS latest_year,
         total_orders,
         total_customers,
         CAST (total_revenue_gbp AS DECIMAL (18, 2)) AS total_revenue_gbp,
         CAST (total_revenue_gbp / NULLIF (revenue_eligible_orders, 0) AS DECIMAL (18, 2)) AS average_order_value_gbp,
         CAST (100.0 * refunded_orders / NULLIF (total_orders, 0) AS DECIMAL (6, 2)) AS refund_rate_pct,
         CAST (100.0 * (total_revenue_gbp - previous_year_revenue_gbp) / NULLIF (previous_year_revenue_gbp, 0) AS DECIMAL (7, 2)) AS year_on_year_revenue_growth_pct
FROM     country_comparison
WHERE    latest_year_rank = 1
ORDER BY total_revenue_gbp DESC, year_on_year_revenue_growth_pct DESC;