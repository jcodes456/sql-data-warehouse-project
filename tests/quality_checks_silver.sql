-- Quality Checks
-- Check for NULLs or DUPLICATEs in PRIMARY KEY
-- Expectation: No Results

SELECT
prd_id,
COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT (*) > 1 OR prd_id IS NULL

-- Check for Unwanted Spaces, NULLs, etc.
-- Expectation: No Results
SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)


-- Check for NULLS or Negative Numbers
-- Expectation: No Results
SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost <0 OR prd_cost IS NULL

-- Data Standardization & Consistency
-- Expectation: No Results
SELECT DISTINCT prd_line
FROM silver.crm_prd_info

=============================================================================

-- Check for Invalid Dates

SELECT
NULLIF (sls_order_dt,0) sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <=0 OR LEN (sls_order_dt) != 8



SELECT
NULLIF (sls_ship_dt,0) sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_ship_dt <=0
OR LEN (sls_ship_dt) != 8
OR sls_ship_dt > 20500101
OR sls_ship_dt < 19000101

-- Check for Invalid Date Orders

SELECT
*
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt

-- Check Data Consistency: Between Sales, Qty, and Price
-- >> Sales = Qty * Price
-- >> Values must not be NULL, zero, or negative
  
 --  V1
SELECT DISTINCT
sls_sales,
sls_quantity,
sls_sales_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_sales_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_sales_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_sales_price <= 0
ORDER BY sls_sales, sls_quantity, sls_sales_price
  
-- ---------------------------------------------

-- V2
SELECT DISTINCT
sls_sales AS old_sls_sales,
sls_quantity,
sls_sales_price AS old_sls_sales_price,

CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_sales_price)
		THEN sls_quantity * ABS(sls_sales_price)
	ELSE sls_sales
END AS sls_sales,

CASE WHEN sls_sales_price IS NULL OR sls_sales_price <= 0
		THEN sls_sales / NULLIF (sls_quantity, 0)
	ELSE sls_sales_price
END AS sls_sales_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_sales_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_sales_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_sales_price <= 0
ORDER BY sls_sales, sls_quantity, sls_sales_price
