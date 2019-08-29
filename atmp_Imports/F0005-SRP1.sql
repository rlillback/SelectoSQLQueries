use JDE_DEVELOPMENT
go

-----------------------------------------------------------------------------------------
--
-- Populate UDC 41/S1 (IMSRP1 and IBSRP1) with all of the Product Lines from Selecto
--
-- NOTE: THIS SHOULD POPULATE 21 ROWS IF NONE OF THE RECORDS EXIST ALREADY.
--
-- History:
-- 27-Aug-2019 R.Lillback Created Initial Version
-- 28-Aug-2019 R.Lillback Added population of DR02 for future joins from original table
--
-----------------------------------------------------------------------------------------

--  Optional restore from production:  
--  truncate table testctl.F0005; insert into testctl.F0005 select * from JDE_PRODUCTION.prodctl.F0005;

-- Here are the optional records to delete
-- select * from testctl.F0005 where (DRSY = N'41' and DRRT = N'S1') and (LTRIM(RTRIM(DRKY)) not in (select distinct IMSRP1 from testdta.F4101) and DRUSER not in (N'TERILLIUM', N'KZABROSKY'))

-- Optionally delete unused records
-- delete from testctl.F0005 where (DRSY = N'41' and DRRT = N'S1' and LTRIM(RTRIM(DRKY)) not in (select distinct IMSRP1 from testdta.F4101) and DRUSER not in (N'TERILLIUM', N'KZABROSKY'))

-- Delete records by date
-- delete from testctl.F0005 where DRSY = N'41' and DRRT = N'S1' and DRUPMJ = 119240

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
	N'S1' as DRRT,
	DRKY = N'       ' + RIGHT(ProductLine, 3),
	DRDL01 = LEFT(RTRIM(ProductLineDesc) + N' - SEL',30),
	DRDL02 = LEFT(RTRIM(ProductLineDesc),30),
	N'' as DRSPHD,
	N'' as DRUDCO,
	N'N' as DRHRDC,
	@user as DRUSER,
	@pid as DRPID,
	@jToday as DRUPMJ,
	@jobn as DRJOBN,
	@tNow as DRUPMT
from [N01A-DWSQLPD].SelectoJDE.dbo.ods_IM_ProductLine as new
	 left join TESTCTL.F0005 as jde on DRSY = N'41' and DRRT = N'S1' and DRKY =  N'       ' + RIGHT(ProductLine, 3)
where
	jde.DRKY is null -- Don't insert records already in the system

