/*
pixelplay gaming analytics
customer dimension

create the customer dimension from cleaned customer data
*/

-- remove old table
DROP TABLE IF EXISTS dim_customer;

-- create customer dimension
SELECT TOP (0) IDENTITY (INT, 1, 1) AS customer_key,
               user_id,
               age,
               age_band,
               gender,
               country_code,
               loyalty_tier,
               customer_segment,
               email_opt_in,
               device_preference,
               income_band,
               household_size,
               signup_date,
               last_updated_date
INTO   dim_customer
FROM   customers_clean;

-- add unknown customer
SET IDENTITY_INSERT dim_customer ON;

INSERT  INTO dim_customer (customer_key, user_id, age, age_band, gender, country_code, loyalty_tier, customer_segment, email_opt_in, device_preference, income_band, household_size, signup_date, last_updated_date)
VALUES                   (0, 'UNK', NULL, 'Unknown', 'Unknown', 'UNKNOWN', 'Unknown', 'Unknown', 'Unknown', 'Unknown', 'Unknown', NULL, NULL, NULL);

SET IDENTITY_INSERT dim_customer OFF;

-- add valid customers
INSERT INTO dim_customer (user_id, age, age_band, gender, country_code, loyalty_tier, customer_segment, email_opt_in, device_preference, income_band, household_size, signup_date, last_updated_date)
SELECT user_id,
       age,
       age_band,
       gender,
       country_code,
       loyalty_tier,
       customer_segment,
       email_opt_in,
       device_preference,
       income_band,
       household_size,
       signup_date,
       last_updated_date
FROM   customers_clean
WHERE  user_id IS NOT NULL
       AND TRIM(user_id) <> ''
       AND UPPER(TRIM(user_id)) <> 'UNKNOWN';

-- set customer id datatype
ALTER TABLE dim_customer ALTER COLUMN user_id VARCHAR (100) NOT NULL;

-- add primary key
ALTER TABLE dim_customer
    ADD CONSTRAINT PK_dim_customer PRIMARY KEY (customer_key);

-- keep customer ids unique
ALTER TABLE dim_customer
    ADD CONSTRAINT UQ_dim_customer_user_id UNIQUE (user_id);
