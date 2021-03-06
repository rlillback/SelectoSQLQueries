use SelectoJDE
go
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ****************************************************************************************
-- Populate JDE's F0911Z1 file with data from the open invoice file
--
-- History: 
-- 16-Jul-2020 R.Lillback Created Initial Version to merge usp_F0911Z1 and usp_F03011Z1
-- 05-Aug-2020 R.Lillback Update AJAN8 to pull from atmp.F0101 instead of JDE, as JDE
--                        isn't updated when this script runs
--  
-- ****************************************************************************************
IF EXISTS(SELECT * FROM SYS.objects WHERE TYPE = 'P' AND name = N'usp_OpenInvoiceLoad')
	DROP PROCEDURE dbo.usp_OpenInvoiceLoad
GO

CREATE PROCEDURE dbo.usp_OpenInvoiceLoad
AS
BEGIN

	SET NOCOUNT ON;

	if object_id(N'tempdb..#F0911Z1') is not null
		drop table #F0911Z1

	CREATE TABLE #F0911Z1(
		[VNEDUS] [nchar](10) NOT NULL,
		[VNEDTY] [nchar](1) NULL,
		[VNEDSQ] [float] NULL,
		[VNEDTN] [nchar](22) NOT NULL,
		[VNEDCT] [nchar](2) NULL,
		[VNEDLN] [float] NOT NULL,
		[VNEDTS] [nchar](6) NULL,
		[VNEDFT] [nchar](10) NULL,
		[VNEDDT] [numeric](18, 0) NULL,
		[VNEDER] [nchar](1) NULL,
		[VNEDDL] [float] NULL,
		[VNEDSP] [nchar](1) NULL,
		[VNEDTC] [nchar](1) NULL,
		[VNEDTR] [nchar](1) NULL,
		[VNEDBT] [nchar](15) NOT NULL,
		[VNEDGL] [nchar](1) NULL,
		[VNEDAN] [float] NULL,
		[VNKCO] [nchar](5) NULL,
		[VNDCT] [nchar](2) NULL,
		[VNDOC] [float] NULL,
		[VNDGJ] [numeric](18, 0) NULL,
		[VNJELN] [float] NULL,
		[VNEXTL] [nchar](2) NULL,
		[VNPOST] [nchar](1) NULL,
		[VNICU] [float] NULL,
		[VNICUT] [nchar](2) NULL,
		[VNDICJ] [numeric](18, 0) NULL,
		[VNDSYJ] [numeric](18, 0) NULL,
		[VNTICU] [float] NULL,
		[VNCO] [nchar](5) NULL,
		[VNANI] [nchar](29) NULL,
		[VNAM] [nchar](1) NULL,
		[VNAID] [nchar](8) NULL,
		[VNMCU] [nchar](12) NULL,
		[VNOBJ] [nchar](6) NULL,
		[VNSUB] [nchar](8) NULL,
		[VNSBL] [nchar](8) NULL,
		[VNSBLT] [nchar](1) NULL,
		[VNLT] [nchar](2) NULL,
		[VNPN] [float] NULL,
		[VNCTRY] [float] NULL,
		[VNFY] [float] NULL,
		[VNFQ] [nchar](4) NULL,
		[VNCRCD] [nchar](3) NULL,
		[VNCRR] [float] NULL,
		[VNHCRR] [float] NULL,
		[VNHDGJ] [numeric](18, 0) NULL,
		[VNAA] [float] NULL,
		[VNU] [float] NULL,
		[VNUM] [nchar](2) NULL,
		[VNGLC] [nchar](4) NULL,
		[VNRE] [nchar](1) NULL,
		[VNEXA] [nchar](30) NULL,
		[VNEXR] [nchar](30) NULL,
		[VNR1] [nchar](8) NULL,
		[VNR2] [nchar](8) NULL,
		[VNR3] [nchar](8) NULL,
		[VNSFX] [nchar](3) NULL,
		[VNODOC] [float] NULL,
		[VNODCT] [nchar](2) NULL,
		[VNOSFX] [nchar](3) NULL,
		[VNPKCO] [nchar](5) NULL,
		[VNOKCO] [nchar](5) NULL,
		[VNPDCT] [nchar](2) NULL,
		[VNAN8] [float] NULL,
		[VNCN] [nchar](8) NULL,
		[VNDKJ] [numeric](18, 0) NULL,
		[VNDKC] [numeric](18, 0) NULL,
		[VNASID] [nchar](25) NULL,
		[VNBRE] [nchar](1) NULL,
		[VNRCND] [nchar](1) NULL,
		[VNSUMM] [nchar](1) NULL,
		[VNPRGE] [nchar](1) NULL,
		[VNTNN] [nchar](1) NULL,
		[VNALT1] [nchar](1) NULL,
		[VNALT2] [nchar](1) NULL,
		[VNALT3] [nchar](1) NULL,
		[VNALT4] [nchar](1) NULL,
		[VNALT5] [nchar](1) NULL,
		[VNALT6] [nchar](1) NULL,
		[VNALT7] [nchar](1) NULL,
		[VNALT8] [nchar](1) NULL,
		[VNALT9] [nchar](1) NULL,
		[VNALT0] [nchar](1) NULL,
		[VNALTT] [nchar](1) NULL,
		[VNALTU] [nchar](1) NULL,
		[VNALTV] [nchar](1) NULL,
		[VNALTW] [nchar](1) NULL,
		[VNALTX] [nchar](1) NULL,
		[VNALTZ] [nchar](1) NULL,
		[VNDLNA] [nchar](1) NULL,
		[VNCFF1] [nchar](1) NULL,
		[VNCFF2] [nchar](1) NULL,
		[VNASM] [nchar](1) NULL,
		[VNBC] [nchar](1) NULL,
		[VNVINV] [nchar](25) NULL,
		[VNIVD] [numeric](18, 0) NULL,
		[VNWR01] [nchar](4) NULL,
		[VNPO] [nchar](8) NULL,
		[VNPSFX] [nchar](3) NULL,
		[VNDCTO] [nchar](2) NULL,
		[VNLNID] [float] NULL,
		[VNWY] [float] NULL,
		[VNWN] [float] NULL,
		[VNFNLP] [nchar](1) NULL,
		[VNOPSQ] [float] NULL,
		[VNJBCD] [nchar](6) NULL,
		[VNJBST] [nchar](4) NULL,
		[VNHMCU] [nchar](12) NULL,
		[VNDOI] [float] NULL,
		[VNALID] [nchar](25) NULL,
		[VNALTY] [nchar](2) NULL,
		[VNDSVJ] [numeric](18, 0) NULL,
		[VNTORG] [nchar](10) NULL,
		[VNREG#] [float] NULL,
		[VNPYID] [float] NULL,
		[VNUSER] [nchar](10) NULL,
		[VNPID] [nchar](10) NULL,
		[VNJOBN] [nchar](10) NULL,
		[VNUPMJ] [numeric](18, 0) NULL,
		[VNUPMT] [float] NULL,
		[VNCRRM] [nchar](1) NULL,
		[VNACR] [float] NULL,
		[VNDGM] [float] NULL,
		[VNDGD] [float] NULL,
		[VNDGY] [float] NULL,
		[VNDG#] [float] NULL,
		[VNDICM] [float] NULL,
		[VNDICD] [float] NULL,
		[VNDICY] [float] NULL,
		[VNDIC#] [float] NULL,
		[VNDSYM] [float] NULL,
		[VNDSYD] [float] NULL,
		[VNDSYY] [float] NULL,
		[VNDSY#] [float] NULL,
		[VNDKM] [float] NULL,
		[VNDKD] [float] NULL,
		[VNDKY] [float] NULL,
		[VNDK#] [float] NULL,
		[VNDSVM] [float] NULL,
		[VNDSVD] [float] NULL,
		[VNDSVY] [float] NULL,
		[VNDSV#] [float] NULL,
		[VNHDGM] [float] NULL,
		[VNHDGD] [float] NULL,
		[VNHDGY] [float] NULL,
		[VNHDG#] [float] NULL,
		[VNDKCM] [float] NULL,
		[VNDKCD] [float] NULL,
		[VNDKCY] [float] NULL,
		[VNDKC#] [float] NULL,
		[VNIVDM] [float] NULL,
		[VNIVDD] [float] NULL,
		[VNIVDY] [float] NULL,
		[VNIVD#] [float] NULL,
		[VNABR1] [nchar](12) NULL,
		[VNABR2] [nchar](12) NULL,
		[VNABR3] [nchar](12) NULL,
		[VNABR4] [nchar](12) NULL,
		[VNABT1] [nchar](1) NULL,
		[VNABT2] [nchar](1) NULL,
		[VNABT3] [nchar](1) NULL,
		[VNABT4] [nchar](1) NULL,
		[VNITM] [float] NULL,
		[VNPM01] [nchar](1) NULL,
		[VNPM02] [nchar](1) NULL,
		[VNPM03] [nchar](1) NULL,
		[VNPM04] [nchar](1) NULL,
		[VNPM05] [nchar](1) NULL,
		[VNPM06] [nchar](1) NULL,
		[VNPM07] [nchar](1) NULL,
		[VNPM08] [nchar](1) NULL,
		[VNPM09] [nchar](1) NULL,
		[VNPM10] [nchar](1) NULL,
		[VNBCRC] [nchar](3) NULL,
		[VNEXR1] [nchar](2) NULL,
		[VNTXA1] [nchar](10) NULL,
		[VNTXITM] [float] NULL,
		[VNACTB] [nchar](10) NULL,
		[VNSTAM] [float] NULL,
		[VNCTAM] [float] NULL,
		[VNAG] [float] NULL,
		[VNAGF] [float] NULL,
		[VNTKTX] [nchar](1) NULL,
		[VNDLNID] [float] NULL,
		[VNCKNU] [nchar](25) NULL,
		[VNBUPC] [nchar](1) NULL,
		[VNAHBU] [nchar](12) NULL,
		[VNEPGC] [nchar](3) NULL,
		[VNJPGC] [nchar](3) NULL,
		[VNRC5] [float] NULL,
		[VNSFXE] [float] NULL,
		[VNOFM] [nchar](1) NULL,
	)


	if object_id(N'tempdb..#F03B11Z1') is not null
		drop table #F03B11Z1

	CREATE TABLE #F03B11Z1(
		[VJEDUS] [nchar](10) NOT NULL,
		[VJEDTY] [nchar](1) NULL,
		[VJEDSQ] [float] NULL,
		[VJEDTN] [nchar](22) NOT NULL,
		[VJEDCT] [nchar](2) NULL,
		[VJEDLN] [float] NOT NULL,
		[VJEDTS] [nchar](6) NULL,
		[VJEDFT] [nchar](10) NULL,
		[VJEDDT] [numeric](18, 0) NULL,
		[VJEDER] [nchar](1) NULL,
		[VJEDDL] [float] NULL,
		[VJEDSP] [nchar](1) NULL,
		[VJEDTC] [nchar](1) NULL,
		[VJEDTR] [nchar](1) NULL,
		[VJEDBT] [nchar](15) NOT NULL,
		[VJEDGL] [nchar](1) NULL,
		[VJEDDH] [nchar](1) NULL,
		[VJEDAN] [float] NULL,
		[VJDOC] [float] NULL,
		[VJDCT] [nchar](2) NULL,
		[VJKCO] [nchar](5) NULL,
		[VJSFX] [nchar](3) NULL,
		[VJAN8] [float] NULL,
		[VJDGJ] [numeric](18, 0) NULL,
		[VJDIVJ] [numeric](18, 0) NULL,
		[VJICUT] [nchar](2) NULL,
		[VJICU] [float] NULL,
		[VJDICJ] [numeric](18, 0) NULL,
		[VJFY] [float] NULL,
		[VJCTRY] [float] NULL,
		[VJPN] [float] NULL,
		[VJCO] [nchar](5) NULL,
		[VJGLC] [nchar](4) NULL,
		[VJAID] [nchar](8) NULL,
		[VJPA8] [float] NULL,
		[VJAN8J] [float] NULL,
		[VJPYR] [float] NULL,
		[VJPOST] [nchar](1) NULL,
		[VJISTR] [nchar](1) NULL,
		[VJBALJ] [nchar](1) NULL,
		[VJPST] [nchar](1) NULL,
		[VJAG] [float] NULL,
		[VJAAP] [float] NULL,
		[VJADSC] [float] NULL,
		[VJADSA] [float] NULL,
		[VJATXA] [float] NULL,
		[VJATXN] [float] NULL,
		[VJSTAM] [float] NULL,
		[VJCRRM] [nchar](1) NULL,
		[VJCRCD] [nchar](3) NULL,
		[VJCRR] [float] NULL,
		[VJDMCD] [nchar](1) NULL,
		[VJACR] [float] NULL,
		[VJFAP] [float] NULL,
		[VJCDS] [float] NULL,
		[VJCDSA] [float] NULL,
		[VJCTXA] [float] NULL,
		[VJCTXN] [float] NULL,
		[VJCTAM] [float] NULL,
		[VJTXA1] [nchar](10) NULL,
		[VJEXR1] [nchar](2) NULL,
		[VJDSVJ] [numeric](18, 0) NULL,
		[VJGLBA] [nchar](8) NULL,
		[VJAM] [nchar](1) NULL,
		[VJAID2] [nchar](8) NULL,
		[VJAM2] [nchar](1) NULL,
		[VJMCU] [nchar](12) NULL,
		[VJOBJ] [nchar](6) NULL,
		[VJSUB] [nchar](8) NULL,
		[VJSBLT] [nchar](1) NULL,
		[VJSBL] [nchar](8) NULL,
		[VJPTC] [nchar](3) NULL,
		[VJDDJ] [numeric](18, 0) NULL,
		[VJDDNJ] [numeric](18, 0) NULL,
		[VJRDDJ] [numeric](18, 0) NULL,
		[VJRDSJ] [numeric](18, 0) NULL,
		[VJSMTJ] [numeric](18, 0) NULL,
		[VJNBRR] [nchar](1) NULL,
		[VJRDRL] [nchar](1) NULL,
		[VJRMDS] [float] NULL,
		[VJCOLL] [nchar](1) NULL,
		[VJCORC] [nchar](2) NULL,
		[VJAFC] [nchar](1) NULL,
		[VJRSCO] [nchar](2) NULL,
		[VJCKNU] [nchar](25) NULL,
		[VJODOC] [float] NULL,
		[VJODCT] [nchar](2) NULL,
		[VJOKCO] [nchar](5) NULL,
		[VJOSFX] [nchar](3) NULL,
		[VJVINV] [nchar](25) NULL,
		[VJPO] [nchar](8) NULL,
		[VJPDCT] [nchar](2) NULL,
		[VJPKCO] [nchar](5) NULL,
		[VJDCTO] [nchar](2) NULL,
		[VJLNID] [float] NULL,
		[VJSDOC] [float] NULL,
		[VJSDCT] [nchar](2) NULL,
		[VJSKCO] [nchar](5) NULL,
		[VJSFXO] [nchar](3) NULL,
		[VJVLDT] [numeric](18, 0) NULL,
		[VJCMC1] [float] NULL,
		[VJVR01] [nchar](25) NULL,
		[VJUNIT] [nchar](8) NULL,
		[VJMCU2] [nchar](12) NULL,
		[VJRMK] [nchar](30) NULL,
		[VJALPH] [nchar](40) NULL,
		[VJRF] [nchar](2) NULL,
		[VJDRF] [float] NULL,
		[VJCTL] [nchar](13) NULL,
		[VJFNLP] [nchar](1) NULL,
		[VJITM] [float] NULL,
		[VJU] [float] NULL,
		[VJUM] [nchar](2) NULL,
		[VJALT6] [nchar](1) NULL,
		[VJRYIN] [nchar](1) NULL,
		[VJVDGJ] [numeric](18, 0) NULL,
		[VJVRE] [nchar](3) NULL,
		[VJRP1] [nchar](1) NULL,
		[VJRP2] [nchar](1) NULL,
		[VJRP3] [nchar](1) NULL,
		[VJAR01] [nchar](3) NULL,
		[VJAR02] [nchar](3) NULL,
		[VJAR03] [nchar](3) NULL,
		[VJAR04] [nchar](3) NULL,
		[VJAR05] [nchar](3) NULL,
		[VJAR06] [nchar](3) NULL,
		[VJAR07] [nchar](3) NULL,
		[VJAR08] [nchar](3) NULL,
		[VJAR09] [nchar](3) NULL,
		[VJAR10] [nchar](3) NULL,
		[VJURC1] [nchar](3) NULL,
		[VJURDT] [numeric](18, 0) NULL,
		[VJURAT] [float] NULL,
		[VJURAB] [float] NULL,
		[VJURRF] [nchar](15) NULL,
		[VJTORG] [nchar](10) NULL,
		[VJUSER] [nchar](10) NULL,
		[VJPID] [nchar](10) NULL,
		[VJUPMJ] [numeric](18, 0) NULL,
		[VJUPMT] [float] NULL,
		[VJJOBN] [nchar](10) NULL,
		[VJHCRR] [float] NULL,
		[VJHDGJ] [numeric](18, 0) NULL,
		[VJDIM] [float] NULL,
		[VJDID] [float] NULL,
		[VJDIY] [float] NULL,
		[VJDI#] [float] NULL,
		[VJDGM] [float] NULL,
		[VJDGD] [float] NULL,
		[VJDGY] [float] NULL,
		[VJDG#] [float] NULL,
		[VJDICM] [float] NULL,
		[VJDICD] [float] NULL,
		[VJDICY] [float] NULL,
		[VJDIC#] [float] NULL,
		[VJDSVM] [float] NULL,
		[VJDSVD] [float] NULL,
		[VJDSVY] [float] NULL,
		[VJDSV#] [float] NULL,
		[VJDDM] [float] NULL,
		[VJDDD] [float] NULL,
		[VJDDY] [float] NULL,
		[VJDD#] [float] NULL,
		[VJDDNM] [float] NULL,
		[VJDDND] [float] NULL,
		[VJDDNY] [float] NULL,
		[VJDDN#] [float] NULL,
		[VJSMTM] [float] NULL,
		[VJSMTD] [float] NULL,
		[VJSMTY] [float] NULL,
		[VJSMT#] [float] NULL,
		[VJRDDM] [float] NULL,
		[VJRDDD] [float] NULL,
		[VJRDDY] [float] NULL,
		[VJRDD#] [float] NULL,
		[VJRDSM] [float] NULL,
		[VJRDSD] [float] NULL,
		[VJRDSY] [float] NULL,
		[VJRDS#] [float] NULL,
		[VJHDGM] [float] NULL,
		[VJHDGD] [float] NULL,
		[VJHDGY] [float] NULL,
		[VJHDG#] [float] NULL,
		[VJSHPN] [float] NULL,
		[VJDTXS] [nchar](1) NULL,
		[VJOMOD] [nchar](1) NULL,
		[VJCLMG] [nchar](10) NULL,
		[VJCMGR] [nchar](10) NULL,
		[VJATAD] [float] NULL,
		[VJCTAD] [float] NULL,
		[VJNRTA] [float] NULL,
		[VJFNRT] [float] NULL,
		[VJPRGF] [nchar](1) NULL,
		[VJGFL1] [nchar](1) NULL,
		[VJGFL2] [nchar](1) NULL,
		[VJDOCO] [float] NULL,
		[VJKCOO] [nchar](5) NULL,
		[VJSOTF] [nchar](1) NULL,
		[VJDTPB] [numeric](18, 0) NULL,
		[VJERDJ] [numeric](18, 0) NULL,
		[VJNETST] [nchar](1) NULL,
		[VJRMR1] [nchar](50) NULL
	)

	if object_id(N'tempdb..#OpenInvoice') is not NULL
		drop table #OpenInvoice

	create table #OpenInvoice (
		EDUS nchar(10) NULL,
		EDTN nchar(22) NULL,
		EDSP nchar(1) NULL,
		EDTC nchar(1) NULL,
		EDTR nchar(1) NULL,
		EDBT nchar(15) NULL,
		EXA  nchar(30) NULL,
		EDLN numeric(7,3) NULL,
		CustomerNo nchar(20) NULL,
		InvoiceDate date NULL,
		Balance numeric(13,2) NULL,
		TermsCode nchar(2) NULL,
		InvoiceDueDate date NULL,
		InvoiceDiscountDate date NULL,
		CustomerPONo nchar(15) NULL,
		InvoiceType nchar(2) NULL,
		InvoiceNo nchar(7) NULL,
	)

	--
	-- Populate the intermediate open invoice table
	--
	insert into #OpenInvoice
		select
			N'LEDGINGTON' as EDUS,
			N'' as EDTN,
			N'0' as EDSP,
			N'A' as EDTC,
			N'I' as EDTR,
			N'8023' as EDBT,
			N'OPEN AR CONVERSION' as EXA,
			1000 as EDLN,
			CustomerNo,
			InvoiceDate,
			Balance,
			TermsCode,
			InvoiceDueDate,
			InvoiceDiscountDate,
			CustomerPONo,
			InvoiceType,
			InvoiceNo
		from dbo.ods_AR_OpenInvoice
		where Balance <> 0

	--
	-- Set each transaction as a unique ID
	-- This transaction *must* be consistent between the 2 files
	--
	update x
		set x.EDTN = x.NewEDTN
	from (
		select 
			EDTN,
			ROW_NUMBER() over (order by CustomerNo asc) as NewEDTN
		from #OpenInvoice
	) as x

	--
	-- Create a Julian Date for today
	--
	declare @jToday numeric(18,0) = dbo.fn_DateTimeToJulian(GETDATE());

	--
	-- Copy data into the F0911Z1 from the intermediate open invoice file
	--
	insert into #F0911Z1
		select 
			EDUS as VNEDUS,
			N'' as VNEDTY,
			0 as VNEDSQ,
			EDTN as VNEDTN,
			N'' as VNEDCT,
			EDLN as VNEDLN,
			N'' as VNEDTS,
			N'' as VNEDFT,
			@jToday as VNEDDT,
			N'' as VNEDER,
			0 as VNEDDL,
			EDSP as VNEDSP,
			EDTC as VNEDTC,
			EDTR as VNEDTR,
			EDBT as VNEDBT,
			N'' as VNEDGL,
			821756 as VNEDAN,
			N'' as VNKCO,
			N'' as VNDCT,
			0 as VNDOC,
			@jToday as VNDGJ,
			0 as VNJELN,
			N'' as VNEXTL,
			N'' as VNPOST,
			0 as VNICU,
			N'IB' as VNICUT,
			@jToday as VNDICJ,
			@jToday as VNDSYJ,
			0 as VNTICU,
			N'' as VNCO,
			N'' as VNANI,
			N'1' as VNAM,
			N'00097005' as VNAID,
			N'' as VNMCU,
			N'' as VNOBJ,
			N'' as VNSUB,
			N'' as VNSBL,
			N'' as VNSBLT,
			N'AA' as VNLT,
			0 as VNPN,
			0 as VNCTRY,
			0 as VNFY,
			N'' as VNFQ,
			N'' as VNCRCD,
			0 as VNCRR,
			0 as VNHCRR,
			0 as VNHDGJ,
			cast((Balance * -100) as numeric(15,2)) as VNAA,
			0 as VNU,
			N'' as VNUM,
			N'' as VNGLC,
			N'' as VNRE,
			EXA as VNEXA,
			N'' as VNEXR,
			N'' as VNR1,
			N'' as VNR2,
			N'' as VNR3,
			N'' as VNSFX,
			0 as VNODOC,
			N'' as VNODCT,
			N'' as VNOSFX,
			N'' as VNPKCO,
			N'' as VNOKCO,
			N'' as VNPDCT,
			0 as VNAN8,
			N'' as VNCN,
			0 as VNDKJ,
			0 as VNDKC,
			N'' as VNASID,
			N'' as VNBRE,
			N'' as VNRCND,
			N'' as VNSUMM,
			N'' as VNPRGE,
			N'' as VNTNN,
			N'' as VNALT1,
			N'' as VNALT2,
			N'' as VNALT3,
			N'' as VNALT4,
			N'' as VNALT5,
			N'' as VNALT6,
			N'' as VNALT7,
			N'' as VNALT8,
			N'' as VNALT9,
			N'' as VNALT0,
			N'' as VNALTT,
			N'' as VNALTU,
			N'' as VNALTV,
			N'' as VNALTW,
			N'' as VNALTX,
			N'' as VNALTZ,
			N'' as VNDLNA,
			N'' as VNCFF1,
			N'' as VNCFF2,
			N'' as VNASM,
			N'' as VNBC,
			N'' as VNVINV,
			0 as VNIVD,
			N'' as VNWR01,
			N'' as VNPO,
			N'' as VNPSFX,
			N'' as VNDCTO,
			0 as VNLNID,
			0 as VNWY,
			0 as VNWN,
			N'' as VNFNLP,
			0 as VNOPSQ,
			N'' as VNJBCD,
			N'' as VNJBST,
			N'' as VNHMCU,
			0 as VNDOI,
			N'' as VNALID,
			N'' as VNALTY,
			0 as VNDSVJ,
			N'' as VNTORG,
			0 as VNREG#,
			0 as VNPYID,
			N'' as VNUSER,
			N'' as VNPID,
			N'' as VNJOBN,
			0 as VNUPMJ,
			0 as VNUPMT,
			N'' as VNCRRM,
			0 as VNACR,
			0 as VNDGM,
			0 as VNDGD,
			0 as VNDGY,
			0 as VNDG#,
			0 as VNDICM,
			0 as VNDICD,
			0 as VNDICY,
			0 as VNDIC#,
			0 as VNDSYM,
			0 as VNDSYD,
			0 as VNDSYY,
			0 as VNDSY#,
			0 as VNDKM,
			0 as VNDKD,
			0 as VNDKY,
			0 as VNDK#,
			0 as VNDSVM,
			0 as VNDSVD,
			0 as VNDSVY,
			0 as VNDSV#,
			0 as VNHDGM,
			0 as VNHDGD,
			0 as VNHDGY,
			0 as VNHDG#,
			0 as VNDKCM,
			0 as VNDKCD,
			0 as VNDKCY,
			0 as VNDKC#,
			0 as VNIVDM,
			0 as VNIVDD,
			0 as VNIVDY,
			0 as VNIVD#,
			N'' as VNABR1,
			N'' as VNABR2,
			N'' as VNABR3,
			N'' as VNABR4,
			N'' as VNABT1,
			N'' as VNABT2,
			N'' as VNABT3,
			N'' as VNABT4,
			0 as VNITM,
			N'' as VNPM01,
			N'' as VNPM02,
			N'' as VNPM03,
			N'' as VNPM04,
			N'' as VNPM05,
			N'' as VNPM06,
			N'' as VNPM07,
			N'' as VNPM08,
			N'' as VNPM09,
			N'' as VNPM10,
			N'' as VNBCRC,
			N'' as VNEXR1,
			N'' as VNTXA1,
			0 as VNTXITM,
			N'' as VNACTB,
			0 as VNSTAM,
			0 as VNCTAM,
			0 as VNAG,
			0 as VNAGF,
			N'' as VNTKTX,
			0 as VNDLNID,
			N'' as VNCKNU,
			N'' as VNBUPC,
			N'' as VNAHBU,
			N'' as VNEPGC,
			N'' as VNJPGC,
			0 as VNRC5,
			0 as VNSFXE,
			N'' as VNOFM
		from #OpenInvoice

		--
	-- Copy data into the F03B11Z1 from the open invoice file
	--
	insert into #F03B11Z1
		select 
			EDUS as VJEDUS,
			N'' as VJEDTY,
			0 as VJEDSQ,
			EDTN as VJEDTN,
			N'' as VJEDCT,
			EDLN as VJEDLN,
			N'' as VJEDTS,
			N'' as VJEDFT,
			@jToday as VJEDDT,
			N'' as VJEDER,
			0 as VJEDDL,
			EDSP as VJEDSP,
			EDTC as VJEDTC,
			EDTR as VJEDTR,
			EDBT as VJEDBT,
			N'' as VJEDGL,
			N'0' as VJEDDH,
			821756 as VJEDAN,
			0 as VJDOC,
			N'' as VJDCT,
			N'' as VJKCO,
			N'' as VJSFX,
			(select aban8 from atmp.f0101 where abalky = ltrim(rtrim(substring(CustomerNo, patindex('%[^0]%', CustomerNo), 20))) collate database_default) as VJAN8,
			0 as VJDGJ,
			dbo.fn_DateTimeToJulian(InvoiceDate) as VJDIVJ,
			N'IB' as VJICUT,
			0 as VJICU,
			@jToday as VJDICJ,
			0 as VJFY,
			0 as VJCTRY,
			0 as VJPN,
			N'03000' as VJCO,
			N'' as VJGLC,
			N'' as VJAID,
			NULL as VJPA8,
			NULL as VJAN8J,
			NULL as VJPYR,
			N'' as VJPOST,
			N' ' as VJISTR,
			N'' as VJBALJ,
			N'A' as VJPST,
			cast(Balance * 100.0 as float)     as VJAG,
			0 as VJAAP,
			0 as VJADSC,
			0 as VJADSA,
			0 as VJATXA,
			0 as VJATXN,
			0 as VJSTAM,
			N'' as VJCRRM,
			N'' as VJCRCD,
			0 as VJCRR,
			N'' as VJDMCD,
			0 as VJACR,
			0 as VJFAP,
			0 as VJCDS,
			0 as VJCDSA,
			0 as VJCTXA,
			0 as VJCTXN,
			0 as VJCTAM,
			N'' as VJTXA1,
			N'' as VJEXR1,
			0 as VJDSVJ,
			N'' as VJGLBA,
			N'2' as VJAM,
			N'' as VJAID2,
			N'' as VJAM2,
			N'        3SUW' as VJMCU,
			N'' as VJOBJ,
			N'' as VJSUB,
			N'' as VJSBLT,
			N'' as VJSBL,
			case (TermsCode) -- Per spreadsheet on Teams site
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
			end collate database_default as VJPTC,
			dbo.fn_DateTimeToJulian(InvoiceDueDate) as VJDDJ,
			dbo.fn_DateTimeToJulian(InvoiceDiscountDate) as VJDDNJ,
			0 as VJRDDJ,
			0 as VJRDSJ,
			0 as VJSMTJ,
			N'' as VJNBRR,
			N'' as VJRDRL,
			0 as VJRMDS,
			N'' as VJCOLL,
			N'' as VJCORC,
			N'' as VJAFC,
			N'' as VJRSCO,
			N'' as VJCKNU,
			0 as VJODOC,
			N'' as VJODCT,
			N'' as VJOKCO,
			N'' as VJOSFX,
			N'' as VJVINV,
			N'' as VJPO,
			N'' as VJPDCT,
			N'' as VJPKCO,
			N'' as VJDCTO,
			0 as VJLNID,
			0 as VJSDOC,
			N'' as VJSDCT,
			N'' as VJSKCO,
			N'' as VJSFXO,
			0 as VJVLDT,
			0 as VJCMC1,
			CustomerPONo collate database_default as VJVR01,
			N'' as VJUNIT,
			N'' as VJMCU2,
			(InvoiceType + N'-' + ltrim(rtrim(substring(InvoiceNo, patindex('%[^0]%', InvoiceNo), 20)))) collate database_default as VJRMK,
			N'' as VJALPH,
			N'' as VJRF,
			0 as VJDRF,
			N'' as VJCTL,
			N'' as VJFNLP,
			0 as VJITM,
			0 as VJU,
			N'' as VJUM,
			N'' as VJALT6,
			N'' as VJRYIN,
			0 as VJVDGJ,
			N'' as VJVRE,
			N'' as VJRP1,
			N'' as VJRP2,
			N'' as VJRP3,
			N'' as VJAR01,
			N'' as VJAR02,
			N'' as VJAR03,
			N'' as VJAR04,
			N'' as VJAR05,
			N'' as VJAR06,
			N'' as VJAR07,
			N'' as VJAR08,
			N'' as VJAR09,
			N'' as VJAR10,
			N'' as VJURC1,
			0 as VJURDT,
			0 as VJURAT,
			0 as VJURAB,
			N'' as VJURRF,
			N'' as VJTORG,
			N'' as VJUSER,
			N'' as VJPID,
			0 as VJUPMJ,
			0 as VJUPMT,
			N'' as VJJOBN,
			0 as VJHCRR,
			0 as VJHDGJ,
			0 as VJDIM,
			0 as VJDID,
			0 as VJDIY,
			0 as VJDI#,
			0 as VJDGM,
			0 as VJDGD,
			0 as VJDGY,
			0 as VJDG#,
			0 as VJDICM,
			0 as VJDICD,
			0 as VJDICY,
			0 as VJDIC#,
			0 as VJDSVM,
			0 as VJDSVD,
			0 as VJDSVY,
			0 as VJDSV#,
			0 as VJDDM,
			0 as VJDDD,
			0 as VJDDY,
			0 as VJDD#,
			0 as VJDDNM,
			0 as VJDDND,
			0 as VJDDNY,
			0 as VJDDN#,
			0 as VJSMTM,
			0 as VJSMTD,
			0 as VJSMTY,
			0 as VJSMT#,
			0 as VJRDDM,
			0 as VJRDDD,
			0 as VJRDDY,
			0 as VJRDD#,
			0 as VJRDSM,
			0 as VJRDSD,
			0 as VJRDSY,
			0 as VJRDS#,
			0 as VJHDGM,
			0 as VJHDGD,
			0 as VJHDGY,
			0 as VJHDG#,
			0 as VJSHPN,
			N'' as VJDTXS,
			N'' as VJOMOD,
			N'' as VJCLMG,
			N'' as VJCMGR,
			0 as VJATAD,
			0 as VJCTAD,
			0 as VJNRTA,
			0 as VJFNRT,
			N'' as VJPRGF,
			N'' as VJGFL1,
			N'' as VJGFL2,
			0 as VJDOCO,
			N'' as VJKCOO,
			N'' as VJSOTF,
			0 as VJDTPB,
			0 as VJERDJ,
			N'' as VJNETST,
			N'' as VJRMR1
		from #OpenInvoice

	--
	-- Copy things into the tables to be copied into JDE
	--
	insert into atmp.F0911Z1
		select * from #F0911Z1

	insert into atmp.F03B11Z1
		select * from #F03B11Z1

	drop table #F0911Z1
	drop table #F03B11Z1
end
go