use JDE_DEVELOPMENT
go

-----------------------------------------------------------------------------------------
--
-- Populate UDC 41/S5 (IMSRP5 and IBSRP5) with all of the Cartridge Sizes from Selecto
--
--
-- History:
-- 28-Aug-2019 R.Lillback Created Initial Version
--
-----------------------------------------------------------------------------------------

--  Optional restore from production:  
--  truncate table testctl.F0005; insert into testctl.F0005 select * from JDE_PRODUCTION.prodctl.F0005;

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

delete from testctl.F0005 where DRSY = N'41' and DRRT = N'S5' and RIGHT(LTRIM(RTRIM(DRDL01)),4) = N'-SEL'

insert into testctl.F0005
select
	N'41' as DRSY,
	N'S5' as DRRT,
	DRKY = N'       0' + cast(ROW_NUMBER() over (order by UDF_CARTRIDGE_SIZE) as nchar(1)) + N'S',
	DRDL01 = LEFT(RTRIM(UDF_CARTRIDGE_SIZE), 26) + N'-SEL',
	DRDL02 = LEFT(RTRIM(UDF_CARTRIDGE_SIZE),30),
	N'' as DRSPHD,
	N'' as DRUDCO,
	N'N' as DRHRDC,
	@user as DRUSER,
	@pid as DRPID,
	@jToday as DRUPMJ,
	@jobn as DRJOBN,
	@tNow as DRUPMT
from [N01A-DWSQLPD].SelectoJDE.dbo.ods_IM_UDT_Cartridge_Size as new


