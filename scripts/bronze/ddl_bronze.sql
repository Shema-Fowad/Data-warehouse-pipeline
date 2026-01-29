/*
DDL script for creating raw tables
This script creates tables in the raw_erp,raw_vendor,raw_contract & raw_finance schemas.
*/
-- CREATE RAW TABLES
-- 1. ERP PURCHASE ORDERS

If object_id('raw_erp.purchase_orders', 'U') is not null
  drop table raw_erp.purchase_orders;
go
  
Create table raw_erp.purchase_orders (
	po_id		varchar(20),
	po_line_id	varchar(20),
	vendor_id	varchar(20),
	category_id	varchar(20),
	region_id	varchar(10),
	order_date	date,
	ordered_amount	decimal(18,2),
	currency	varchar(3)
);
go

-- 2. ERP invoices
If object_id('raw_erp.invoices', 'U') is not null
  drop table raw_erp.invoices;
go
  
create table raw_erp.invoices (
	invoice_id		varchar(20),
	invoice_line_id		varchar(20),
	po_id			varchar(20),
	vendor_id		varchar(20),
	invoice_date	date,
	invoice_amount	decimal(18,2),
	invoice_status	varchar(20)
);
go

-- 3. vendor master

If object_id('raw_vendor.vendors', 'U') is not null
  drop table raw_vendor.vendors;
go
  
create table raw_vendor.vendors (
	vendor_id		varchar(20),
	vendor_name		varchar(100),
	vendor_tier		varchar(20),
	region_id		varchar(10),
	active_flag		char(1)
);
go

--4. contract management

If object_id('raw_contract.contracts', 'U') is not null
  drop table raw_contract.contracts;
go
  
create table raw_contract.contracts (
	contract_id		varchar(20),
	vendor_id		varchar(20),
	category_id		varchar(20),
	contract_start	date,
	contract_end	date,
	contact_value	decimal(18,2),
	negotiated_savings	decimal(18,2)
);
go

-- 5. finance- budget forecast

If object_id('raw_finance.budget_forecast', 'U') is not null
  drop table raw_finance.budget_forecast;
go
  
create table raw_finance.budget_forecast (
	category_id		varchar(20),
	region_id		varchar(20),
	month			date,
	budgeted_spend	decimal(18,2)
);
go

-- let's verify
select
	s.name as schema_name,
	t.name as table_name
from sys.tables t
join sys.schemas s
on t.schema_id = s.schema_id
order by s.name, t.name
