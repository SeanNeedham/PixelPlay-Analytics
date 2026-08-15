/*
pixelplay gaming analytics
region data cleaning

clean and standardise region data before modelling
*/
-- clean country code
SELECT DISTINCT CASE WHEN COUNTRY_CODE IS NULL
                          OR TRIM(COUNTRY_CODE) = ''
                          OR UPPER(TRIM(COUNTRY_CODE)) IN ('ZZ', 'UNKNOWN', 'N/A') THEN 'UNKNOWN' ELSE UPPER(TRIM(COUNTRY_CODE)) END AS country_code,
                -- fix unknown regions using country code
                CASE WHEN (REGION IS NULL
                           OR TRIM(REGION) = ''
                           OR UPPER(TRIM(REGION)) IN ('X.X', 'X.X.', 'UNKNOWN', 'UNKNOWN REGION', 'N/A'))
                          AND UPPER(TRIM(COUNTRY_CODE)) IN ('US', 'USA') THEN 'NA' WHEN (REGION IS NULL
                                                                                         OR TRIM(REGION) = ''
                                                                                         OR UPPER(TRIM(REGION)) IN ('X.X', 'X.X.', 'UNKNOWN', 'UNKNOWN REGION', 'N/A'))
                                                                                        AND UPPER(TRIM(COUNTRY_CODE)) IN ('IE', 'IL', 'FR', 'LB') THEN 'EMEA' WHEN UPPER(TRIM(REGION)) IN ('NA', 'NORTH AMERICA') THEN 'NA' WHEN REGION IS NOT NULL
                                                                                                                                                                                                                                 AND TRIM(REGION) <> '' THEN UPPER(TRIM(REGION)) ELSE 'Unknown' END AS region_name
INTO   region_clean
FROM   region;