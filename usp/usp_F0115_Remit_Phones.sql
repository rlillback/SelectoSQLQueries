USE SelectoJDE
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF EXISTS(SELECT * FROM SYS.objects WHERE TYPE = 'P' AND name = N'usp_F0115_Remit_Phones')
	DROP PROCEDURE dbo.usp_F0115_Remit_Phones
GO

CREATE PROCEDURE [dbo].[usp_F0115_Remit_Phones] 
AS
BEGIN
-- ****************************************************************************************
-- Import remit phone and fax numbers 
--
-- NOTES:
--
-- HISTORY:
--   12-Feb-2020 R.Lillback Created inital version
--   08-May-2020 R.Lillback Remove leading 0s from Vendor number
-- ****************************************************************************************
	SET NOCOUNT ON;
	if OBJECT_ID(N'tempdb..#TempPhones') is not null
		drop table #TempPhones
	if OBJECT_ID(N'tempdb..#TempOutput') is not null
		drop table #TempOutput
	

	create table #TempPhones (
		Code nvarchar(40),
		Name nvarchar(40),
		Leng float,
		Entr nvarchar(6),
		[WPAN8] [float] NOT NULL,
		[WPIDLN] [float] NOT NULL,
		[WPRCK7] [float] NOT NULL,
		[WPCNLN] [float] NOT NULL,
		[WPPHTP] [nchar](4) NULL,
		[WPAR1] [nchar](6) NULL,
		[WPPH1] [nchar](60) NULL,
		[WPUSER] [nchar](10) NULL,
		[WPPID] [nchar](10) NULL,
		[WPUPMJ] [numeric](18, 0) NULL,
		[WPJOBN] [nchar](10) NULL,
		[WPUPMT] [float] NULL,
		[WPCFNO1] [float] NULL,
		[WPGEN1] [nchar](10) NULL,
		[WPFALGE] [nchar](1) NULL,
		[WPSYNCS] [float] NULL,
		[WPCAAD] [float] NULL,
	)
	create table #TempOutput (
		Code nvarchar(40),
		Name nvarchar(40),
		Leng float,
		Entr nvarchar(6),
		[WPAN8] [float] NOT NULL,
		[WPIDLN] [float] NOT NULL,
		[WPRCK7] [float] NOT NULL,
		[WPCNLN] [float] NOT NULL,
		[WPPHTP] [nchar](4) NULL,
		[WPAR1] [nchar](6) NULL,
		[WPPH1] [nchar](60) NULL,
		[WPUSER] [nchar](10) NULL,
		[WPPID] [nchar](10) NULL,
		[WPUPMJ] [numeric](18, 0) NULL,
		[WPJOBN] [nchar](10) NULL,
		[WPUPMT] [float] NULL,
		[WPCFNO1] [float] NULL,
		[WPGEN1] [nchar](10) NULL,
		[WPFALGE] [nchar](1) NULL,
		[WPSYNCS] [float] NULL,
		[WPCAAD] [float] NULL,
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
	                          
	--===========================================================
	-- START VENDOR LOAD
	--===========================================================  
	insert into #TempPhones
		select 
			ltrim(rtrim(substring(V.ALKY, patindex('%[^0]%', V.ALKY), 20))) COLLATE Latin1_General_CI_AS_WS as Code,
			Vint.ABALPH COLLATE Latin1_General_CI_AS_WS as Name,
			1 As Leng,
			'Tel' as Entr,
			Vint.ABAN85 as WPAN8, -- Grab the remittance address not AN8
			CAST(0 as float) as WPIDLN,
			CAST(0 as float) as WPRCK7,
			CAST(0 as float) as WPCNLN,
			N'' as WWPHTP,
			V.PRE COLLATE Latin1_General_CI_AS_WS as WPPAR1,
			V.PH1 COLLATE Latin1_General_CI_AS_WS as WPPH1,
			@user COLLATE Latin1_General_CI_AS_WS as WPUSER,
			@pid COLLATE Latin1_General_CI_AS_WS as WPPID,
			@jToday as WPUPMJ,
			@jobn COLLATE Latin1_General_CI_AS_WS as WPJOBN,
			@tNow as WPUPMT,
			CAST(0 as float) as WPCFNO1,
			N'' COLLATE Latin1_General_CI_AS_WS as WPGEN1,
			N'' COLLATE Latin1_General_CI_AS_WS as WPFLAGE,
			CAST(0 as float) as WPSYNCS,
			CAST(0 as float) as WPCAAD
		from dbo.ods_VendorFlatFile as V
		join atmp.F0101 as Vint on ltrim(rtrim(substring(V.ALKY, patindex('%[^0]%', V.ALKY), 20))) = Vint.ABALKY collate DATABASE_DEFAULT
		where V.AT1 = N'R3' and V.PH1 != N''
	--===========================================================
	-- END VENDOR LOAD
	--===========================================================

	--===========================================================
	-- start file transform into JDE speak
	--===========================================================
	declare @AN8 float;
	declare rowCursor cursor for select distinct WPAN8 from #TempPhones

	open rowCursor;
	fetch next from rowCursor into @AN8;
	while @@FETCH_STATUS = 0 BEGIN
		INSERT INTO #TempOutput
			SELECT 
				Code,
				Name,
				Leng,
				Entr,
				WPAN8,
				WPIDLN,
				(ROW_NUMBER() OVER(Order By WPRCK7) - 1)as WPRCK7,
				WPCNLN,
				WPPHTP,
				WPAR1,
				WPPH1,
				WPUSER,
				WPPID,
				WPUPMJ,
				WPJOBN,
				WPUPMT,
				WPCFNO1,
				WPGEN1,
				WPFALGE,
				WPSYNCS,
				WPCAAD
			from #TempPhones
			where WPAN8 = @AN8 and Leng < 21 
		fetch next from rowCursor into @AN8;
	END -- cursor

	close rowCursor;
	deallocate rowCursor;

	--
	-- Copy the table over into atmp.F0115
	--
	insert into 
		atmp.F0115
	select
		WPAN8, WPIDLN, WPRCK7, WPCNLN, WPPHTP, WPAR1, WPPH1, WPUSER, WPPID, WPUPMJ, WPJOBN, WPUPMT, WPCFNO1, WPGEN1, WPFALGE, WPSYNCS, WPCAAD
	from #TempOutput

	drop table #TempOutput
	drop table #TempPhones
END

GO


