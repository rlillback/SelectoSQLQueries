use SelectoJDE
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-------------------------------------------------------------------------------------------
-- Populate the Ship-To Customer Master atmp.F03012
--
-- HISTORY:
-- 01-Apr-2020 R.Lillback Updated per Laura's changes after first data load (created version)
-- 08-Apr-2020 R.Lillback Updated per Laura from PP to FP for freight code
-- 28-Apr-2020 R.Lillback Update AIAFT = 'Y' instead of 'N'
-- 29-Apr-2020 R.Lillback Update freight handling code to PP
-- 08-May-2020 R.Lillback Fixed issue with no leading 0s in join to ods_AR_Customer
-- 
--------------------------------------------------------------------------------------------
IF EXISTS(SELECT * FROM SYS.objects WHERE TYPE = 'P' AND name = N'usp_F03012_S3')
	DROP PROCEDURE dbo.usp_F03012_S3
GO

CREATE PROCEDURE dbo.usp_F03012_S3
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

	if OBJECT_ID(N'tempdb..#tempCustomer') is not NULL
		drop table #tempCustomer

	create table #tempCustomer (
		AN8 float not NULL,
		ALKY nchar(20) not NULL,
		CreditLimit float NULL,
		TERMSNUM nchar(2) NULL,
		EMAIL3 nchar(30) NULL,
		SHIPVIA nchar(30) NULL,
		SalesGroup nchar(3) NULL,
		Parent nchar(1) NULL,
		PriceGroup nchar(8) NULL,
	)

	insert into #tempCustomer 
		select ABAN8, ABALKY, NULL, NULL, NULL, NULL, NULL, N'', NULL
		from atmp.F0101 
		where ABAT1 = N'S3'

	update x
		set CreditLimit = ISNULL(c.CreditLimit, 0),
		    TERMSNUM = ISNULL(c.TermsCode, N'EE'),
		    EMAIL3 = ISNULL(left(c.EmailAddress,30) , N''),
		    SHIPVIA = ISNULL(left(c.ShipMethod,30), N''),
		    Parent = N'P',
		    PriceGroup = N'SU' + ISNULL(LEFT(c.PriceLevel,1), N'0')
	from #tempCustomer as x
		left join dbo.ods_AR_Customer as c on x.ALKY = ltrim(rtrim(substring(c.CustomerNo, patindex('%[^0]', c.CustomerNo), 20))) collate DATABASE_DEFAULT

	insert into atmp.F03012							   
	select
		CAST(ABAN8 AS FLOAT) AS AIAN8,
		N'00000' COLLATE Latin1_General_CI_AS_WS AS AICO,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIARC,
		CASE ABAC04
			WHEN N'348' THEN N'       92200' 
			ELSE N'       91900'
		END COLLATE Latin1_General_CI_AS_WS AS AIMCUR, -- //:TODO Does this change??
		CASE ABAC04
			when N'302' then N'50010'
			when N'313' then N'50010'
			when N'337' then N'50010'
			when N'338' then N'50070'
			when N'339' then N'50020'
			when N'346' then N'50010'
			when N'347' then N'50010'
			when N'348' then N'50010'
			when N'510' then N'55090'
			when N'535' then N'55090'
			else N'50010'
		end COLLATE Latin1_General_CI_AS_WS AS AIOBAR,
		CASE ABAC04
			when N'302' then N'005' -- was 002
			when N'313' then N'119'
			when N'337' then N'126'
			when N'338' then N'012'
			when N'339' then N'000'
			when N'346' then N'130'
			when N'347' then N'128'
			when N'348' then N'002'
			when N'510' then N'035'
			when N'535' then N'055'
			else N'000'
		end COLLATE Latin1_General_CI_AS_WS AS AIAIDR,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIKCOR,
		CAST(0 AS FLOAT) AS AIDCAR,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIDTAR,
		N'' COLLATE Latin1_General_CI_AS_WS AS AICRCD,
		N'' COLLATE Latin1_General_CI_AS_WS AS AITXA1,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIEXR1,
		CAST((tmp.[CreditLimit] * 1) AS FLOAT) AS AIACL, 
		N'N' COLLATE Latin1_General_CI_AS_WS AS AIHDAR,
		case tmp.[TERMSNUM] -- Per spreadsheet on Teams site
					when '00' then N'01'
					when '01' then N'1/1'  
					when '02' then N'2/1'
					when '05' then N'1.6'
					when '06' then N'1/2' 
					when '07' then N'1.5'  
					when '08' then N'6/1' 
					when '10' then N'N10'
					when '21' then N'N20' 
					when '30' then N'N30'
					when '36' then N'N36' 
					when '45' then N'N45' 
					when '60' then N'N60'
					when '90' then N'N90' 
					when '99' then N'H27'
					else N'01' 			 
		end COLLATE Latin1_General_CI_AS_WS AS AITRAR, 
		N'P' COLLATE Latin1_General_CI_AS_WS AS AISTTO,
		N'C' COLLATE Latin1_General_CI_AS_WS AS AIRYIN, 
		CASE 
			when Parent = N'' then N'P'
			else N'P'
		end COLLATE Latin1_General_CI_AS_WS AS AISTMT,
		ABAN8 AS AIARPY, 										
		CASE 
			when Parent = N'' then N'Y'
			else N'N'
		end COLLATE Latin1_General_CI_AS_WS AS AIATCS,
		N'P' COLLATE Latin1_General_CI_AS_WS AS AISITO,
		N'3' COLLATE Latin1_General_CI_AS_WS AS AISQNL,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIALGM, 
		SUBSTRING(ABALPH,1, 1) COLLATE Latin1_General_CI_AS_WS AS AICYCN,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIBO,
		N'' COLLATE Latin1_General_CI_AS_WS AS AITSTA,
		N'' COLLATE Latin1_General_CI_AS_WS AS AICKHC,
		0 AS AIDLC,
		N'N' COLLATE Latin1_General_CI_AS_WS AS AIDNLT,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIPLCR,
		0 AS AIRVDJ,
		CAST(0 AS FLOAT) AS AIDSO,
		N'' COLLATE Latin1_General_CI_AS_WS AS AICMGR,
		N'' COLLATE Latin1_General_CI_AS_WS AS AICLMG,
		CAST(0 AS FLOAT) AS AIDLQT,
		0 AS AIDLQJ,
		N'' COLLATE Latin1_General_CI_AS_WS AS AINBRR,
		N'N' COLLATE Latin1_General_CI_AS_WS AS AICOLL,
		CAST(0 AS FLOAT) AS AINBR1,
		CAST(0 AS FLOAT) AS AINBR2,
		CAST(0 AS FLOAT) AS AINBR3,
		CAST(0 AS FLOAT) AS AINBCL,
		N'N' COLLATE Latin1_General_CI_AS_WS AS AIAFC,
		CAST(0 AS FLOAT) AS AIFD,
		CAST(0 AS FLOAT) AS AIFP,
		N'N' COLLATE Latin1_General_CI_AS_WS AS AICFCE,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIAB2,
		0 AS AIDT1J,
		0 AS AIDFIJ,
		0 AS AIDLIJ,
		N'C' COLLATE Latin1_General_CI_AS_WS AS AIABC1,
		N'C' COLLATE Latin1_General_CI_AS_WS AS AIABC2,
		N'C' COLLATE Latin1_General_CI_AS_WS AS AIABC3,
		0 AS AIFNDJ,
		0 AS AIDLP,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIDB,
		0 AS AIDNBJ,
		N'' COLLATE Latin1_General_CI_AS_WS AS AITRW,
		0 AS AITWDJ,
		CAST(0 AS FLOAT) AS AIAVD,
		N'USD' COLLATE Latin1_General_CI_AS_WS AS AICRCA,
		CAST(0 AS FLOAT) AS AIAD,
		CAST(0 AS FLOAT) AS AIAFCP,
		CAST(0 AS FLOAT) AS AIAFCY,
		CAST(0 AS FLOAT) AS AIASTY,
		CAST(0 AS FLOAT) AS AISPYE,
		CAST(0 AS FLOAT) AS AIAHB,
		CAST(0 AS FLOAT) AS AIALP,
		CAST(0 AS FLOAT) AS AIABAM,
		CAST(0 AS FLOAT) AS AIABA1,
		CAST(0 AS FLOAT) AS AIAPRC,
		CAST(0 AS FLOAT) AS AIMAXO,
		CAST(0 AS FLOAT) AS AIMINO,
		CAST(0 AS FLOAT) AS AIOYTD,
		CAST(0 AS FLOAT) AS AIOPY,
		N'SQLLD' COLLATE Latin1_General_CI_AS_WS AS AIPOPN,
		118001 AS AIDAOJ,
		CAST(1 AS FLOAT) AS AIAN8R,
		N'S' COLLATE Latin1_General_CI_AS_WS AS AIBADT, -- Change for ship-to only addresses
		PriceGroup COLLATE Latin1_General_CI_AS_WS AS AICPGP,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIORTP,
		CAST(0 AS FLOAT) AS AITRDC,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIINMG,
		N'N' COLLATE Latin1_General_CI_AS_WS AS AIEXHD,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIHOLD,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIROUT,
		N'' COLLATE Latin1_General_CI_AS_WS AS AISTOP,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIZON,
		CAST(0 AS FLOAT) AS AICARS,
		LEFT((tmp.EMAIL3),30) COLLATE Latin1_General_CI_AS_WS AS AIDEL1, --  TODO Map these
		LEFT((tmp.SHIPVIA),30) COLLATE Latin1_General_CI_AS_WS AS AIDEL2, -- TODO Map these
		CAST(0 AS FLOAT) AS AILTDT,
		N'PP' COLLATE Latin1_General_CI_AS_WS AS AIFRTH, 
		N'Y' COLLATE Latin1_General_CI_AS_WS AS AIAFT,
		N'Y' COLLATE Latin1_General_CI_AS_WS AS AIAPTS,
		N'N' COLLATE Latin1_General_CI_AS_WS AS AISBAL,
		N'Y' COLLATE Latin1_General_CI_AS_WS AS AIBACK,
		N'N' COLLATE Latin1_General_CI_AS_WS AS AIPORQ,
		N'0' COLLATE Latin1_General_CI_AS_WS AS AIPRIO,
		N'P' COLLATE Latin1_General_CI_AS_WS AS AIARTO,
		CAST(1 AS FLOAT) AS AIINVC,
		N'N' COLLATE Latin1_General_CI_AS_WS AS AIICON,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIBLFR,
		0 AS AINIVD,
		0 AS AILEDJ,
		N'N' COLLATE Latin1_General_CI_AS_WS AS AIPLST,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIMORD,
		CAST(0 AS FLOAT) AS AICMC1,
		CAST(0 AS FLOAT) AS AICMR1,
		CAST(0 AS FLOAT) AS AICMC2,
		CAST(0 AS FLOAT) AS AICMR2,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIPALC,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIVUMD,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIWUMD,
		case   												-- //TODO: Parent/child relationships??
			when Parent = N'' then N'P'
			else N'I' 
		end COLLATE Latin1_General_CI_AS_WS AS AIEDPM,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIEDII,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIEDCI,
		CAST(0 AS FLOAT) AS AIEDQD,
		CAST(0 AS FLOAT) AS AIEDAD,
		N'Y' COLLATE Latin1_General_CI_AS_WS AS AIEDF1,
		N'E' COLLATE Latin1_General_CI_AS_WS AS AIEDF2,
		N'Y' COLLATE Latin1_General_CI_AS_WS AS AISI01,
		N'Y' COLLATE Latin1_General_CI_AS_WS AS AISI02,
		N'' COLLATE Latin1_General_CI_AS_WS AS AISI03,
		N'' COLLATE Latin1_General_CI_AS_WS AS AISI04,
		N'' COLLATE Latin1_General_CI_AS_WS AS AISI05,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIURCD,
		CAST(0 AS FLOAT) AS AIURAT,
		CAST(0 AS FLOAT) AS AIURAB,
		0 AS AIURDT,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIURRF,
		N'' COLLATE Latin1_General_CI_AS_WS AS AICP01,
		N'SUWANEE' COLLATE Latin1_General_CI_AS_WS AS AIASN,
		N'N' COLLATE Latin1_General_CI_AS_WS AS AIDSPA,
		N'' COLLATE Latin1_General_CI_AS_WS AS AICRMD,
		CAST(8 AS FLOAT) AS AIPLY,
		CAST(0 AS FLOAT) AS AIMAN8,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIARL,
		CAST(0 AS FLOAT) AS AIAMCR,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIAC01,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIAC02,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIAC03,
		SalesGroup COLLATE Latin1_General_CI_AS_WS AS AIAC04,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIAC05,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIAC06,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIAC07,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIAC08,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIAC09,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIAC10,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIAC11,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIAC12,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIAC13,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIAC14,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIAC15,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIAC16,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIAC17,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIAC18,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIAC19,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIAC20,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIAC21,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIAC22,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIAC23,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIAC24,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIAC25,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIAC26,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIAC27,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIAC28,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIAC29,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIAC30,
		N'' COLLATE Latin1_General_CI_AS_WS AS AISLPG,
		N'' COLLATE Latin1_General_CI_AS_WS AS AISLDW,
		N'' COLLATE Latin1_General_CI_AS_WS AS AICFPP,
		N'' COLLATE Latin1_General_CI_AS_WS AS AICFSP,
		N'0' COLLATE Latin1_General_CI_AS_WS AS AICFDF,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIRQ01,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIRQ02,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIDR03,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIDR04,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIRQ03,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIRQ04,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIRQ05,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIRQ06,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIRQ07,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIRQ08,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIDR08,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIDR09,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIRQ09,
		@user COLLATE Latin1_General_CI_AS_WS AS AIUSER,
		@pid COLLATE Latin1_General_CI_AS_WS AS AIPID,
		@jToday AS AIUPMJ,
		@tNow AS AIUPMT,
		@jobn COLLATE Latin1_General_CI_AS_WS AS AIJOBN,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIPRGF,
		N'0' COLLATE Latin1_General_CI_AS_WS AS AIBYAL,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIBSC,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIASHL,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIPRSN,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIOPBO,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIAPSB,
		N'' COLLATE Latin1_General_CI_AS_WS AS AITIER1,
		CAST(0 AS FLOAT) AS AIPWPCP,
		N'0' COLLATE Latin1_General_CI_AS_WS AS AICUSTS,
		N'' COLLATE Latin1_General_CI_AS_WS AS AISTOF,
		CAST(0 AS FLOAT) AS AITERRID,
		CAST(0 AS FLOAT) AS AICIG,
		N'' COLLATE Latin1_General_CI_AS_WS AS AITORG,
		GETDATE() as AIDTEE,
		CAST(0 AS FLOAT) AS AISYNCS,
		CAST(0 AS FLOAT) AS AICAAD,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIGOPASF
	from
		atmp.F0101
		join #tempCustomer as tmp on ABAN8 = AN8
	-- implicit = where ABAT1 = N'S3'
END