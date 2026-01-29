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
      
      INSERT INTO dim.dim_vendor (vendor_id, vendor_name, vendor_tier, region_id, active_flag)
      SELECT DISTINCT
          vendor_id,
          vendor_name,
          vendor_tier,
          region_id,
          active_flag
      FROM raw_vendor.vendors;
      
      -- ii. region dimension
      TRUNCATE TABLE dim.dim_region;
      
      insert into dim.dim_region(region_id, region_name)
      select distinct
      region_id,
      region_id
      from raw_vendor.vendors
      
      -- iii. category dimension
      
      TRUNCATE TABLE dim.dim_category;
      
      insert into dim.dim_category (category_id, category_name, category_manager)
      values
      ('CAT01', 'Raw Materials', 'John Smith'),
      ('CAT02', 'Packaging', 'Anita Rao'),
      ('CAT03', 'Logistics', 'Michael Chen');
      
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
      
      -- facts tables
      
      -- i. procurement spend
      
      TRUNCATE TABLE fact.fact_procurement_spend;
      
      INSERT INTO fact.fact_procurement_spend
      SELECT
          invoice_line_id,
          vendor_key,
          category_key,
          region_key,
          date_key,
          contract_id,
          invoice_amount,
          is_contract_compliant
      FROM (
          SELECT
              i.invoice_line_id,
              v.vendor_key,
              c.category_key,
              r.region_key,
              d.date_key,
              ct.contract_id,
              i.invoice_amount,
              CASE 
                  WHEN ct.contract_id IS NOT NULL THEN 1 ELSE 0 
              END AS is_contract_compliant,
              ROW_NUMBER() OVER (
                  PARTITION BY i.invoice_line_id
                  ORDER BY 
                      i.invoice_date DESC,
                      ct.contract_start DESC
              ) AS rn
          FROM raw_erp.invoices i
          JOIN raw_erp.purchase_orders po
              ON i.po_id = po.po_id
          JOIN dim.dim_vendor v
              ON i.vendor_id = v.vendor_id
          JOIN dim.dim_category c
              ON po.category_id = c.category_id
          JOIN dim.dim_region r
              ON po.region_id = r.region_id
          JOIN dim.dim_date d
              ON i.invoice_date = d.full_date
          LEFT JOIN raw_contract.contracts ct
              ON i.vendor_id = ct.vendor_id
             AND po.category_id = ct.category_id
             AND i.invoice_date BETWEEN ct.contract_start AND ct.contract_end
          WHERE i.invoice_status = 'POSTED'
      ) x
      WHERE rn = 1;
      
      
      -- ii. load budget vs actual fact
      
      TRUNCATE TABLE fact.fact_budget_vs_actual;
      
      INSERT INTO fact.fact_budget_vs_actual
      SELECT
          c.category_key,
          r.region_key,
          d.date_key,
          bf.budgeted_spend,
          SUM(f.spend_amount) AS actual_spend
      FROM raw_finance.budget_forecast bf
      JOIN dim.dim_category c ON bf.category_id = c.category_id
      JOIN dim.dim_region r ON bf.region_id = r.region_id
      JOIN dim.dim_date d ON bf.month = d.full_date
      LEFT JOIN fact.fact_procurement_spend f
          ON f.category_key = c.category_key
          AND f.region_key = r.region_key
      GROUP BY
          c.category_key, r.region_key, d.date_key, bf.budgeted_spend;
END
