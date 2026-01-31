/*
Stored Procedure: It will load the Silver layer from Bronze layer

---
Script Purpose:
          This stored procedure performs the ETL(Extract, Transform, load) process to populate silver schema tables from the bronze schema.
      Actions performed:
      - Truncates silver tables.
      - Inserts transformed and cleansed data from bronze to silver tables.
*/

--execute the stored procedure instead of running multiple queries
EXEC sp.load_silver
          
--create stored procedure for loading the bronze layer
CREATE OR ALTER PROCEDURE sp.load_silver AS
BEGIN
      -- dimesion tables
      -- i. vendor dimension
      
                    TRUNCATE TABLE dim.dim_vendor;
                    INSERT INTO dim.dim_vendor
                    SELECT
                        UPPER(LTRIM(RTRIM(v.vendor_id)))              AS vendor_id,
                        NULLIF(LTRIM(RTRIM(v.vendor_name)), '')       AS vendor_name,
                        UPPER(NULLIF(LTRIM(RTRIM(v.vendor_tier)), '')) AS vendor_tier,
                        CASE 
                            WHEN UPPER(LTRIM(RTRIM(v.region_id))) IN ('APAC','EMEA','NA','LATAM')
                                THEN UPPER(LTRIM(RTRIM(v.region_id)))
                            ELSE 'UNKNOWN'
                        END                                           AS region_id,
                        CASE 
                            WHEN UPPER(v.active_flag) = 'Y' THEN 1
                            ELSE 0
                        END                                           AS active_flag
                    FROM raw_vendor.vendors v;
                    
                    
                    select *
                    from dim.dim_vendor
          
      -- ii. region dimension


                              TRUNCATE TABLE dim.dim_region;
      
                              INSERT INTO dim.dim_region
                              SELECT DISTINCT
                                  region_id,
                                  CASE region_id
                                      WHEN 'APAC' THEN 'Asia Pacific'
                                      WHEN 'EMEA' THEN 'Europe Middle East Africa'
                                      WHEN 'NA'   THEN 'North America'
                                      WHEN 'LATAM'THEN 'Latin America'
                                      ELSE 'Unknown'
                                  END AS region_name
                              FROM (
                                  SELECT UPPER(LTRIM(RTRIM(region_id))) AS region_id
                                  FROM raw_vendor.vendors
                              ) r;
                              
                              select *
                              from dim.dim_region
      
      -- iii. category dimension
      
                              TRUNCATE TABLE dim.dim_category;
                              
                              INSERT INTO dim.dim_category
                              SELECT DISTINCT
                                  UPPER(LTRIM(RTRIM(category_id))) AS category_id
                              FROM raw_erp.purchase_orders
                              WHERE category_id IS NOT NULL;
                              
                              select *
                              from dim.dim_category
                                    
      -- iv. date dimension
      
                                    TRUNCATE TABLE dim.dim_date;
                              
                              
                                    INSERT INTO dim.dim_date
                                    SELECT DISTINCT
                                        CONVERT(INT, FORMAT(d, 'yyyyMMdd')) AS date_key,
                                        d,
                                        YEAR(d),
                                        MONTH(d),
                                        DATENAME(month, d),
                                        DATEPART(quarter, d)
                                    FROM (
                                        SELECT invoice_date AS d FROM raw_erp.invoices
                                        UNION
                                        SELECT contract_start FROM raw_contract.contracts
                                    ) x;
                              
                                        select *
                                        from dim.dim_date

      -- facts tables
      
      -- i. procurement spend
      
                                        -- grain: One record per invoice line per day
                                        TRUNCATE TABLE fact.fact_procurement_spend;
                                        
                                        INSERT INTO fact.fact_procurement_spend (
                                            invoice_id,
                                            invoice_line_id,
                                            vendor_key,
                                            category_key,
                                            region_key,
                                            date_key,
                                            contract_id,
                                            spend_amount,
                                            is_contract_compliant
                                        )
                                        SELECT
                                            UPPER(LTRIM(RTRIM(i.invoice_id)))        AS invoice_id,
                                            UPPER(LTRIM(RTRIM(i.invoice_line_id)))  AS invoice_line_id,
                                        
                                            dv.vendor_key,
                                            dc.category_key,
                                            dr.region_key,
                                            dd.date_key,
                                        
                                            c.contract_id,
                                        
                                            CASE
                                                WHEN i.invoice_amount IS NULL OR i.invoice_amount < 0
                                                    THEN 0
                                                ELSE i.invoice_amount
                                            END AS spend_amount,
                                        
                                            CASE
                                                WHEN c.contract_id IS NOT NULL THEN 1
                                                ELSE 0
                                            END AS is_contract_compliant
                                        
                                        FROM raw_erp.invoices i
                                        
                                        LEFT JOIN raw_erp.purchase_orders p
                                            ON UPPER(LTRIM(RTRIM(i.po_id))) = UPPER(LTRIM(RTRIM(p.po_id)))
                                        
                                        LEFT JOIN dim.dim_vendor dv
                                            ON dv.vendor_id = UPPER(LTRIM(RTRIM(i.vendor_id)))
                                        
                                        LEFT JOIN dim.dim_category dc
                                            ON dc.category_id = UPPER(LTRIM(RTRIM(p.category_id)))
                                        
                                        LEFT JOIN dim.dim_region dr
                                            ON dr.region_id = UPPER(LTRIM(RTRIM(p.region_id)))
                                        
                                        JOIN dim.dim_date dd
                                            ON dd.full_date = i.invoice_date
                                        
                                        LEFT JOIN raw_contract.contracts c
                                            ON UPPER(LTRIM(RTRIM(p.vendor_id)))   = UPPER(LTRIM(RTRIM(c.vendor_id)))
                                           AND UPPER(LTRIM(RTRIM(p.category_id))) = UPPER(LTRIM(RTRIM(c.category_id)))
                                           AND i.invoice_date BETWEEN c.contract_start AND c.contract_end
                                        
                                        -- Data quality gate
                                        WHERE i.invoice_id IS NOT NULL
                                          AND i.invoice_line_id IS NOT NULL
                                          AND category_key is not null
                                          and region_key is not null
                                          and vendor_key is not null;
                                        
                                        select *
                                        from fact.fact_procurement_spend;
      
      
      -- ii. load budget vs actual fact
      
                                        TRUNCATE TABLE fact.fact_budget_vs_actual;
                                        
                                        INSERT INTO fact.fact_budget_vs_actual (
                                            category_key,
                                            region_key,
                                            date_key,
                                            budgeted_spend,
                                            actual_spend
                                        )
                                        SELECT
                                            dc.category_key,
                                            dr.region_key,
                                            dd.date_key,
                                        
                                            ISNULL(b.budgeted_spend, 0)        AS budgeted_spend,
                                            ISNULL(SUM(f.spend_amount), 0)     AS actual_spend
                                        
                                        FROM raw_finance.budget_forecast b
                                        
                                        -- Date resolution (month grain)
                                        JOIN dim.dim_date dd
                                            ON dd.full_date = b.month
                                        
                                        -- Dimension lookups (natural → surrogate)
                                        LEFT JOIN dim.dim_category dc
                                            ON dc.category_id = UPPER(LTRIM(RTRIM(b.category_id)))
                                        
                                        LEFT JOIN dim.dim_region dr
                                            ON dr.region_id = UPPER(LTRIM(RTRIM(b.region_id)))
                                        
                                        -- Actual spend from fact table (already keyed)
                                        LEFT JOIN fact.fact_procurement_spend f
                                            ON f.category_key = dc.category_key
                                           AND f.region_key   = dr.region_key
                                           AND f.date_key     = dd.date_key
                                        
                                        GROUP BY
                                            dc.category_key,
                                            dr.region_key,
                                            dd.date_key,
                                            b.budgeted_spend;
                                        
                                        
                                        select *
                                        from fact.fact_budget_vs_actual;

-- iii). load fact.fact_contract_savings

                                        -- grain: One record per contract per month
                                        
                                        TRUNCATE TABLE fact.fact_contract_savings;
                                        
                                        INSERT INTO fact.fact_contract_savings
                                        SELECT
                                            UPPER(LTRIM(RTRIM(c.contract_id)))        AS contract_id,
                                            d.date_key                                AS date_key,
                                        
                                            ROUND(
                                                ISNULL(c.negotiated_savings, 0) /
                                                NULLIF(DATEDIFF(MONTH, c.contract_start, c.contract_end) + 1, 0),
                                                2
                                            )                                         AS projected_savings,
                                            -- Realized savings & it comes from actual transactional behavior so it's zero.
                                            0                                         AS realized_savings
                                        
                                        FROM raw_contract.contracts c
                                        
                                        JOIN dim.dim_date d
                                            ON d.full_date >= DATEFROMPARTS(YEAR(c.contract_start), MONTH(c.contract_start), 1)
                                           AND d.full_date <= DATEFROMPARTS(YEAR(c.contract_end),   MONTH(c.contract_end),   1)
                                           AND d.full_date = DATEFROMPARTS(YEAR(d.full_date), MONTH(d.full_date), 1);
                                        
                                           
                                        select *
                                        from fact.fact_contract_savings;

END
