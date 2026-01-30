/*
Quality check script
This script performs various quality checks for data accuracy, consistency across all three layers.
*/

--1. raw layer check
-- row count check
select 'raw_erp.invoices' as table_name, count(*) as row_count
from raw_erp.invoices
union all
select 'raw_erp.purchase_orders' ,  count(*) from raw_erp.purchase_orders
union all
select 'raw_vendor.vendors', count(*) from raw_vendor.vendors
union all
select 'raw_contract.contracts', count(*) from raw_contract.contracts
union all
select 'raw_finance.budget_forecast', count(*) from raw_finance.budget_forecast

--should be zero

select count(*) as null_invoice_amounts
from raw_erp.invoices
where invoice_amount is null

select count(*) as null_vendor_ids
from raw_erp.invoices
where vendor_id is null

-- status values, should be posted and cancelled
select distinct invoice_status
from raw_erp.invoices

--2. dimension layer check
--should be zero
select vendor_id, count(*)
from dim.dim_vendor
group by vendor_id
having count(*) >1;

select category_id, count(*)
from dim.dim_category
group by category_id
having count(*) >1;

--should be zero
select count(*) as orphan_vendors
from dim.dim_vendor
where vendor_key is null;


--date dimension, date dimension should include invoice date
select
	min(invoice_Date) as min_invoice_date,
	max(invoice_Date) as max_invoice_date
from raw_erp.invoices;

select
	min(full_date) as min_date_dim,
	max(full_date) as max_date_dim
from dim.dim_date;

--3. fact table check
--should be >= posted invoice line count
select count(*) as fact_rows
from fact.fact_procurement_spend

-- erp vs fact , variance should be zero
SELECT
    (SELECT SUM(invoice_amount)
     FROM raw_erp.invoices
     WHERE invoice_status = 'POSTED') AS erp_total,

    (SELECT SUM(spend_amount)
     FROM fact.fact_procurement_spend) AS fact_total,

    ABS(
        (SELECT SUM(invoice_amount)
         FROM raw_erp.invoices
         WHERE invoice_status = 'POSTED')
        -
        (SELECT SUM(spend_amount)
         FROM fact.fact_procurement_spend)
    ) AS variance;

-- duplicate fact records, shoul be zero
SELECT invoice_line_id, COUNT(*)
FROM fact.fact_procurement_spend
GROUP BY invoice_line_id
HAVING COUNT(*) > 1;

--negative spend? should be zero
SELECT COUNT(*) AS invalid_spend_rows
FROM fact.fact_procurement_spend
WHERE spend_amount <= 0;

--4.budget vs actual check
-- missing budget rows, should be zero
SELECT COUNT(*) AS missing_budget
FROM fact.fact_budget_vs_actual
WHERE budgeted_spend IS NULL;

--5. semantic layer check
SELECT COUNT(*) FROM analytics.vw_procurement_spend;
SELECT COUNT(*) FROM analytics.vw_budget_vs_actual;
SELECT COUNT(*) FROM analytics.vw_contract_compliance;

-- KPI Consistency (View vs Fact), both table should match
SELECT
    (SELECT SUM(spend_amount)
     FROM fact.fact_procurement_spend) AS fact_total,

    (SELECT SUM(spend_amount)
     FROM analytics.vw_procurement_spend) AS view_total;
