use SelectoJDE
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ****************************************************************************************
-- Load Vendor data for all V3 reords.  Don't set the remittance address, it will happen
-- in another procedure.
--
-- PREREQUISITES: V3 is in UDC 01/ST
--                SUW is in UDC 01/01
--
-- HISTORY:
--   21-Jan-2020 R.Lillback Created initial version
--   10-Feb-2020 R.Lillback Updated the load to not bring in inactive vendors
--   10-Feb-2020 R.Lillback starting row number is now a next number NNN001 from NNSY = 01
--   17-Feb-2020 R.Lillback Set ABTAXC based on Form1099 in Vendor database per Laura
--   08-May-2020 R.Lillback Trim leading 0's from vendor codes
--
-- TODO:
--   
-- ****************************************************************************************
IF EXISTS(SELECT * FROM SYS.objects WHERE TYPE = 'P' AND name = N'usp_F0101_Vendor_Load')
	DROP PROCEDURE dbo.usp_F0101_Vendor_Load
GO

CREATE PROCEDURE dbo.usp_F0101_Vendor_Load
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
	declare @tmpMCU nchar(12) = (SELECT ABMCU FROM N0E9SQL01.JDE_DEVELOPMENT.TESTDTA.F0101 WHERE ABAN8 = 4590);

	-- set the starting customer number 
	declare @startingRowNum float = (select NNN001 from N0E9SQL01.JDE_DEVELOPMENT.TESTCTL.F0002 where NNSY = N'01');

	if OBJECT_ID(N'tempdb..#tempIntermediate') is not null
		drop table #tempIntermediate
	
	CREATE TABLE #tempIntermediate (
		[ROWNUM] [float] NULL,
		[VendCode] [nchar](20) NULL,
		[AlphaName] [nchar](40) NULL,
		[TaxId] [nchar](20) NULL,
		[CorpIdentity] [nchar](1) NULL,
		[RemittanceAddr] float NULL,
		[Form1099] [nchar](1) NULL,
	) 

	insert into #tempIntermediate 
		select 
			NULL as ROWNUM
		   ,ltrim(rtrim(substring(VendorNo, patindex('%[^0]%', VendorNo), 20))) as VendCode
		   ,LEFT(VendorName,40) as AlphaName
		   ,TaxPayerIdSocialSecurityNo as TaxId
		   ,N'C' as CorpIdentity
		   ,NULL as RemittanceAddr
		   ,Form1099
		from dbo.ods_AP_Vendor
		left join dbo.ods_VendorFlatFile on VendorNo = ALKY and AT1 = N'I' COLLATE DATABASE_DEFAULT
		where VendorStatus <> N'I' and ALKY is NULL

	-- now set the JDE address book numbers as ROW_NUMBER
	update x
		set x.ROWNUM = y.xrn, x.RemittanceAddr = y.xrn
	from #tempIntermediate as x
	join 
	(
		select  
			@startingRowNum
			+ ROW_NUMBER() OVER(ORDER BY VendCode) 
			- 1  as xrn,
			VendCode as cc
		from #tempIntermediate
	) as y on x.VendCode = y.cc
	                               
	insert into atmp.F0101
	select 
			CAST(INTER.ROWNUM AS FLOAT) AS ABAN8,
			INTER.VendCode COLLATE DATABASE_DEFAULT AS ABALKY,
			INTER.TaxId COLLATE DATABASE_DEFAULT AS ABTAX,
			INTER.AlphaName COLLATE DATABASE_DEFAULT AS ABALPH,
			N'' COLLATE DATABASE_DEFAULT AS ABDC,
			@tmpMCU COLLATE DATABASE_DEFAULT AS ABMCU, 
			N'' COLLATE DATABASE_DEFAULT AS ABSIC,
			N'' COLLATE DATABASE_DEFAULT AS ABLNGP,
			N'V3' COLLATE DATABASE_DEFAULT AS ABAT1, 
			N'' COLLATE DATABASE_DEFAULT AS ABCM,
			case (INTER.Form1099)
				when 'M'  then 'N'
				else 'C'
			end COLLATE DATABASE_DEFAULT AS ABTAXC,
			N'N' COLLATE DATABASE_DEFAULT AS ABAT2,
			N'N' COLLATE DATABASE_DEFAULT AS ABAT3,
			N'N' COLLATE DATABASE_DEFAULT AS ABAT4,
			N'N' COLLATE DATABASE_DEFAULT AS ABAT5,
			N'Y' COLLATE DATABASE_DEFAULT AS ABATP,
			N'N' COLLATE DATABASE_DEFAULT AS ABATR,
			N'N' COLLATE DATABASE_DEFAULT AS ABATPR,
			N'' COLLATE DATABASE_DEFAULT AS ABAB3,
			N'N' COLLATE DATABASE_DEFAULT AS ABATE,
			N'' COLLATE DATABASE_DEFAULT AS ABSBLI,
			119001 AS ABEFTB, 
			CAST(INTER.ROWNUM AS FLOAT) AS ABAN81,
			CAST(INTER.ROWNUM AS FLOAT) AS ABAN82,
			CAST(INTER.ROWNUM AS FLOAT) AS ABAN83,
			CAST(INTER.ROWNUM AS FLOAT) AS ABAN84,
			CAST(INTER.ROWNUM AS FLOAT) AS ABAN86,
			CAST(INTER.RemittanceAddr AS FLOAT) AS ABAN85,
			N'SUW' COLLATE DATABASE_DEFAULT AS ABAC01,
			N'' COLLATE DATABASE_DEFAULT AS ABAC02,
			N'' COLLATE DATABASE_DEFAULT AS ABAC03,
			N'' COLLATE DATABASE_DEFAULT AS ABAC04,
			N'' COLLATE DATABASE_DEFAULT AS ABAC05,
			N'' COLLATE DATABASE_DEFAULT AS ABAC06,
			N'' COLLATE DATABASE_DEFAULT AS ABAC07,
			N'' COLLATE DATABASE_DEFAULT AS ABAC08,
			N'' COLLATE DATABASE_DEFAULT AS ABAC09,
			N'' COLLATE DATABASE_DEFAULT AS ABAC10,
			N'' COLLATE DATABASE_DEFAULT AS ABAC11,
			N'N' COLLATE DATABASE_DEFAULT AS ABAC12,
			N'' COLLATE DATABASE_DEFAULT AS ABAC13,
			N'N' COLLATE DATABASE_DEFAULT AS ABAC14,
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
	from #tempIntermediate as INTER

	--
	-- Update the next number for addresses
	--
	update N0E9SQL01.JDE_DEVELOPMENT.TESTCTL.F0002 set NNN001 = (select max(ABAN8)+1 from atmp.F0101) where NNSY=N'01'

	drop table #tempIntermediate
	
END

GO
