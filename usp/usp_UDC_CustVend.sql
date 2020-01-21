use JDE_DEVELOPMENT
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ****************************************************************************************
-- Create customer & vendor UDCs delete them if they already exist to make sure we have
-- the latest versions
--
-- HISTORY:
--   21-Jan-2020 R.Lillback Created initial version
-- ****************************************************************************************
IF EXISTS(SELECT * FROM SYS.objects WHERE TYPE = 'P' AND name = N'usp_UDC_CustVend')
	DROP PROCEDURE atmp.usp_UDC_CustVend
GO

CREATE PROCEDURE atmp.usp_UDC_CustVend
AS
BEGIN

	SET NOCOUNT ON;
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

	/*********************************************************
	 * First, let's make sure we update all the search types *
	 *********************************************************/
	delete from testctl.F0005
	where 
		ltrim(rtrim(DRSY)) = N'01' 
			and 
		ltrim(rtrim(DRRT)) = N'ST' 
			and 
		ltrim(rtrim(DRKY)) in ('V3', 'C3', 'R3', 'S3')

	insert into testctl.F0005
	select 
		DRSY,
		DRRT,
		rtrim(DRKY) + N'3' as DRKY,
		DRDL01,
		DRDL02,
		DRSPHD,
		DRUDCO,
		DRHRDC,
		@user as DRUSER,
		@pid as DRPID,
		@jToday as DRUPMJ,
		@jobn as DRJOBN,
		@tNow as DRUPMT
	from testctl.F0005
	where 
		ltrim(rtrim(DRSY)) = N'01' 
			and 
		ltrim(rtrim(DRRT)) = N'ST' 
			and 
		ltrim(rtrim(DRKY)) in ('V', 'C', 'R', 'S')

	update x
	set x.DRDL01 = ltrim(rtrim(y.DRDL01)) + N'- Suwanee'
	from testctl.F0005 as x 
	join
	(
		select DRSY, DRRT, DRKY, DRDL01
		from testctl.F0005 
		where ltrim(rtrim(DRSY)) = N'01' 
				and 
			  ltrim(rtrim(DRRT)) = N'ST' 
				and 
			  ltrim(rtrim(DRKY)) in ('V3', 'C3', 'R3', 'S3')
	) as y on x.DRSY = y.DRSY and x.DRRT = y.DRRT and x.DRKY = y.DRKY

	/*********************************************************
	 * Next, update AC0x fields                              *
	 *********************************************************/
	 delete from testctl.F0005 where ltrim(rtrim(DRSY)) = N'01' and ltrim(rtrim(DRRT)) = N'01' and ltrim(rtrim(DRKY)) = N'SUW'
	 insert into testctl.F0005
	 select top 1
		DRSY,
		DRRT,
		N'SUW' as DRKY,
		N'SUWANEE' as DRDL01,
		DRDL02,
		DRSPHD,
		DRUDCO,
		N'N' as DRHRDC,
		@user as DRUSER,
		@pid as DRPID,
		@jToday as DRUPMJ,
		@jobn as DRJOBN,
		@tNow as DRUPMT
	from testctl.F0005
	where ltrim(rtrim(DRSY)) = N'01' and ltrim(rtrim(DRRT)) = N'01'

END