# Procurement Analytics Data Warehouse

> A SQL Server-based data warehouse implementation for procurement spend analysis and vendor performance tracking

## Overview

This project solves a common business problem: procurement teams working with fragmented data across multiple systems (ERP, vendor databases, contract management, finance systems) need a unified view to answer critical questions about spending patterns, vendor performance, and budget compliance.

**My Solution:** Built a centralized data warehouse that consolidates procurement data and provides analytics-ready views for business intelligence reporting.

---

## The Business Problem

Procurement teams typically struggle with:
- Scattered data across ERP systems, vendor files, contract databases, and finance spreadsheets
- Manual effort to calculate total spend by vendor, category, or region
- Difficulty tracking off-contract purchases and budget variance
- No single source of truth for vendor performance metrics

**Impact:** Without consolidated data, procurement decisions are delayed, savings opportunities are missed, and compliance risks increase.

---

## Technical Implementation

### Architecture Choice: Medallion Pattern

I implemented a three-layer architecture to separate concerns and enable data quality controls:

```
CSV Source Files → Bronze (Raw) → Silver (Modeled) → Gold (Analytics) → Power BI
```

**Why this pattern?**
- Bronze preserves raw data for audit/reprocessing
- Silver applies business rules and dimensional modeling
- Gold provides pre-calculated metrics for consistent reporting

### Technology Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| Storage | SQL Server Express | Relational warehouse |
| ETL | T-SQL Scripts | Data extraction and transformation |
| Modeling | Star Schema (Galaxy variation) | Optimized for analytical queries |
| Visualization | Power BI Desktop | Self-service dashboards |
| Version Control | Git/GitHub | Code management |

---

## Data Model

### Schema Organization

I structured the database into logical schemas:

- `raw_erp` – ERP purchase orders and invoices (Bronze)
- `raw_vendor` – Vendor master data (Bronze)
- `raw_contract` – Contract terms and compliance data (Bronze)
- `raw_finance` – Budget and forecast information (Bronze)
- `dim` – Dimension tables (Silver)
- `fact` – Fact tables (Silver)
- `analytics` – Business-facing views (Gold)

### Core Tables

**Fact Tables:**
- `fact.fact_procurement_spend` – Grain: One row per line item on a purchase order
- `fact.fact_budget_vs_actual` – Grain: One row per category per month

**Dimension Tables:**
- `dim.dim_vendor` – SCD Type 1 (current state only)
- `dim.dim_category` – Procurement category hierarchy
- `dim.dim_region` – Geographic regions
- `dim.dim_date` – Standard date dimension

**Design Decisions:**
- Used surrogate keys for all dimensions (insulates from source system changes)
- Implemented conformity across facts (shared dimension keys)
- Denormalized category hierarchies for query performance

---

## Key Metrics & KPIs

All calculations are performed **in SQL** (not in the BI layer) for:
- Consistency across reports
- Auditability and lineage
- Performance (pre-aggregated in Gold views)

**Metrics Delivered:**

| KPI | Definition | Business Use |
|-----|-----------|--------------|
| Total Spend | SUM of invoice amounts | Executive reporting |
| Spend by Vendor | Grouped by vendor dimension | Vendor consolidation analysis |
| Spend by Category | Grouped by category hierarchy | Spend visibility |
| Budget Variance | Actual vs. budgeted spend | Financial control |
| Contract Compliance % | On-contract spend / total spend | Risk management |
| Off-Contract Spend | Spend without contract coverage | Savings opportunity |

---

## ETL Process

### Data Flow

1. **Bronze Layer** – CSV files loaded AS-IS into staging tables
   - No transformations applied
   - Preserves source data for troubleshooting

2. **Silver Layer** – Data modeling and cleansing
   - Type casting and null handling
   - Lookup table joins to create dimension keys
   - Fact table population with foreign keys

3. **Gold Layer** – Analytics views
   - Pre-joined facts and dimensions
   - Calculated metrics (YTD, variance, compliance %)
   - Business-friendly column names

### Current Limitations

- **Full load only** – No incremental processing (future enhancement: implement MERGE/UPSERT)
- **Manual execution** – Scripts run in SSMS (future: stored procedures + SQL Agent jobs)

---

## Dashboards

### 1. Executive Spend Overview
**Audience:** CPO, Finance Leadership  
**Questions Answered:**
- What's our total spend this quarter vs. budget?
- Which categories are over/under budget?
- What percentage of spend is contract-compliant?

### 2. Procurement Operations
**Audience:** Category Managers  
**Questions Answered:**
- Which vendors represent our highest spend concentration?
- Where are we purchasing off-contract?
- What's the month-over-month trend by category?

### 3. Vendor Performance
**Audience:** Sourcing Team  
**Questions Answered:**
- How much spend is concentrated in our top 10 vendors?
- Which vendors have coverage under active contracts?
- What's our contract compliance rate by vendor tier?

---

## Repository Structure

```
├── datasets/           # Sample CSV files (anonymized test data)
├── scripts/
│   ├── bronze/        # Raw data ingestion scripts
│   ├── silver/        # Dimension and fact loading scripts
│   ├── gold/          # Analytics view creation
│   └── quality/       # Data quality checks (planned)
├── docs/
│   ├── er_diagram.png
│   └── naming_conventions.md
└── README.md
```

---

## How to Run This Project

### Prerequisites
- SQL Server Express (or higher)
- SQL Server Management Studio (SSMS)
- Power BI Desktop (for dashboards)

### Setup Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/Shema-Fowad/Data-warehouse-pipeline.git
   ```

2. **Execute SQL scripts in order**
   ```
   scripts/bronze/     → Load raw tables
   scripts/silver/     → Create dimensions and facts
   scripts/gold/       → Create analytics views
   ```

3. **Connect Power BI**
   - Open Power BI Desktop
   - Connect to SQL Server instance
   - Import from `analytics` schema
   - Refresh data model

---

## What I Learned

### Technical Skills
- Designing dimensional models (star schema with conformed dimensions)
- Implementing medallion architecture in a relational database
- Writing ETL logic in T-SQL (INSERT, UPDATE, MERGE patterns)
- Creating calculated columns and views for analytics

### Business Understanding
- Procurement domain: PO lifecycle, contract compliance, spend analysis
- Translating business questions into data requirements
- Balancing normalization vs. denormalization for query performance

### Challenges Overcome
- **Data quality issues:** Source CSVs had inconsistent vendor naming → implemented cleansing rules
- **Grain definition:** Determining the right level of detail for fact tables
- **Performance:** Initial queries were slow → added strategic indexes and pre-aggregation

---

## Future Enhancements

**Short-term:**
- [ ] Add data quality reconciliation queries (source row counts vs. warehouse)
- [ ] Implement incremental loading using MERGE statements
- [ ] Create stored procedures with error handling

**Medium-term:**
- [ ] Add slowly changing dimension (SCD Type 2) logic for vendor address changes
- [ ] Build anomaly detection queries for unusual spending patterns
- [ ] Implement data lineage tracking

**Long-term:**
- [ ] Migrate to Azure SQL Database for cloud deployment
- [ ] Add Python orchestration layer (Airflow or Prefect)
- [ ] Develop predictive models for spend forecasting

---

## Why This Project Matters

This project demonstrates my ability to:
1. **Translate business needs into technical solutions** – Understood procurement challenges and designed a warehouse to solve them
2. **Apply dimensional modeling principles** – Built star schema with proper grain, slowly changing dimensions, and conformity
3. **Work with the full analytics stack** – From raw data ingestion through to BI dashboard delivery
4. **Document and organize work** – Professional code structure, README, and naming conventions

---

## License

MIT License - See [LICENSE](LICENSE) file for details
## About ME
Hi there! I am Shema Fowad. I am a Business Data Analyst with experience in **Operations analytics**, focused on building **scalable, decision driven data solutions** using SQL and BI tools.
email me - shemafowad.sf@gmail.com
