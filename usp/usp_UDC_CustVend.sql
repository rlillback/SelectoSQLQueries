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
--   11-Mar-2020 R.Lillback Added 40/PC and 40/PI
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

	/*********************************************************
	 * Next, add customer fields for pricing                 *
	 *********************************************************/
	delete from testctl.F0005 where ltrim(rtrim(DRSY)) = N'40' and ltrim(rtrim(DRRT)) = N'PC' and ltrim(rtrim(DRKY)) like N'SU%'
	insert into testctl.F0005
	select top 1
		DRSY,
		DRRT,
		N'  SU0' as DRKY,
		N'Suwanee Full Base Price' as DRDL01,
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
	where ltrim(rtrim(DRSY)) = N'40' and ltrim(rtrim(DRRT)) = N'PC'

	declare @loop int = 15;
	declare @counter int = 0;
	declare @priceGroup nchar(1);
	while (@counter < @loop) begin
		set @priceGroup = (
							case @counter
								when 0  then N'1'
								when 1  then N'A'
								when 2  then N'D'
								when 3  then N'E'
								when 4  then N'J'
								when 5  then N'N'
								when 6  then N'O'
								when 7  then N'P'
								when 8  then N'R'
								when 9  then N'S'
								when 10 then N'U'
								when 11 then N'V'
								when 12 then N'W'
								when 13 then N'Y'
								when 14 then N'Z'
							end 
						   );
		insert into testctl.F0005
		select top 1
			DRSY,
			DRRT,
			(N'  SU' + @priceGroup) collate database_default as DRKY,
			(N'Suwanee ' + @priceGroup) collate database_default as DRDL01,
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
		where ltrim(rtrim(DRSY)) = N'40' and ltrim(rtrim(DRRT)) = N'PC'
		set @counter = @counter + 1;
	end

	/*********************************************************
	 * Next, add item fields for pricing                     *
	 *********************************************************/
	 delete from testctl.F0005 where ltrim(rtrim(DRSY)) = N'40' and ltrim(rtrim(DRRT)) = N'PI' and ltrim(rtrim(DRKY)) = N'SU'
	insert into testctl.F0005
	select top 1
		DRSY,
		DRRT,
		N'  SU' as DRKY,
		N'Suwanee Item' as DRDL01,
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
	where ltrim(rtrim(DRSY)) = N'40' and ltrim(rtrim(DRRT)) = N'PI'
END