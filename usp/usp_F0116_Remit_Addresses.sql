USE SelectoJDE
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF EXISTS(SELECT * FROM SYS.objects WHERE TYPE = 'P' AND name = N'usp_F0116_Remit_Addresses')
	DROP PROCEDURE dbo.usp_F0116_Remit_Addresses
GO

CREATE PROCEDURE [dbo].[usp_F0116_Remit_Addresses] 
AS
BEGIN
-- ****************************************************************************************
-- Import vendor V3 address entries into atmp.F0116
--
-- NOTES:
--
-- HISTORY:
--   12-Feb-2020 R.Lillback Created initial version
--   17-Feb-2020 R.Lillback Only load first 5 digits of zip code per Laura
--	 19-Feb-2020 R.Lillback Look up county from F0117 per Laura
--   08-May-2020 R.Lillback Remove leading 0s from vendor addresses
-- ****************************************************************************************
	SET NOCOUNT ON;
	if OBJECT_ID(N'tempdb..#tempAddresses') is not null
		drop table #tempAddresses

	CREATE TABLE #tempAddresses(
		Code varchar(10),
		Name varchar(40),
		[ALAN8] [float] NOT NULL,
		[ALEFTB] [numeric](18, 0) NOT NULL,
		[ALEFTF] [nchar](1) NULL,
		[ALADD1] [nchar](40) NULL,
		[ALADD2] [nchar](40) NULL,
		[ALADD3] [nchar](40) NULL,
		[ALADD4] [nchar](40) NULL,
		[ALADDZ] [nchar](12) NULL,
		[ALCTY1] [nchar](25) NULL,
		[ALCOUN] [nchar](25) NULL,
		[ALADDS] [nchar](3) NULL,
		[ALCRTE] [nchar](4) NULL,
		[ALBKML] [nchar](2) NULL,
		[ALCTR] [nchar](3) NULL,
		[ALUSER] [nchar](10) NULL,
		[ALPID] [nchar](10) NULL,
		[ALUPMJ] [numeric](18, 0) NULL,
		[ALJOBN] [nchar](10) NULL,
		[ALUPMT] [float] NULL,
		[ALSYNCS] [float] NULL,
		[ALCAAD] [float] NULL,
	)

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

	--
	-- Gather the Vendor addresses
	--
	insert into #tempAddresses
		select
			ltrim(rtrim(substring(V.ALKY, patindex('%[^0]%', V.ALKY), 20))) COLLATE Latin1_General_CI_AS_WS as Code,
			Vint.ABALPH COLLATE Latin1_General_CI_AS_WS as Name,
			Vint.ABAN85 as ALAN8, 
			119001 as ALEFTB, -- Make sure to have and effective date of 1-Jan-2019 in case of any backdating
			N'0' COLLATE Latin1_General_CI_AS_WS as ALEFTF,
			ISNULL(LEFT(V.ADD1,40), N'') COLLATE Latin1_General_CI_AS_WS as ALADD1,
			ISNULL(LEFT(V.ADD2,40), N'') COLLATE Latin1_General_CI_AS_WS as ALADD2,
			N'' COLLATE Latin1_General_CI_AS_WS as ALADD3,
			N'' COLLATE Latin1_General_CI_AS_WS as ALADD4,
			ISNULL(LEFT(V.ADDZ,5), N'') COLLATE Latin1_General_CI_AS_WS as ALADDZ,
			ISNULL(V.CTY1, N'') COLLATE Latin1_General_CI_AS_WS as ALCTY1,
			ALCOUN = ISNULL((select top 1 A8COUN from N0E9SQL01.JDE_DEVELOPMENT.TESTDTA.F0117 where A8ADDZ = LEFT(V.ADDZ,5) COLLATE DATABASE_DEFAULT),N''),
			ISNULL(V.ADDS, N'') COLLATE Latin1_General_CI_AS_WS as ALADDS,
			N'' COLLATE Latin1_General_CI_AS_WS as ALCRTE,
			N'' COLLATE Latin1_General_CI_AS_WS as ALBKML,
			V.CTR COLLATE Latin1_General_CI_AS_WS as ALCTR,
			@user COLLATE Latin1_General_CI_AS_WS AS ALUSER,
			@pid COLLATE Latin1_General_CI_AS_WS AS ALPID,
			@jToday as ALUPMJ,
			@jobn COLLATE Latin1_General_CI_AS_WS AS ALJOBN,
			@tNow AS ALUPMT,
			CAST(0 AS FLOAT) AS ALSYNCS,
			CAST(0 AS FLOAT) AS ALCAAD
		from dbo.ods_VendorFlatFile as V
		join atmp.F0101 as Vint on ltrim(rtrim(substring(V.ALKY, patindex('%[^0]%', V.ALKY), 20))) = Vint.ABALKY
		where V.AT1 = N'R3'
		
		
	insert into	
		atmp.F0116
	select 
		ALAN8, ALEFTB, ALEFTF, ALADD1, ALADD2, ALADD3, ALADD4, ALADDZ, ALCTY1, ALCOUN, ALADDS, ALCRTE, ALBKML, ALCTR, ALUSER, ALPID, ALUPMJ, ALJOBN, ALUPMT, ALSYNCS, ALCAAD
    from 
		#tempAddresses

	drop table #tempAddresses
END

GO


