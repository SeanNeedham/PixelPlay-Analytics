/*
pixelplay gaming analytics
customer data cleaning

clean and standardise customer data before modelling
*/
WITH   cleaned_customers
AS     (SELECT -- clean user id
               NULLIF (LOWER(TRIM(USER_ID)), '') AS user_id,
               -- clean age
               CASE WHEN TRY_CAST (AGE AS DECIMAL (5, 1)) BETWEEN 13 AND 100 THEN CAST (TRY_CAST (AGE AS DECIMAL (5, 1)) AS INT) ELSE NULL END AS age,
               -- standardise gender
               CASE WHEN UPPER(TRIM(GENDER)) IN ('M', 'MALE') THEN 'Male' WHEN UPPER(TRIM(GENDER)) IN ('F', 'FEMALE') THEN 'Female' WHEN UPPER(TRIM(GENDER)) IN ('NON-BINARY', 'NON BINARY') THEN 'Non-binary' WHEN GENDER IS NULL
                                                                                                                                                                                                                    OR TRIM(GENDER) = ''
                                                                                                                                                                                                                    OR UPPER(TRIM(GENDER)) IN ('UNKNOWN', 'PREFER NOT TO SAY', 'OTHER') THEN 'Unknown' ELSE TRIM(GENDER) END AS gender,
               -- clean country code
               CASE WHEN COUNTRY_CODE IS NULL
                         OR TRIM(COUNTRY_CODE) = ''
                         OR UPPER(TRIM(COUNTRY_CODE)) IN ('ZZ', 'UNKNOWN', 'N/A') THEN 'UNKNOWN' ELSE UPPER(TRIM(COUNTRY_CODE)) END AS country_code,
               -- convert signup date
               CASE WHEN TRY_CONVERT (DATE, SIGNUP_DATE, 23) IS NOT NULL THEN TRY_CONVERT (DATE, SIGNUP_DATE, 23) WHEN TRY_CONVERT (DATE, SIGNUP_DATE, 103) IS NOT NULL THEN TRY_CONVERT (DATE, SIGNUP_DATE, 103) WHEN TRY_CONVERT (DATE, SIGNUP_DATE, 101) IS NOT NULL THEN TRY_CONVERT (DATE, SIGNUP_DATE, 101) WHEN TRY_CAST (SIGNUP_DATE AS INT) IS NOT NULL THEN DATEADD(DAY, TRY_CONVERT (INT, CONVERT (VARCHAR (50), SIGNUP_DATE)), DATEFROMPARTS(1899, 12, 30)) ELSE NULL END AS signup_date,
               -- standardise loyalty tier
               CASE WHEN UPPER(TRIM(LOYALTY_TIER)) = 'BRONZE' THEN 'Bronze' WHEN UPPER(TRIM(LOYALTY_TIER)) = 'SILVER' THEN 'Silver' WHEN UPPER(TRIM(LOYALTY_TIER)) = 'GOLD' THEN 'Gold' WHEN UPPER(TRIM(LOYALTY_TIER)) = 'PLATINUM' THEN 'Platinum' WHEN LOYALTY_TIER IS NULL
                                                                                                                                                                                                                                                         OR TRIM(LOYALTY_TIER) = '' THEN 'Unknown' ELSE TRIM(LOYALTY_TIER) END AS loyalty_tier,
               -- clean customer segment
               COALESCE (NULLIF (TRIM(CUSTOMER_SEGMENT), ''), 'Unknown') AS customer_segment,
               -- standardise device
               CASE WHEN LOWER(TRIM(DEVICE_PREFERENCE)) IN ('mobile', 'mobile app') THEN 'Mobile' WHEN LOWER(TRIM(DEVICE_PREFERENCE)) = 'desktop' THEN 'Desktop' WHEN LOWER(TRIM(DEVICE_PREFERENCE)) = 'tablet' THEN 'Tablet' WHEN LOWER(TRIM(DEVICE_PREFERENCE)) = 'console' THEN 'Console' WHEN DEVICE_PREFERENCE IS NULL
                                                                                                                                                                                                                                                                                                  OR TRIM(DEVICE_PREFERENCE) = ''
                                                                                                                                                                                                                                                                                                  OR LOWER(TRIM(DEVICE_PREFERENCE)) = 'unknown' THEN 'Unknown' ELSE TRIM(DEVICE_PREFERENCE) END AS device_preference,
               -- standardise email opt-in
               CASE WHEN UPPER(TRIM(EMAIL_OPT_IN)) IN ('TRUE', 'YES', 'Y', '1') THEN 'Yes' WHEN UPPER(TRIM(EMAIL_OPT_IN)) IN ('FALSE', 'NO', 'N', '0') THEN 'No' ELSE 'Unknown' END AS email_opt_in,
               -- clean income band
               CASE WHEN INCOME_BAND IS NULL
                         OR TRIM(INCOME_BAND) = ''
                         OR UPPER(TRIM(INCOME_BAND)) IN ('UNKNOWN', 'PREFER NOT TO SAY', 'N/A') THEN 'Unknown' ELSE TRIM(INCOME_BAND) END AS income_band,
               -- convert household size
               TRY_CAST (NULLIF (TRIM(HOUSEHOLD_SIZE), '') AS INT) AS household_size,
               -- convert last updated date
               COALESCE (TRY_CONVERT (DATE, CONVERT (VARCHAR (50), LAST_UPDATED_DATE), 23), TRY_CONVERT (DATE, CONVERT (VARCHAR (50), LAST_UPDATED_DATE), 103), TRY_CONVERT (DATE, CONVERT (VARCHAR (50), LAST_UPDATED_DATE), 101), CASE WHEN TRY_CONVERT (INT, CONVERT (VARCHAR (50), LAST_UPDATED_DATE)) BETWEEN 1 AND 60000 THEN DATEADD(DAY, TRY_CONVERT (INT, CONVERT (VARCHAR (50), LAST_UPDATED_DATE)), DATEFROMPARTS(1899, 12, 30)) END) AS last_updated_date,
               -- keep source quality flag
               NULLIF (TRIM(MESSY_DEMO_FLAG), '') AS source_quality_flag
        FROM   customer_info),
       standardised_customers
AS     (SELECT c.user_id,
               c.age,
               c.gender,
               c.country_code,
               COALESCE (r.region_name, 'Unknown') AS region_name,
               c.signup_date,
               c.loyalty_tier,
               c.customer_segment,
               c.device_preference,
               c.email_opt_in,
               c.income_band,
               c.household_size,
               c.last_updated_date,
               c.source_quality_flag,
               -- create age band
               CASE WHEN c.age IS NULL THEN 'Unknown' WHEN c.age < 18 THEN 'Under 18' WHEN c.age BETWEEN 18 AND 24 THEN '18-24' WHEN c.age BETWEEN 25 AND 34 THEN '25-34' WHEN c.age BETWEEN 35 AND 44 THEN '35-44' WHEN c.age BETWEEN 45 AND 54 THEN '45-54' WHEN c.age BETWEEN 55 AND 64 THEN '55-64' WHEN c.age >= 65 THEN '65+' ELSE 'Unknown' END AS age_band
        FROM   cleaned_customers AS c
               LEFT OUTER JOIN
               region_clean AS r
               ON c.country_code = r.country_code),
-- rank duplicate customers
       ranked_customers
AS     (SELECT user_id,
               age,
               age_band,
               gender,
               country_code,
               region_name,
               signup_date,
               loyalty_tier,
               customer_segment,
               device_preference,
               email_opt_in,
               income_band,
               household_size,
               last_updated_date,
               source_quality_flag,
               ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY CASE WHEN last_updated_date IS NULL THEN 1 ELSE 0 END, last_updated_date DESC) AS row_number
        FROM   standardised_customers
        -- remove missing user ids
        WHERE  user_id IS NOT NULL)
SELECT user_id,
       age,
       age_band,
       gender,
       country_code,
       region_name,
       signup_date,
       loyalty_tier,
       customer_segment,
       device_preference,
       email_opt_in,
       income_band,
       household_size,
       last_updated_date,
       source_quality_flag,
       -- flag incomplete records
       CASE WHEN age IS NULL THEN 'Missing Age' WHEN country_code = 'UNKNOWN' THEN 'Missing Country' WHEN signup_date IS NULL THEN 'Missing Signup Date' WHEN loyalty_tier = 'Unknown' THEN 'Missing Loyalty Tier' WHEN email_opt_in IS NULL THEN 'Missing Email Preference' ELSE 'Complete' END AS data_quality_status
INTO   customers_clean
FROM   ranked_customers
-- keep latest customer record
WHERE  row_number = 1;