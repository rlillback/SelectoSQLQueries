use SelectoJDE
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ****************************************************************************************
-- Load Vendor data for all R3 reords. Update the V3 remittance address, too
--
-- PREREQUISITES: R3 is in UDC 01/ST
--                SUW is in UDC 01/01
--
-- HISTORY:
--   11-Feb-2020 R.Lillback Created initial version
--	 08-May-2020 R.Lillback remove leading zeros from vendor code
--   09-May-2020 R.Lillback Fix bug in vendor update
--   20-May-2020 R.Lillback Set ABAC02 = 'SUW'
--   06-Jun-2020 R.Lillback Updated remit AN8 to use the accounting range, but not rules
-- ****************************************************************************************
IF EXISTS(SELECT * FROM SYS.objects WHERE TYPE = 'P' AND name = N'usp_F0101_Remit_Load')
	DROP PROCEDURE dbo.usp_F0101_Remit_Load
GO

CREATE PROCEDURE dbo.usp_F0101_Remit_Load
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
	declare @startingRowNum float = (select (MAX(ABAN8)) from N0E9SQL01.JDE_DEVELOPMENT.TESTDTA.F0101 where ABAT1 = 'R');

	if OBJECT_ID(N'tempdb..#tempIntermediate') is not null
		drop table #tempIntermediate
	
	CREATE TABLE #tempIntermediate (
		[ROWNUM] [float] NULL,
		[VendCode] [nchar](20) NULL,
		[AlphaName] [nchar](40) NULL,
		[TaxId] [nchar](20) NULL,
		[CorpIdentity] [nchar](1) NULL,
		[RemittanceAddr] float NULL,
		[ParentAddr] float NULL,
	) 

	--
	-- Grab all fo the vendor remit addresses from the flat file
	--
	insert into #tempIntermediate 
		select 
			(100000 + (select ABAN8 from atmp.F0101 where ABAT1 = 'V3' and ABALKY = ltrim(rtrim(substring(VendorNo, patindex('%[^0]%', VendorNo), 20))))) as ROWNUM
		   ,ltrim(rtrim(substring(VendorNo, patindex('%[^0]%', VendorNo), 20))) as VendCode
		   ,UPPER(LEFT(VendorName,40)) as AlphaName
		   ,TaxPayerIdSocialSecurityNo as TaxId
		   ,N'C' as CorpIdentity
		   ,(100000 + (select ABAN8 from atmp.F0101 where ABAT1 = 'V3' and ABALKY = ltrim(rtrim(substring(VendorNo, patindex('%[^0]%', VendorNo), 20))))) as RemittanceAddr
		   ,NULL as ParentAddr
		from dbo.ods_AP_Vendor
		join dbo.ods_VendorFlatFile on VendorNo = ALKY and AT1 = N'R3' COLLATE DATABASE_DEFAULT
		where VendorStatus <> N'I' 

		--
	-- now set the JDE address book numbers for the parent address
	--
	update #tempIntermediate
	set ParentAddr = (select ABAN8 from atmp.F0101 where VendCode = ABALKY COLLATE DATABASE_DEFAULT)
	                               
	insert into atmp.F0101
	select 
			CAST(INTER.ROWNUM AS FLOAT) AS ABAN8,
			RIGHT((RTRIM(INTER.VendCode) + N' R3'), 20) COLLATE DATABASE_DEFAULT AS ABALKY,
			INTER.TaxId COLLATE DATABASE_DEFAULT AS ABTAX,
			INTER.AlphaName COLLATE DATABASE_DEFAULT AS ABALPH,
			N'' COLLATE DATABASE_DEFAULT AS ABDC,
			@tmpMCU COLLATE DATABASE_DEFAULT AS ABMCU, 
			N'' COLLATE DATABASE_DEFAULT AS ABSIC,
			N'' COLLATE DATABASE_DEFAULT AS ABLNGP,
			N'R3' COLLATE DATABASE_DEFAULT AS ABAT1, 
			N'' COLLATE DATABASE_DEFAULT AS ABCM,
			INTER.CorpIdentity COLLATE DATABASE_DEFAULT AS ABTAXC,
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
	-- Now update all of the remittance addresses ABAN85 for all the parents
	--
	update x
	set ABAN85 = RemittanceAddr 
	from atmp.F0101 as x
	join #tempIntermediate on ABALKY = VendCode COLLATE DATABASE_DEFAULT
	where ABAN8 in (select ParentAddr from #tempIntermediate)

	drop table #tempIntermediate
	
END

GO
