use SelectoJDE
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ****************************************************************************************
-- Populate atmp.F0101 with customer data from raw sage file
--
-- Prerequisites:  UDC 01/ST has C3 'Customers - Suwanee Only' in it
--
-- History: 
-- 20191119 - R.Lillback Created initial version
-- 12-Feb-2020 - R.Lillback Converted to next numbers from a fixed address number
-- 29-Mar-2020 - R.Lillback Updated credit message per Laura. All are '2' - PO Required
-- 08-May-2020 - R.Lillback Strip leading 0's from customer code
--
-- TODO:
--  
-- ****************************************************************************************
IF EXISTS(SELECT * FROM SYS.objects WHERE TYPE = 'P' AND name = N'usp_F0101_Load_Customer')
	DROP PROCEDURE dbo.usp_F0101_Load_Customer
GO

CREATE PROCEDURE dbo.usp_F0101_Load_Customer
AS
BEGIN

	SET NOCOUNT ON;

	-- Set the JDE audit data
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


	-- get the proper format for the 1 MCU
	declare @tmpMCU nchar(12) = (SELECT ABMCU FROM N0E9SQL01.JDE_DEVELOPMENT.TESTDTA.F0101 WHERE ABAN8 = 4590); 

	-- set the starting customer number 
	declare @startingRowNum float = (select NNN001 from N0E9SQL01.JDE_DEVELOPMENT.TESTCTL.F0002 where NNSY = N'01');

	if OBJECT_ID(N'tempdb..#tempIntermediate') is not null
		drop table #tempIntermediate
	
	CREATE TABLE #tempIntermediate (
		[ROWNUM] [float] NULL,
		[CustCode] [nvarchar](20) NULL,
		[AlphaName] [nvarchar](40) NULL,
		[CreditMesssage] [nvarchar](2) NULL,
		[SalesGroup] [nvarchar](3) NULL,
		[Parent] [nvarchar](25) NULL,
	) 

	insert into #tempIntermediate 
		select 
			NULL as ROWNUM
		   ,ltrim(rtrim(substring(CustomerNo, patindex('%[^0]%', CustomerNo), 20))) as CustCode
		   ,UPPER(CustomerName) as AlphaName
		   ,N'' as CreditMessage 
		   ,ISNULL(b.ABAC04, N'') as SalesGroup 
		   ,NULL as Parent
		from dbo.ods_AR_Customer as a
		     left join dbo.ods_SalesCodeFlatFile as b on a.CustomerNo = b.ABALKY collate database_default
		where CustomerStatus <> N'I'

	-- now set the JDE address book numbers as ROW_NUMBER
	update x
		set x.ROWNUM = y.xrn
	from #tempIntermediate as x
	join 
	(
		select  
			@startingRowNum
			+ ROW_NUMBER() OVER(ORDER BY CustCode) 
			- 1  as xrn,
			CustCode as cc
		from #tempIntermediate
	) as y on x.CustCode = y.cc
                              
	insert into atmp.F0101
	select 
		ROWNUM AS ABAN8,
		CustCode COLLATE DATABASE_DEFAULT AS ABALKY, -- Copy Sage Customer No into JDE
		N'' COLLATE DATABASE_DEFAULT AS ABTAX,
		AlphaName COLLATE DATABASE_DEFAULT AS ABALPH,
		N'' COLLATE DATABASE_DEFAULT AS ABDC,
		@tmpMCU COLLATE DATABASE_DEFAULT AS ABMCU, -- Set MCU = 1, there aren't branches for AB records
		N'' COLLATE DATABASE_DEFAULT AS ABSIC,
		N'' COLLATE DATABASE_DEFAULT AS ABLNGP,
		N'C3' COLLATE DATABASE_DEFAULT AS ABAT1, 
		N'2' COLLATE DATABASE_DEFAULT AS ABCM,	
		N'' COLLATE DATABASE_DEFAULT AS ABTAXC,	-- Set tax to print as 12-3456789 vs 123-45-6789
		N'' COLLATE DATABASE_DEFAULT AS ABAT2,
		N'N' COLLATE DATABASE_DEFAULT AS ABAT3,
		N'N' COLLATE DATABASE_DEFAULT AS ABAT4,
		N'N' COLLATE DATABASE_DEFAULT AS ABAT5,
		N'N' COLLATE DATABASE_DEFAULT AS ABATP,
		N'Y' COLLATE DATABASE_DEFAULT AS ABATR, 
		N'N' COLLATE DATABASE_DEFAULT AS ABATPR,
		N'' COLLATE DATABASE_DEFAULT AS ABAB3,
		N'N' COLLATE DATABASE_DEFAULT AS ABATE,
		N'' COLLATE DATABASE_DEFAULT AS ABSBLI,
		119001 AS ABEFTB,					-- Jan 1, 2019 is effective date
		CAST(ROWNUM AS FLOAT) AS ABAN81,
		CAST(ROWNUM AS FLOAT) AS ABAN82,
		CAST(ROWNUM AS FLOAT) AS ABAN83,
		CAST(ROWNUM AS FLOAT) AS ABAN84,
		CAST(ROWNUM AS FLOAT) AS ABAN86,
		CAST(ROWNUM AS FLOAT) AS ABAN85,
		N'SUW' COLLATE DATABASE_DEFAULT AS ABAC01,
		N'' COLLATE DATABASE_DEFAULT AS ABAC02,
		N'' COLLATE DATABASE_DEFAULT AS ABAC03,
		SalesGroup COLLATE DATABASE_DEFAULT AS ABAC04,
		N'A' COLLATE DATABASE_DEFAULT AS ABAC05,
		N'' COLLATE DATABASE_DEFAULT AS ABAC06,
		N'' COLLATE DATABASE_DEFAULT AS ABAC07,
		N'' COLLATE DATABASE_DEFAULT AS ABAC08,
		N'' COLLATE DATABASE_DEFAULT AS ABAC09,
		N'' COLLATE DATABASE_DEFAULT AS ABAC10,
		N'' COLLATE DATABASE_DEFAULT AS ABAC11,
		N'' COLLATE DATABASE_DEFAULT AS ABAC12,
		N'' COLLATE DATABASE_DEFAULT AS ABAC13,
		N'' COLLATE DATABASE_DEFAULT AS ABAC14,
		N'' COLLATE DATABASE_DEFAULT AS ABAC15,
		N'' COLLATE DATABASE_DEFAULT AS ABAC16,
		N'' COLLATE DATABASE_DEFAULT AS ABAC17,
		N'' COLLATE DATABASE_DEFAULT AS ABAC18,
		N'' COLLATE DATABASE_DEFAULT AS ABAC19,
		N'' COLLATE DATABASE_DEFAULT AS ABAC20,
		N'' COLLATE DATABASE_DEFAULT AS ABAC21,
		N'' COLLATE DATABASE_DEFAULT AS ABAC22,
		N'' COLLATE DATABASE_DEFAULT AS ABAC23,
		N'' COLLATE DATABASE_DEFAULT AS ABAC24,
		N'' COLLATE DATABASE_DEFAULT AS ABAC25,
		N'' COLLATE DATABASE_DEFAULT AS ABAC26,
		N'' COLLATE DATABASE_DEFAULT AS ABAC27,
		N'' COLLATE DATABASE_DEFAULT AS ABAC28,
		N'' COLLATE DATABASE_DEFAULT AS ABAC29,
		N'' COLLATE DATABASE_DEFAULT AS ABAC30,
		N'' COLLATE DATABASE_DEFAULT AS ABGLBA,
		CAST(0 AS FLOAT) AS ABPTI,
		0 AS ABPDI,
		N'' COLLATE DATABASE_DEFAULT AS ABMSGA,
		N'' COLLATE DATABASE_DEFAULT AS ABRMK,
		N'' COLLATE DATABASE_DEFAULT AS ABTXCT,
		N'' COLLATE DATABASE_DEFAULT AS ABTX2,
		N'' COLLATE DATABASE_DEFAULT AS ABALP1,
		N'' COLLATE DATABASE_DEFAULT AS ABURCD,
		0 AS ABURDT,
		CAST(0 AS FLOAT) AS ABURAT,
		CAST(0 AS FLOAT) AS ABURAB,
		N'' COLLATE DATABASE_DEFAULT AS ABURRF,
		@user COLLATE DATABASE_DEFAULT AS ABUSER,
		@pid COLLATE DATABASE_DEFAULT AS ABPID,
		@jToday AS ABUPMJ,
		@jobn COLLATE DATABASE_DEFAULT AS ABJOBN,
		CAST(@tNow AS FLOAT) AS ABUPMT,
		N'' COLLATE DATABASE_DEFAULT AS ABPRGF,
		N'' COLLATE DATABASE_DEFAULT AS ABSCCLTP,
		N'' COLLATE DATABASE_DEFAULT AS ABTICKER,
		N'' COLLATE DATABASE_DEFAULT AS ABEXCHG,
		N'' COLLATE DATABASE_DEFAULT AS ABDUNS,
		N'' COLLATE DATABASE_DEFAULT AS ABCLASS01,
		N'' COLLATE DATABASE_DEFAULT AS ABCLASS02,
		N'' COLLATE DATABASE_DEFAULT AS ABCLASS03,
		N'' COLLATE DATABASE_DEFAULT AS ABCLASS04,
		N'' COLLATE DATABASE_DEFAULT AS ABCLASS05,
		CAST(0 AS FLOAT) AS ABNOE,
		CAST(0 AS FLOAT) AS ABGROWTHR,
		N'' COLLATE DATABASE_DEFAULT AS ABYEARSTAR,
		N'' COLLATE DATABASE_DEFAULT AS ABAEMPGP,
		N'' COLLATE DATABASE_DEFAULT AS ABACTIN,
		N'' COLLATE DATABASE_DEFAULT AS ABREVRNG,
		CAST(0 AS FLOAT) AS ABSYNCS,
		CAST(0 AS FLOAT) AS ABPERRS,
		CAST(0 AS FLOAT) AS ABCAAD
	from #tempIntermediate

	drop table #tempIntermediate 
	
	--
	-- Update the next number for addresses
	--
	update N0E9SQL01.JDE_DEVELOPMENT.TESTCTL.F0002 set NNN001 = (select max(ABAN8)+1 from atmp.F0101) where NNSY=N'01'

END

GO

