use SelectoJDE
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ****************************************************************************************
-- Create F4072 records for any contract pricing that exists in Sage
--
-- HISTORY:
--   11-Mar-2020 R.Lillback Created initial version
--   27-May-2020 R.Lillback Fixed issue with no leading zero's on customer numbers
-- ****************************************************************************************
IF EXISTS(SELECT * FROM SYS.objects WHERE TYPE = 'P' AND name = N'usp_F4072_Contract')
	DROP PROCEDURE dbo.usp_F4072_Contract
GO

CREATE PROCEDURE dbo.usp_F4072_Contract
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

	if OBJECT_ID(N'tempdb..#tempContract') is not NULL
		drop table #tempContract

	create table #tempContract (
		ItemCode nchar(25),
		CustomerNo nchar(25),
		DiscountMarkup1 float,
	)

	/*********************************************************************
	 * First, lets make all the contract pricing.  This maps to JDE as   *
	 * Item & Customer specific basis code of 5	under the STDMULTI	     *
	 * adjustment.														 *
	 *********************************************************************/
	insert into #tempContract
	select ItemCode, CustomerNo, DiscountMarkup1 from dbo.ods_IM_PriceCode
	where PriceCode is NULL
		  and ItemCode is not NULL 
		  and CustomerNo is not NULL 
		  and PricingMethod = 'O' -- PricingMethod = O is contract pricing

	insert into atmp.F4072
	select
		N'STDMULTI' as ADAST,
		IMITM as ADITM,
		IMLITM COLLATE DATABASE_DEFAULT as ADLITM,
		IMAITM COLLATE DATABASE_DEFAULT as ADAITM,
		ABAN8 as ADAN8,
		0 as ADIGID,
		0 as ADCGID,
		0 as ADOGID,
		N'USD' as ADCRCD,
		N'EA' as ADUOM,
		-9999 as ADMNQ,
		118001 as ADEFTJ,
		140366 as ADEXDJ,
		N'5' as ADBSCD, -- Basis code = 5 means ADFVTR is a dollar amount
		N'' as ADLEDG,
		N'' as ADFRMN, 
		round(DiscountMarkup1*10000,0) as ADFVTR,
		N'N' as ADFGY,
		0 as ADTID,
		N'' as ADURCD,
		0 as ADURDT,
		0 as ADURAT,
		0 as ADURAB,
		N'' as ADURRF,
		0 as ADNBRORD,
		N'' as ADUOMVID,
		N'' as ADFVUM,
		N'1' as ADPARTFG,
		N'' as ADAPRS,
		@user as ADUSER,
		@pid as ADPID,
		@jobn as ADJOBN,
		@jToday as ADUPMJ,
		@tNow as ADTDAY,
		0 as ADBKTPID,
		N'' as ADCRCDVID,
		N'' as ADRULENAME
	from #tempContract
	join atmp.F4101 on IMLITM = rtrim(ItemCode) COLLATE DATABASE_DEFAULT 
	join atmp.F0101 on ABALKY = ltrim(rtrim(substring(CustomerNo, patindex('%[^0]%', CustomerNo), 20))) COLLATE DATABASE_DEFAULT 


	/*********************************************************************
	 * Next, lets make all the discount pricing.  This maps to JDE as    *
	 * Item & Customer specific basis code of 1	under the STDMULTI	     *
	 * adjustment.														 *
	 *********************************************************************/
	truncate table #tempContract
	insert into #tempContract
	select ItemCode, CustomerNo, DiscountMarkup1 from dbo.ods_IM_PriceCode
	where PriceCode is NULL
		  and ItemCode is not NULL 
		  and CustomerNo is not NULL 
		  and PricingMethod = 'D' -- PricingMethod = D overrides the discount %

	insert into atmp.F4072
	select
		N'STDMULTI' as ADAST,
		IMITM as ADITM,
		IMLITM COLLATE DATABASE_DEFAULT as ADLITM,
		IMAITM COLLATE DATABASE_DEFAULT as ADAITM,
		ABAN8 as ADAN8,
		0 as ADIGID,
		0 as ADCGID,
		0 as ADOGID,
		N'USD' as ADCRCD,
		N'EA' as ADUOM,
		-9999 as ADMNQ,
		118001 as ADEFTJ,
		140366 as ADEXDJ,
		N'1' as ADBSCD, -- Basis code = 1 means ADFVTR is a percent amount
		N'' as ADLEDG,
		N'' as ADFRMN, 
		round((100.0-DiscountMarkup1)*10000,0) as ADFVTR, -- Sage holds this as a % discount, JDE as a % of price
		N'N' as ADFGY,
		0 as ADTID,
		N'' as ADURCD,
		0 as ADURDT,
		0 as ADURAT,
		0 as ADURAB,
		N'' as ADURRF,
		0 as ADNBRORD,
		N'' as ADUOMVID,
		N'' as ADFVUM,
		N'1' as ADPARTFG,
		N'' as ADAPRS,
		@user as ADUSER,
		@pid as ADPID,
		@jobn as ADJOBN,
		@jToday as ADUPMJ,
		@tNow as ADTDAY,
		0 as ADBKTPID,
		N'' as ADCRCDVID,
		N'' as ADRULENAME
	from #tempContract
	join atmp.F4101 on IMLITM = rtrim(ItemCode) COLLATE DATABASE_DEFAULT 
	join atmp.F0101 on ABALKY = ltrim(rtrim(substring(CustomerNo, patindex('%[^0]%', CustomerNo), 20))) COLLATE DATABASE_DEFAULT

	/*********************************************************************
	 * Finally, lets make all the discounts.  This maps to JDE as        *
	 * Item & Customer specific basis code of 5	under the DISCDOL	     *
	 * adjustment.														 *
	 *																	 *
	 * Also, we need to override the STDMULTI for this item and			 *
	 * set it to 100% of the base price.								 *
	 *********************************************************************/
	truncate table #tempContract
	insert into #tempContract
	select ItemCode, CustomerNo, DiscountMarkup1 from dbo.ods_IM_PriceCode
	where PriceCode is NULL
		  and ItemCode is not NULL 
		  and CustomerNo is not NULL 
		  and PricingMethod = 'P' -- PricingMethod P = $ off the base price
		  and DiscountMarkup1 != 0

	insert into atmp.F4072
	select
		N'DISCDOL' as ADAST,
		IMITM as ADITM,
		IMLITM COLLATE DATABASE_DEFAULT as ADLITM,
		IMAITM COLLATE DATABASE_DEFAULT as ADAITM,
		ABAN8 as ADAN8,
		0 as ADIGID,
		0 as ADCGID,
		0 as ADOGID,
		N'USD' as ADCRCD,
		N'EA' as ADUOM,
		-9999 as ADMNQ,
		118001 as ADEFTJ,
		140366 as ADEXDJ,
		N'5' as ADBSCD, -- Basis code = 5 means ADFVTR is a dollar amount
		N'' as ADLEDG,
		N'' as ADFRMN, 
		round((-1*DiscountMarkup1)*10000,0) as ADFVTR, -- Sage holds this as a positive #, JDE as a negative
		N'N' as ADFGY,
		0 as ADTID,
		N'' as ADURCD,
		0 as ADURDT,
		0 as ADURAT,
		0 as ADURAB,
		N'' as ADURRF,
		0 as ADNBRORD,
		N'' as ADUOMVID,
		N'' as ADFVUM,
		N'1' as ADPARTFG,
		N'' as ADAPRS,
		@user as ADUSER,
		@pid as ADPID,
		@jobn as ADJOBN,
		@jToday as ADUPMJ,
		@tNow as ADTDAY,
		0 as ADBKTPID,
		N'' as ADCRCDVID,
		N'' as ADRULENAME
	from #tempContract
	join atmp.F4101 on IMLITM = rtrim(ItemCode) COLLATE DATABASE_DEFAULT 
	join atmp.F0101 on ABALKY = ltrim(rtrim(substring(CustomerNo, patindex('%[^0]%', CustomerNo), 20))) COLLATE DATABASE_DEFAULT

	/* 
	 * And we also have to add a 100% STDMULTI for these people
	 */
	insert into atmp.F4072
	select
		N'STDMULTI' as ADAST,
		IMITM as ADITM,
		IMLITM COLLATE DATABASE_DEFAULT as ADLITM,
		IMAITM COLLATE DATABASE_DEFAULT as ADAITM,
		ABAN8 as ADAN8,
		0 as ADIGID,
		0 as ADCGID,
		0 as ADOGID,
		N'USD' as ADCRCD,
		N'EA' as ADUOM,
		-9999 as ADMNQ,
		118001 as ADEFTJ,
		140366 as ADEXDJ,
		N'2' as ADBSCD, -- Basis code = 2 means ADFVTR is a percent
		N'' as ADLEDG,
		N'' as ADFRMN, 
		1000000 as ADFVTR, -- 100%
		N'N' as ADFGY,
		0 as ADTID,
		N'' as ADURCD,
		0 as ADURDT,
		0 as ADURAT,
		0 as ADURAB,
		N'' as ADURRF,
		0 as ADNBRORD,
		N'' as ADUOMVID,
		N'' as ADFVUM,
		N'1' as ADPARTFG,
		N'' as ADAPRS,
		@user as ADUSER,
		@pid as ADPID,
		@jobn as ADJOBN,
		@jToday as ADUPMJ,
		@tNow as ADTDAY,
		0 as ADBKTPID,
		N'' as ADCRCDVID,
		N'' as ADRULENAME
	from #tempContract
	join atmp.F4101 on IMLITM = rtrim(ItemCode) COLLATE DATABASE_DEFAULT 
	join atmp.F0101 on ABALKY = ltrim(rtrim(substring(CustomerNo, patindex('%[^0]%', CustomerNo), 20))) COLLATE DATABASE_DEFAULT

	-- adjust the rule numbers
	declare @maxrule FLOAT = (select MAX(ADATID) from N0E9SQL01.JDE_DEVELOPMENT.TESTDTA.F4072);
	update
		t
	set
		t.ADATID = t.newATID
	from (
		select ADATID, @maxrule + (ROW_NUMBER() OVER (ORDER BY [ADAST])) as newATID
		from atmp.F4072
	) as t	

	 DROP TABLE #tempContract

END
GO