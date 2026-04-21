*/
-- ============================================================================
Quality Checks
-- ============================================================================
Script Purpose:
		This script perfromrs quality checks to validate the integrity, consistency,
		and accuracy of the Gold layer. These checks ensure:
		- Uniqueness of surrogate keys in dimension tables
		- Referential integrity between fact and dimension tables
		= Validation of relationships in the data model for analytical purposes

Usage Notes:
	- Run these checks after data loading Silver Layer
	- Investigate and resolve any discrepencies found during the checks
-- ============================================================================
*/

--Fixing descrepencies between the 2 sources for Gender
SELECT DISTINCT
	ci.cst_gndr,
	ca.gen,
	CASE WHEN ci.cst_gndr != 'N/A' THEN ci.cst_gndr -- CRM is the Master for gender
	ELSE COALESCE (ca.gen, 'N/A')
    END AS new_gen
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON		  ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON		  ci.cst_key = la.cid
ORDER BY 1, 2

SELECT DISTINCT gender from gold.dim_customers



select * from gold.fact_sales

SELECT *
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
WHERE p.product_key IS NULL



-- Checking for Duplicates:
SELECT cst_id, COUNT(*) FROM
	(SELECT
		ci.cst_id,
		ci.cst_key,
		ci.cst_firstname,
		ci.cst_lastname,
		ci.cst_material_status,
		ci.cst_gndr,
		ci.cst_create_data,
		ca.bdate,
		ca.gen,
		la.cntry
	FROM silver.crm_cust_info ci
	LEFT JOIN silver.erp_cust_az12 ca
	ON		  ci.cst_key = ca.cid
	LEFT JOIN silver.erp_loc_a101 la
	ON		  ci.cst_key = la.cid
)t GROUP BY cst_id
HAVING COUNT(*) > 1
*/
--==================================================


-- NEXT FIX:
SELECT
	ci.cst_id,
	ci.cst_key,
	ci.cst_firstname,
	ci.cst_lastname,
	ci.cst_material_status,
	--Fixing descrepencies between the 2 sources for Gender
	CASE WHEN ci.cst_gndr != 'N/A' THEN ci.cst_gndr -- CRM is the Master for gender
		 ELSE COALESCE (ca.gen, 'N/A')
    END AS new_gen,
	ci.cst_create_data,
	ca.bdate,	
	la.cntry
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON		  ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON		  ci.cst_key = la.cid
*/

--===========================================================================================


-- NEXT FIX: Clean up the column names and use proper snake-case names
SELECT
	ci.cst_id AS customer_id,
	ci.cst_key AS customer_number,
	ci.cst_firstname AS first_name,
	ci.cst_lastname AS last_name,
	la.cntry AS country,
	ci.cst_material_status AS marital_status,
	--Fixing descrepencies between the 2 sources for Gender
	CASE WHEN ci.cst_gndr != 'N/A' THEN ci.cst_gndr -- CRM is the Master for gender
		 ELSE COALESCE (ca.gen, 'N/A')
    END AS gender,
	ca.bdate AS birthdate,
	ci.cst_create_data AS create_date
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON		  ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON		  ci.cst_key = la.cid
*/
