use JDE_DEVELOPMENT
go

-----------------------------------------------------------------------------------------
--
-- Populate UDC 41/S3 (IMSRP3 and IBSRP3) with all of the Cartridge Technologies from Selecto
--
--
-- History:
-- 28-Aug-2019 R.Lillback Created Initial Version
--
-----------------------------------------------------------------------------------------

--  Optional restore from production:  
--  truncate table testctl.F0005; insert into testctl.F0005 select * from JDE_PRODUCTION.prodctl.F0005;

-- Here are teh optional records to delete
-- select * from testctl.F0005 where (DRSY = N'41' and DRRT = N'S1') and (LTRIM(RTRIM(DRKY)) not in (select distinct IMSRP1 from testdta.F4101) and DRUSER not in (N'TERILLIUM', N'KZABROSKY'))

-- Optionally delete unused records
-- delete from testctl.F0005 where (DRSY = N'41' and DRRT = N'S1' and LTRIM(RTRIM(DRKY)) not in (select distinct IMSRP1 from testdta.F4101) and DRUSER not in (N'TERILLIUM', N'KZABROSKY'))

delete from testctl.F0005 where DRSY = N'41' and DRRT = N'S3' and RIGHT(LTRIM(RTRIM(DRDL01)),4) = N'-SEL'

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
	N'S3' as DRRT,
	DRKY = N'       ' + UDF_CODE + N'S',
	DRDL01 = LEFT(RTRIM(UDF_DESCRIPTION), 26) + N'-SEL',
	DRDL02 = LEFT(RTRIM(UDF_DESCRIPTION),30),
	N'' as DRSPHD,
	N'' as DRUDCO,
	N'N' as DRHRDC,
	@user as DRUSER,
	@pid as DRPID,
	@jToday as DRUPMJ,
	@jobn as DRJOBN,
	@tNow as DRUPMT
from [N01A-DWSQLPD].SelectoJDE.dbo.ods_IM_UDT_CARTRIDGE_TECHNOLOGY as new


