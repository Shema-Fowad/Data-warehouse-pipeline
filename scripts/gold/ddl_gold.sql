/*
This script created analytics schema and views to import into power BI.
    Usage:
    -These views can be queried directly for analytics and reporting.
*/

-- first let's creat a schema
create schema analytics;

-- View 1: procurement spend
IF OBJECT_ID('analytics.vw_procurement_spend', 'V') IS NOT NULL
    DROP VIEW analytics.vw_procurement_spend;
GO

CREATE VIEW analytics.vw_procurement_spend AS
SELECT
    d.full_date,
    d.year,
    d.month,
    d.month_name,
    v.vendor_name,
    v.vendor_tier,
    r.region_name,
    f.spend_amount,
    f.is_contract_compliant
FROM fact.fact_procurement_spend f
JOIN dim.dim_date d     ON f.date_key = d.date_key
JOIN dim.dim_vendor v   ON f.vendor_key = v.vendor_key
JOIN dim.dim_category c ON f.category_key = c.category_key
JOIN dim.dim_region r   ON f.region_key = r.region_key;

-- View 2: Spend Aggregation

IF OBJECT_ID('analytics.vw_spend_summary', 'V') IS NOT NULL
    DROP VIEW analytics.vw_spend_summary;
GO
  
CREATE VIEW analytics.vw_spend_summary AS
SELECT
    year,
    month,
    region_name,
    SUM(spend_amount) AS total_spend,
    AVG(CAST(is_contract_compliant AS FLOAT)) AS contract_compliance_rate
FROM analytics.vw_procurement_spend
GROUP BY
    year, month, region_name;

-- View 3: Budget vs Actual

IF OBJECT_ID('analytics.vw_budget_vs_actual', 'V') IS NOT NULL
    DROP VIEW analytics.vw_budget_vs_actual;
GO
  
CREATE VIEW analytics.vw_budget_vs_actual AS
SELECT
    d.year,
    d.month,
    r.region_name,
    f.budgeted_spend,
    f.actual_spend,
    f.budgeted_spend - f.actual_spend AS variance
FROM fact.fact_budget_vs_actual f
JOIN dim.dim_date d     ON f.date_key = d.date_key
JOIN dim.dim_category c ON f.category_key = c.category_key
JOIN dim.dim_region r   ON f.region_key = r.region_key;

-- View 4: Contract Compliance Drilldown

IF OBJECT_ID('analytics.vw_contract_compliance', 'V') IS NOT NULL
    DROP VIEW analytics.vw_contract_compliance;
GO
  
CREATE VIEW analytics.vw_contract_compliance AS
SELECT
    vendor_name,
    region_name,
    COUNT(*) AS total_transactions,
    SUM(CASE WHEN is_contract_compliant = 1 THEN 1 ELSE 0 END) AS compliant_transactions,
    AVG(CAST(is_contract_compliant AS FLOAT)) AS compliance_rate
FROM analytics.vw_procurement_spend
GROUP BY vendor_name, region_name;
