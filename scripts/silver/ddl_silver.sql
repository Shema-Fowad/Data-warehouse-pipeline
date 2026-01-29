/* 
DDL Script for Fact & dimensions table
This Script creates table in the fact & dim schema dropping existing tables if they already exist.
*/
-- let's create facts and dimesions table now


-- 1. DIMENSIONS TABLE

if object_id('dim.dim_vendor' , 'U') is not null
  drop table dim.dim_vendor;
create table dim.dim_vendor (
	vendor_key		int identity primary key,
	vendor_id		varchar(20),
	vendor_name		varchar(100),
	vendor_tier		varchar(20),
	region_id		varchar(10),
	active_flag		char(1)
);
go

  
if object_id('dim.dim_category' , 'U') is not null
  drop table dim.dim_category;
create table dim.dim_category (
	category_key		int identity primary key,
	category_id			varchar(20),
	category_name		varchar(50),
	category_manager	varchar(50),
);
go

  
if object_id('dim.dim_region' , 'U') is not null
  drop table dim.dim_region;
create table dim.dim_region (
	region_key		int identity primary key,
	region_id			varchar(10),
	region_name		varchar(50),
);
go


if object_id('dim.dim_date' , 'U') is not null
  drop table dim.dim_date;
create table dim.dim_date (
	date_key		int primary key,
	full_date		date,
	year			int,
	month			int,
	month_name		varchar(10),
	quarter			int
);
go

-- 2. FACTS TABLE

if object_id('fact.fact_procurement_spend' , 'U') is not null
  drop table fact.fact_procurement_spend;
create table fact.fact_procurement_spend(
	invoice_line_id			varchar(20) primary key,
	vendor_key				int,
	category_key			int,
	region_key				int,
	date_key				int,
	contract_id				varchar(20),
	spend_amount			decimal(18,2),
	is_contract_compliant	bit
); 
go


if object_id('fact.fact_contract_savings' , 'U') is not null
  drop table fact.fact_contract_savings;
create table fact.fact_contract_savings (
	contract_id		varchar(20),
	date_key		int,
	projected_savings	decimal(18,2),
	realized_savings	decimal(18,2),
);
go


if object_id('fact.fact_budget_vs_actual' , 'U') is not null
  drop table fact.fact_budget_vs_actual;
create table fact.fact_budget_vs_actual (
	category_key			int,
	region_key				int,
	date_key				int,
	budgeted_spend			decimal(18,2),
	actual_spend			decimal(18,2)
);
go

-- lets verify
select
	table_schema,
	table_name
from
	information_schema.tables
where table_schema in ('dim', 'fact')
order by table_schema,
	table_name;
