# Naming Conventions – GSP Procurement Analytics

## Purpose
This document defines standardized naming conventions for the **GSP Procurement Analytics Data Warehouse**.  
The goal is to ensure **consistency, readability, scalability, and enterprisegrade design**, aligned with real-world analytics and data engineering practices.

---

## 1. General Naming Rules

- Use **snake_case** for all database objects
- Use **lowercase** for schemas, tables, columns
- Use **descriptive business names** (avoid cryptic abbreviations)
- Avoid SQL reserved keywords
- Be consistent across all layers (raw → analytics)

---

## 2. Database & Schemas

### Database
gsp_analytics


### Schemas by Layer
| Layer | Schema Name | Description |
|-----|------------|------------|
| Bronze / Raw | `raw_erp` | ERP purchase orders & invoices |
| Bronze / Raw | `raw_vendor` | Vendor master data |
| Bronze / Raw | `raw_contract` | Contract management data |
| Bronze / Raw | `raw_finance` | Budget & forecast data |
| Silver | `dim` & `fact` | ETL, Conformed dimensions & Fact tables |
| Gold / Semantic | `analytics` | Business-ready views |

---

## 3. Table Naming Conventions

### 3.1 Raw Tables
**Pattern**
<source_system>.<entity_name>

**Examples**
raw_erp.invoices
raw_erp.purchase_orders
raw_vendor.vendors
raw_contract.contracts
raw_finance.budget_forecast


➡ Raw tables:
- Preserve source structure
- No business logic
- Minimal transformations

---

### 3.2 Dimension Tables
**Pattern**
dim.dim_<business_entity>


**Examples**
dim.dim_vendor
dim.dim_category
dim.dim_region
dim.dim_date


➡ Dimensions:
- Use surrogate keys
- Conformed across facts
- One row per business entity

---

### 3.3 Fact Tables
**Pattern**
fact.fact_<business_process>


**Examples**
fact.fact_procurement_spend
fact.fact_budget_vs_actual


➡ Facts:
- Numeric measures
- Foreign keys to dimensions
- Defined grain (documented)

---

### 3.4 Analytics / Semantic Views
**Pattern**
analytics.vw_<business_description>


**Examples**
analytics.vw_procurement_spend
analytics.vw_spend_summary
analytics.vw_budget_vs_actual
analytics.vw_contract_compliance
analytics.vw_data_quality_exceptions


➡ Views:
- Used by Power BI & ad-hoc SQL
- Contain business logic
- Stable interface for reporting

---

## 4. Column Naming Conventions

### 4.1 Surrogate Keys
**Pattern**
<entity>_key


**Examples**
vendor_key
category_key
region_key
date_key
fact_spend_key


---

### 4.2 Business / Natural Keys
Use source system identifiers as-is:

invoice_id
invoice_line_id
po_id
contract_id
vendor_id
category_id


---

### 4.3 Measures & Metrics
**Pattern**
<metric>_<unit>


**Examples**
spend_amount
budgeted_spend
actual_spend
projected_savings
realized_savings
variance_amount


---

### 4.4 Flags & Status Columns
**Pattern**
is_<condition>


**Examples**
is_contract_compliant
is_active
data_freshness_flag
invoice_status


---

### 4.5 Dates & Time Columns
invoice_date
order_date
contract_start
contract_end
load_date
etl_insert_ts
etl_update_ts


---

## 5. Stored Procedures & ETL Scripts

### Stored Procedures
**Pattern**
sp.<action>_<layer>


**Examples**
sp.load_silver
sp.load_bronze


---

## 6. Power BI Naming Guidelines

- Dataset name: **GSP Procurement Analytics**
- Page names:
  - Executive Overview
  - Procurement Operations
  - Vendor Performance
- KPI display names:
  - Total Spend
  - Contract Compliance %
  - Budget Variance
  - Savings Realized

---

## 8. Why This Naming Convention Matters

- Improves readability and onboarding
- Prevents metric duplication
- Aligns SQL, BI, and documentation
- Reflects enterprise analytics standards

---

## 9. Summary

This naming convention is designed to:
- Scale with additional data sources
- Support automated pipelines
