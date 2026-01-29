/*
Stored Procedure: it will load the bronze layer from the source
---
Script purpose:
      This stored procedure loads data into the bronze schema from external CSV files.
      It performs two actions:
        - Truncates the bronze tables before loading the data.
        - Uses the 'Bulk Insert' command to load data from CSV files to bronze tables.
---
*/

-- let's create a stored procedure schema first
create schema sp;
go

--execute the stored procedure instead of running multiple queries
EXEC sp.load_bronze

--create stored procedure for loading the bronze layer
create or alter procedure sp.load_bronze as
BEGIN
	--1
	truncate table raw_contract.contracts;

	bulk insert raw_contract.contracts
	from 'C:\Users\Admin\Desktop\shema work\gsp_analytics\datasets\contracts\contracts.csv'
	with (
		firstrow = 2,
		fieldterminator = ',',
	);

	select *
	from raw_contract.contracts

	select count *
	from raw_contract.contracts

	--2
	truncate table raw_erp.invoices;

	bulk insert raw_erp.invoices
	from 'C:\Users\Admin\Desktop\shema work\gsp_analytics\datasets\erp\invoices.csv'
	with (
		firstrow = 2,
		fieldterminator = ',',
	);

	select *
	from raw_erp.invoices;

	select count *
	from raw_erp.invoices;

	--3
	truncate table raw_erp.purchase_orders;

	bulk insert raw_erp.purchase_orders
	from 'C:\Users\Admin\Desktop\shema work\gsp_analytics\datasets\erp\purchase_orders.csv'
	with (
		firstrow = 2,
		fieldterminator = ',',
	);

	select *
	from raw_erp.purchase_orders;

	select count *
	from raw_erp.purchase_orders;

	--4
	truncate table raw_finance.budget_forecast;

	bulk insert raw_finance.budget_forecast
	from 'C:\Users\Admin\Desktop\shema work\gsp_analytics\datasets\finance\budget_forecast.csv'
	with (
		firstrow = 2,
		fieldterminator = ',',
	);

	select *
	from raw_finance.budget_forecast;

	select count *
	from raw_finance.budget_forecast;

	--5
	truncate table raw_vendor.vendors;

	bulk insert raw_vendor.vendors
	from 'C:\Users\Admin\Desktop\shema work\gsp_analytics\datasets\vendor_master\vendors.csv'
	with (
		firstrow = 2,
		fieldterminator = ',',
	);
END

select *
from raw_vendor.vendors;

select count *
from raw_vendor.vendors;
