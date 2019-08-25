use SelectoJDE
go

-----------------------------------------------------------------------------------------
--
-- Get all active customers in the Sage system
--
-- History:
-- 25-Aug-2019 R.Lillback Created initial version
--
-----------------------------------------------------------------------------------------
select
	*
from dbo.ods_AR_Customer
where CustomerStatus = N'A' -- Active customers
order by CustomerName asc