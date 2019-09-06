use KSTG
go

truncate table [dbo].[stg_SEL_AR_Customer]
insert into dbo.stg_SEL_AR_Customer select * from [SELECTO-TS\SQLEXPRESS].SelectoStaging.dbo.stg_SEL_AR_Customer

truncate table [dbo].[stg_SEL_AR_InvoiceHistoryHeader]
insert into dbo.[stg_SEL_AR_InvoiceHistoryHeader] select * from [SELECTO-TS\SQLEXPRESS].SelectoStaging.dbo.[stg_SEL_AR_InvoiceHistoryHeader]

truncate table [dbo].[stg_SEL_CI_Item]
insert into dbo.[stg_SEL_CI_Item] select * from [SELECTO-TS\SQLEXPRESS].SelectoStaging.dbo.[stg_SEL_CI_Item]

truncate table [dbo].[stg_SEL_SO_SalesOrderDetail]
insert into dbo.[stg_SEL_SO_SalesOrderDetail] select * from [SELECTO-TS\SQLEXPRESS].SelectoStaging.dbo.[stg_SEL_SO_SalesOrderDetail]

truncate table [dbo].[stg_SEL_SO_SalesOrderHeader]
insert into dbo.[stg_SEL_SO_SalesOrderHeader] select * from [SELECTO-TS\SQLEXPRESS].SelectoStaging.dbo.[stg_SEL_SO_SalesOrderHeader]

truncate table [dbo].[stg_SEL_SO_SalesOrderHistoryDetail]
insert into dbo.[stg_SEL_SO_SalesOrderHistoryDetail] select * from [SELECTO-TS\SQLEXPRESS].SelectoStaging.dbo.[stg_SEL_SO_SalesOrderHistoryDetail]

truncate table [dbo].[stg_SEL_SO_SalesOrderHistoryHeader]
insert into dbo.[stg_SEL_SO_SalesOrderHistoryHeader] select * from [SELECTO-TS\SQLEXPRESS].SelectoStaging.dbo.[stg_SEL_SO_SalesOrderHistoryHeader]