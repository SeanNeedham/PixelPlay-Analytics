/*
pixelplay gaming analytics
product dimension

create the product dimension from cleaned product data
*/
-- remove old table
DROP TABLE IF EXISTS dim_product;

-- create product dimension
SELECT TOP (0) IDENTITY (INT, 1, 1) AS product_key,
               product_id,
               product_name,
               product_category,
               base_price_gbp,
               launch_year
INTO   dim_product
FROM   products_clean;

-- add unknown product
SET IDENTITY_INSERT dim_product ON;

INSERT  INTO dim_product (product_key, product_id, product_name, product_category, base_price_gbp, launch_year)
VALUES                  (0, 'UNKN', 'Unknown Product', 'Unknown', 0.00, 0);

SET IDENTITY_INSERT dim_product OFF;

-- add valid products
INSERT INTO dim_product (product_id, product_name, product_category, base_price_gbp, launch_year)
SELECT product_id,
       product_name,
       product_category,
       base_price_gbp,
       launch_year
FROM   products_clean
WHERE  product_id IS NOT NULL
       AND TRIM(product_id) <> ''
       AND UPPER(TRIM(product_id)) <> 'UNKN';

-- add primary key
ALTER TABLE dim_product
    ADD CONSTRAINT PK_dim_product PRIMARY KEY (product_key);

-- keep product ids unique
ALTER TABLE dim_product
    ADD CONSTRAINT UQ_dim_product_product_id UNIQUE (product_id);
