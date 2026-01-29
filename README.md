# Data-warehouse-pipeline
building a data warehouse for procurement team with SQL server, including ETL processes, data modelling, and analytics.

This project demonstrates a comprehensive data warehousing and analytics solution, from building a data warehouse to generating actionable insights.

## Data Architecture

The data architecture for this project follows Medallion Architecture **Bronze**, **Silver**, and **Gold** layers:

1. **Bronze Layer**: Stores raw data as-is from the source systems. Data is ingested from CSV Files into SQL Server Database.
2. **Silver Layer**: Data is modeled into a star schema.This layer also includes data cleansing, standardization, and normalization processes to prepare data for analysis.
3. **Gold Layer**: This layer creates Analytics views for analysis and ready to be imported into power BI.

## Project Overview

This project involves:

1. **Data Architecture**: Designing a Modern Data Warehouse Using Medallion Architecture **Bronze**, **Silver**, and **Gold** layers.
2. **ETL Pipelines**: Extracting, transforming, and loading data from source systems into the warehouse.
3. **Data Modeling**: Developing fact and dimension tables optimized for analytical queries.
4. **Analytics & Reporting**: Creating SQL-based reports and dashboards for actionable insights.

---

## Technology Stack
- **Database:** SQL Server Express
- **SQL Tooling:** SQL Server Management Studio (SSMS)
- **BI Tool:** Power BI Desktop
- **Version Control:** GitHub
- **Modeling:** GALAXY Schema
- **Automation:** SQL-based ETL (full load)

---

## Data Model Overview

### Schemas Used
raw_erp – ERP purchase orders & invoices
raw_vendor – Vendor master data
raw_contract – Contract management data
raw_finance – Budget & forecast data
dim – Conformed dimensions
fact – Fact tables
analytics – Business-ready semantic views

---

### Core Fact Tables
- `fact.fact_procurement_spend`
- `fact.fact_budget_vs_actual`

### Core Dimensions
- `dim.dim_vendor`
- `dim.dim_category`
- `dim.dim_region`
- `dim.dim_date`

📌 *ER diagram available in `er_diagram.png`*

---

## Key KPIs Delivered
- Total Spend
- Spend by Vendor / Category / Region
- Budget vs Actual Spend
- Contract Compliance %
- Off-Contract Spend
- Data Quality Exceptions

All KPIs are calculated **in SQL**, not in the BI layer, ensuring:
- Metric consistency
- Auditability
- Reduced BI complexity

---

## Dashboards Built (Power BI)

### 1️. Executive Dashboard
**Audience:** CPO, Finance Leadership  
- Total Spend vs Budget
- Contract Compliance %
- Category-level spend concentration
- High-risk areas

### 2️. Procurement Operations Dashboard
**Audience:** Category Managers  
- Vendor-level spend
- Non-compliant spend drilldowns
- Month-over-month variance analysis

### 3️. Vendor Performance Dashboard
**Audience:** Sourcing Managers  
- Spend concentration by vendor
- Compliance by vendor tier
- Contract coverage indicators

---

## Data Quality & Controls
To ensure trust in the data:
- ERP totals reconciled with warehouse facts
- Missing dimension mappings detected
- Late-arriving data flagged
- Failed checks exposed via exception views

---

## Repository Structure
/datasets
├── CSV files
/scripts
├── bronze/ -- raw ingestion scripts
├── silver/ -- dimension & cleansing logic with facts and dimensions loading
├── gold/ -- analytics views
├── quality/ -- reconciliation & data quality checks
/docs
├── er_diagram.png
├── naming_conventions.md
README.md


---

## Naming Standards
Consistent naming conventions are applied across:
- Schemas
- Tables
- Columns
- Views
- Stored procedures

📌 Detailed standards available in `naming_conventions.md`

---

## Business Impact
- Reduced manual reporting effort by ~80%
- Improved accuracy and trust in procurement metrics
- Enabled faster identification of savings leakage
- Provided scalable foundation for future analytics & forecasting

---

## Future Enhancements
- Spend forecasting by category and region
- Supplier risk detection (anomaly-based)
- Savings realization tracking over time
- Incremental loading strategy
- Power BI Service deployment

---

## What This Project Demonstrates
- End-to-end data warehouse design
- Realistic procurement domain modeling
- GALAXY schema & grain definition
- Data quality and reconciliation logic
- BI-ready semantic layer design
  
---

## How to Use This Project
1. Clone the repository
2. Run SQL scripts in order (Bronze → Silver → Gold)
3. Open Power BI and connect to `analytics` views
4. Explore dashboards and KPIs

---
## About ME
Hi there! I am Shema Fowad. I am a Business Data Analyst with experience in **Operations analytics**, focused on building **scalable, decision driven data solutions** using SQL and BI tools.
email me - shemafowad.sf@gmail.com
