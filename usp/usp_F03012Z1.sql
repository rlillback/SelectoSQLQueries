use SelectoJDE
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ****************************************************************************************
-- Populate JDE's F03B11Z1 file with data from the open invoice file
--
-- History: 
-- 29-Jun-2020 R.Lillback Created Initial Version
-- 06-Jul-2020 R.Lillback Updated version per Laura's review
--  
-- ****************************************************************************************
IF EXISTS(SELECT * FROM SYS.objects WHERE TYPE = 'P' AND name = N'usp_F03B11Z1')
	DROP PROCEDURE dbo.usp_F03B11Z1
GO

CREATE PROCEDURE dbo.usp_F03B11Z1
AS
BEGIN

	SET NOCOUNT ON;

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

	--
	-- Copy data into the F03B11Z1 from the open invoice file
	--
	insert into #F03B11Z1
		select 
			N'LEDGINGTON' as VJEDUS,
			N'' as VJEDTY,
			0 as VJEDSQ,
			N'1' as VJEDTN,
			N'' as VJEDCT,
			1000 as VJEDLN,
			N'' as VJEDTS,
			N'' as VJEDFT,
			dbo.fn_DateTimeToJulian(GETDATE()) as VJEDDT,
			N'' as VJEDER,
			0 as VJEDDL,
			N'' as VJEDSP,
			N'A' as VJEDTC,
			N'I' as VJEDTR,
			N'8023' as VJEDBT,
			N'' as VJEDGL,
			N'0' as VJEDDH,
			821756 as VJEDAN,
			0 as VJDOC,
			N'' as VJDCT,
			N'' as VJKCO,
			N'' as VJSFX,
			(select aban8 from n0e9sql01.jde_development.testdta.f0101 where abalky = ltrim(rtrim(substring(CustomerNo, patindex('%[^0]%', CustomerNo), 20))) collate database_default) as VJAN8,
			0 as VJDGJ,
			dbo.fn_DateTimeToJulian(InvoiceDate) as VJDIVJ,
			N'IB' as VJICUT,
			0 as VJICU,
			dbo.fn_DateTimeToJulian(GETDATE()) as VJDICJ,
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
		from dbo.ods_AR_OpenInvoice
		where Balance <> 0

	--
	-- Set each transaction as a unique ID
	--
	update x
		set x.VJEDTN = x.NewEDTN
	from (
		select 
			VJEDTN,
			ROW_NUMBER() over (order by VJEDTN asc) as NewEDTN
		from #F03B11Z1
	) as x

	--
	-- Copy things into JDE
	--
	insert into atmp.F03B11Z1
		select * from #F03B11Z1

	drop table #F03B11Z1
end
go