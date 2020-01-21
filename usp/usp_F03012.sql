use JDE_DEVELOPMENT
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-------------------------------------------------------------------------------------------
-- Populate the Customer Master atmp.F03012
--
-- HISTORY:
-- 20-Jan-2020 R.Lillback Created initial file
-- 
-- TODO:
-- Laura to find out G/L Mapping for Customers
-- Ray to find out if we are importing credit limits from dbo.ods_AR_Customer CreditLimit
-- ### Figure out what else??
--------------------------------------------------------------------------------------------
IF EXISTS(SELECT * FROM SYS.objects WHERE TYPE = 'P' AND name = N'usp_F03012')
	DROP PROCEDURE atmp.usp_F03012
GO

CREATE PROCEDURE atmp.usp_F03012
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

	insert into atmp.F03012							   
	select
		CAST(ABAN8 AS FLOAT) AS AIAN8,
		N'00000' COLLATE Latin1_General_CI_AS_WS AS AICO,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIARC,
		N'       93320' COLLATE Latin1_General_CI_AS_WS AS AIMCUR, -- //:TODO Does this change??
		CASE -- //:TODO Update based on Accounting, once they figure out the details of ABAC04
			when ABAC04 = N'200' then N'50010'
			when ABAC04 = N'202' then N'50010'
			when ABAC04 = N'204' then N'50020'
			when ABAC04 = N'206' then N'50010'
			when ABAC04 = N'208' then N'50010'
			when ABAC04 = N'215' then N'50090'
			when ABAC04 = N'220' then N'50090'
			else N'50010'
		end COLLATE Latin1_General_CI_AS_WS AS AIOBAR,
		CASE -- //:TODO Update based on Accounting, once they figure out the details of ABAC04 
			when ABAC04 = N'200' then N'000'
			when ABAC04 = N'202' then N'008'
			when ABAC04 = N'204' then N'000'
			when ABAC04 = N'206' then N'010'
			when ABAC04 = N'208' then N'002' 
			when ABAC04 = N'215' then N'050'
			when ABAC04 = N'220' then N'060'
			else N'000'
		end COLLATE Latin1_General_CI_AS_WS AS AIAIDR,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIKCOR,
		CAST(0 AS FLOAT) AS AIDCAR,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIDTAR,
		N'' COLLATE Latin1_General_CI_AS_WS AS AICRCD,
		N'' COLLATE Latin1_General_CI_AS_WS AS AITXA1,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIEXR1,
		CAST((tmp.[Customer Credit Limit] * 1) AS FLOAT) AS AIACL, -- //TODO: Are there customer credit limits?
		N'N' COLLATE Latin1_General_CI_AS_WS AS AIHDAR,
		case tmp.[TERMSNUM] -- //TODO: Update terms once Laura finalizes them
					when '1' then N'N30'
					when '2' then N'N45'
					when '3' then N'N60'
					when '4' then N'H02'
					when '5' then N'H27'
					when '6' then N'D6' -- error
					when '7' then N'D7' -- error
					when '8' then N'03'
					when '9' then N'03'
					when '10' then N'D10' -- error
					when '11' then N'N15'
					when '12' then N'N10'
					when '13' then N'N7'
					when '14' then N'D14' -- error
					when '15' then N'D15' -- error
					when '16' then N'13'
					when '17' then N'10T'
					when '18' then N'D18' -- error
					when '19' then N'2/1'
					when '20' then N'D20' -- error
					else N'EE' -- error
		end COLLATE Latin1_General_CI_AS_WS AS AITRAR, 
		N'P' COLLATE Latin1_General_CI_AS_WS AS AISTTO,
		N'C' COLLATE Latin1_General_CI_AS_WS AS AIRYIN, -- Per Laura, default to C
		CASE 
			when Parent = N'' then N'P'
			else N'P'
		end COLLATE Latin1_General_CI_AS_WS AS AISTMT,
		CAST(round(aban8/10,0,1)*10 AS FLOAT) AS AIARPY,
		CASE 
			when Parent = N'' then N'Y'
			else N'N'
		end COLLATE Latin1_General_CI_AS_WS AS AIATCS,
		N'P' COLLATE Latin1_General_CI_AS_WS AS AISITO,
		N'3' COLLATE Latin1_General_CI_AS_WS AS AISQNL,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIALGM, -- Decided default to Blank
		SUBSTRING(ABALPH,1, 1) COLLATE Latin1_General_CI_AS_WS AS AICYCN,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIBO,
		CASE 
			when CI.CreditMesssage = N'CC' then N'CC'
			when CI.CreditMesssage = N'16' then N'16'
			else N''
		end COLLATE Latin1_General_CI_AS_WS AS AITSTA,
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
		CASE 
			when CreditMesssage = N'16' then N'S'
			else N'X'
		end COLLATE Latin1_General_CI_AS_WS AS AIBADT, -- //TODO: How does pricing work?
		CASE 
			when SalesGroup = N'200' then N'TEMDLR'
			when SalesGroup = N'202' then N'TEMCI50'
			when SalesGroup = N'204' then N'TEMMEM'
			when SalesGroup = N'206' then N'TEMDIR'
			when SalesGroup = N'215' then N'TEMXFR'
			when SalesGroup = N'220' then N'TEMXFR'
			else N'TEMDLR'
		end COLLATE Latin1_General_CI_AS_WS AS AICPGP,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIORTP,
		CAST(0 AS FLOAT) AS AITRDC,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIINMG,
		N'N' COLLATE Latin1_General_CI_AS_WS AS AIEXHD,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIHOLD,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIROUT,
		N'' COLLATE Latin1_General_CI_AS_WS AS AISTOP,
		N'' COLLATE Latin1_General_CI_AS_WS AS AIZON,
		CAST(0 AS FLOAT) AS AICARS,
		LEFT((tmp.EMAIL3),30) COLLATE Latin1_General_CI_AS_WS AS AIDEL1,
		LEFT((tmp.SHIPVIA),30) COLLATE Latin1_General_CI_AS_WS AS AIDEL2,
		CAST(0 AS FLOAT) AS AILTDT,
		N'PP' COLLATE Latin1_General_CI_AS_WS AS AIFRTH, -- Default to Pre-paid for now
		N'N' COLLATE Latin1_General_CI_AS_WS AS AIAFT,
		N'Y' COLLATE Latin1_General_CI_AS_WS AS AIAPTS,
		N'N' COLLATE Latin1_General_CI_AS_WS AS AISBAL,
		N'Y' COLLATE Latin1_General_CI_AS_WS AS AIBACK,
		N'N' COLLATE Latin1_General_CI_AS_WS AS AIPORQ,
		N'0' COLLATE Latin1_General_CI_AS_WS AS AIPRIO,
		CASE 
			when Parent = N'' then N'C'
			else N'P'
		end COLLATE Latin1_General_CI_AS_WS AS AIARTO,
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
		CASE
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
		CASE
			when SalesGroup = N'215' then N'TEMECXFR'
			when SalesGroup = N'220' then N'TEMECXFR'
			else N'TEMECULA' 
		END COLLATE Latin1_General_CI_AS_WS AS AIASN,
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
		CAST(N'0' AS FLOAT) AS AIPWPCP,
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
		atmp.tmp_CustomerIntermediate as CI
		join testdta.F0101 on ROWNUM = ABAN8
		join N01ADWSQLPD.KSTG.dbo.ods_Nimbus_Customer as tmp on CI.CustCode = tmp.[Customer Number] COLLATE Latin1_General_CI_AS_WS
END