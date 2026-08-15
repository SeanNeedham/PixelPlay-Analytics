/*
pixelplay gaming analytics
region dimension

create the region dimension from cleaned region data
*/
-- remove old table
DROP TABLE IF EXISTS dim_region;

-- create region dimension
SELECT TOP (0) IDENTITY (INT, 1, 1) AS region_key,
               country_code,
               region_name
INTO   dim_region
FROM   region_clean;

-- add unknown region
SET IDENTITY_INSERT dim_region ON;

INSERT  INTO dim_region (region_key, country_code, region_name)
VALUES                 (0, 'UNKNOWN', 'Unknown');

SET IDENTITY_INSERT dim_region OFF;

-- add valid regions
INSERT INTO dim_region (country_code, region_name)
SELECT country_code,
       region_name
FROM   region_clean
WHERE  country_code IS NOT NULL
       AND TRIM(country_code) <> ''
       AND UPPER(TRIM(country_code)) <> 'UNKNOWN';

-- set country code datatype
ALTER TABLE dim_region ALTER COLUMN country_code VARCHAR (10) NOT NULL;

-- add primary key
ALTER TABLE dim_region
    ADD CONSTRAINT PK_dim_region PRIMARY KEY (region_key);

-- keep country codes unique
ALTER TABLE dim_region
    ADD CONSTRAINT UQ_dim_region_country_code UNIQUE (country_code);
