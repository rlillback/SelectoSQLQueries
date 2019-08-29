use JDE_DEVELOPMENT
go

-----------------------------------------------------------------------------------------
--
-- Populate UDC 41/06 (IMSRP6 and IBSRP6) with all of the Product Stages from Selecto
--
--
-- History:
-- 28-Aug-2019 R.Lillback Created Initial Version
--
-----------------------------------------------------------------------------------------

--  Optional restore from production:  
--  truncate table testctl.F0005; insert into testctl.F0005 select * from JDE_PRODUCTION.prodctl.F0005;

delete from testctl.F0005 where DRSY = N'41' and DRRT = N'06' and RIGHT(RTRIM(LTRIM(DRDL01)),4) = N'-SEL'

-- Set up the audit trail
declare @user nvarchar(10) = N'RLILLBACK';
declare @pid nvarchar(10) = N'SQLLD';
declare @jobn nvarchar(10) = N'SQLLD';
declare @jToday numeric(18,0)= dbo.fn_DateTimeToJulian(GETDATE()); -- Julian Date Today
declare @tNow float = CONVERT (
							   float,
							   datepart(hh,getdate())*10000 + 
							   datepart(mi, getdate())*100 +
							   datepart(ss, getdate())
							   ); -- Time now as held by JDE

							   
insert into testctl.F0005
select
	N'41' as DRSY,
	N'06' as DRRT,
	DRKY = N'       0' + cast(ROW_NUMBER() over (order by UDF_PRODUCT_STAGE) as nchar(1)) + N'S',
	DRDL01 = LEFT(RTRIM(UDF_PRODUCT_STAGE), 26) + N'-SEL',
	DRDL02 = LEFT(RTRIM(UDF_PRODUCT_STAGE),30),
	N'' as DRSPHD,
	N'' as DRUDCO,
	N'N' as DRHRDC,
	@user as DRUSER,
	@pid as DRPID,
	@jToday as DRUPMJ,
	@jobn as DRJOBN,
	@tNow as DRUPMT
from [N01A-DWSQLPD].SelectoJDE.dbo.ods_IM_UDT_PRODUCT_STAGE as new


