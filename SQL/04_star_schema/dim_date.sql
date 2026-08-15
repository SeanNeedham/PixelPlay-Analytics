/*
pixelplay gaming analytics
date dimension

create the date dimension from cleaned order dates
*/
-- remove old table
DROP TABLE IF EXISTS dim_date;

-- create date dimension
CREATE TABLE dim_date (
    date_key INT NOT NULL,
    date_value DATE NULL,
    year_number SMALLINT NULL,
    quarter_number TINYINT NULL,
    quarter_name VARCHAR (2) NULL,
    month_number TINYINT NULL,
    month_name VARCHAR (10) NULL,
    year_month CHAR (7) NULL,
    year_month_sort INT NULL,
    iso_week_number TINYINT NULL,
    day_of_month TINYINT NULL,
    day_name VARCHAR (10) NULL,
    day_of_week_number TINYINT NULL,
    is_weekend BIT NULL,
    CONSTRAINT PK_dim_date PRIMARY KEY (date_key)
);

-- add unknown date
INSERT  INTO dim_date (date_key, date_value, year_number, quarter_number, quarter_name, month_number, month_name, year_month, year_month_sort, iso_week_number, day_of_month, day_name, day_of_week_number, is_weekend)
VALUES               (0, NULL, NULL, NULL, 'NA', NULL, 'Unknown', NULL, NULL, NULL, NULL, 'Unknown', NULL, NULL);

-- get reporting date range
DECLARE @start_date AS DATE;

DECLARE @end_date AS DATE;

SELECT @start_date = MIN(purchase_date),
       @end_date = MAX(purchase_date)
FROM   orders_clean
WHERE  purchase_date IS NOT NULL;

-- set monday as day one
SET DATEFIRST 1;

-- build date list
WITH date_list
AS   (SELECT @start_date AS date_value
      UNION ALL
      SELECT DATEADD(DAY, 1, date_value)
      FROM   date_list
      WHERE  date_value < @end_date)
INSERT INTO dim_date (date_key, date_value, year_number, quarter_number, quarter_name, month_number, month_name, year_month, year_month_sort, iso_week_number, day_of_month, day_name, day_of_week_number, is_weekend)
SELECT YEAR(date_value) * 10000 + MONTH(date_value) * 100 + DAY(date_value) AS date_key,
       date_value,
       YEAR(date_value) AS year_number,
       DATEPART(QUARTER, date_value) AS quarter_number,
       CONCAT('Q', DATEPART(QUARTER, date_value)) AS quarter_name,
       MONTH(date_value) AS month_number,
       DATENAME(MONTH, date_value) AS month_name,
       CONVERT (CHAR (7), date_value, 126) AS year_month,
       YEAR(date_value) * 100 + MONTH(date_value) AS year_month_sort,
       DATEPART(ISO_WEEK, date_value) AS iso_week_number,
       DAY(date_value) AS day_of_month,
       DATENAME(WEEKDAY, date_value) AS day_name,
       DATEPART(WEEKDAY, date_value) AS day_of_week_number,
       CASE WHEN DATEPART(WEEKDAY, date_value) IN (6, 7) THEN 1 ELSE 0 END AS is_weekend
FROM   date_list
OPTION (MAXRECURSION 0);
