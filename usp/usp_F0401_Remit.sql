use SelectoJDE
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-------------------------------------------------------------------------------------------
-- Populate the Vendor Master records.
--
-- 12-Feb-2020 R.Lillback Created Initial Version
--------------------------------------------------------------------------------------------
IF EXISTS(SELECT * FROM SYS.objects WHERE TYPE = 'P' AND name = N'usp_F0401_Remit')
	DROP PROCEDURE dbo.usp_F0401_Remit
GO

CREATE PROCEDURE dbo.usp_F0401_Remit
AS
BEGIN
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

	if OBJECT_ID(N'tempdb..#tempFile') is not NULL
		drop table #tempFile

	create table #tempFile (
		ALKY nchar(20) not NULL,
		AN8 float,
		AN85 float
	)

	--
	-- Populate the list of remit addresses
	--
	insert into #tempFile
		select ALKY, 0,0 
		from dbo.ods_VendorFlatFile
		where AT1 = N'R3'

	--
	-- Update the parent & remit addresses
	-- Note this works because ALKY = V3 records (ALKY + ' R3' is R3 records)
	--
	update x
	set AN8 = ABAN8, AN85 = ABAN85
	from #tempFile as x
	join atmp.F0101 on ALKY = ABALKY COLLATE DATABASE_DEFAULT 

	insert into atmp.F0401								   
	select distinct
			AN85 AS A6AN8, -- Grab this from the temp file
			A6APC,
			A6MCUP,
			A6OBAP,
			A6AIDP,
			A6KCOP,
			A6DCAP,
			A6DTAP,
			A6CRRP,
			A6TXA2,
			A6EXR2,
			A6HDPY,
			A6TXA3,
			A6EXR3,
			A6TAWH,
			A6PCWH, 
			A6TRAP,
			A6SCK,
			A6PYIN,
			A6SNTO,
			A6AB1,
			A6FLD,
			A6SQNL,
			A6CRCA,
			A6AYPD,
			A6APPD,
			A6ABAM,
			A6ABA1,
			A6APRC,
			A6MINO,
			A6MAXO,
			A6AN8R,
			A6BADT,
			A6CPGP,
			A6ORTP,
			A6INMG,
			A6HOLD,
			A6ROUT,
			A6STOP,
			A6ZON,
			A6ANCR,
			A6CARS,
			A6DEL1,
			A6DEL2,
			A6LTDT,
			A6FRTH,
			A6INVC,
			A6PLST,
			A6WUMD,
			A6VUMD,
			A6PRP5,
			A6EDPM,
			A6EDCI,
			A6EDII,
			A6EDQD,
			A6EDAD,
			A6EDF1,
			A6EDF2,
			A6VI01,
			A6VI02,
			A6VI03,
			A6VI04,
			A6VI05,
			A6MNSC,
			A6ATO,
			A6RVNT,
			A6URCD,
			A6URDT,
			A6URAT,
			A6URAB,
			A6URRF,
			@user COLLATE DATABASE_DEFAULT AS A6USER,
			@pid COLLATE DATABASE_DEFAULT AS A6PID,
			@jobn COLLATE DATABASE_DEFAULT AS A6JOBN,
			@jToday AS A6UPMJ,
			CAST(@tnow AS FLOAT) AS A6UPMT,
			A6ASN,
			A6CRMD,
			A6AVCH,
			A6ATRL
	from #tempFile
		join atmp.F0401 on AN8 = A6AN8
	
END

