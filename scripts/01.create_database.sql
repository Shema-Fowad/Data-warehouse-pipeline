/*  CREATE DATABASE & SCHEMAS
This script creates a new database named 'gsp_analytics'.
the script sets up 6 schemas within the database: 
i). raw_erp
ii). raw_vendor
iii). raw_contract
iv). raw_finance
v). dim
vi). fact
*/

CREATE DATABASE gsp_analytics;
GO

SELECT name FROM sys.databases;

USE gsp_analytics;
GO

create schema raw_erp;
go
create schema raw_vendor;
go
create schema raw_contract;
go
create schema raw_finance;
go
create schema dim;
go
create schema fact;
go
