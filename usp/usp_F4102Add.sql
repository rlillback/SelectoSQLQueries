use SelectoJDE
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ****************************************************************************************
-- Import item branch data from atmp.F4101 into atmp.F4102 for Suwanee aka Selecto
--
-- HISTORY:
-- 09-Sep-2019 R.Lillback Created initial version
-- 03-Apr-2020 R.Lillback Updated per Dale's feedback on first data load
-- 17-Apr-2020 R.Lillback Updated for procurement/product type swap in Sage
-- 28-Apr-2020 R.Lillback Fixed IBPRGR for items already in 1A (was '' now 'SU')
-- ****************************************************************************************
IF EXISTS(SELECT * FROM SYS.objects WHERE TYPE = 'P' AND name = N'usp_F4102Add')
	DROP PROCEDURE dbo.usp_F4102Add
GO

CREATE PROCEDURE dbo.usp_F4102Add 
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

	truncate table atmp.F4102; -- Clear the table before loading data into it
	                               
	insert into atmp.F4102 -- Insert the new data into it
	select 
		IMITM AS IBITM,
		IMLITM AS IBLITM,
		IMAITM AS IBAITM,
		N'        3SUW' AS IBMCU,
		IMSRP1 AS IBSRP1,
		IMSRP2 AS IBSRP2,
		IMSRP3 AS IBSRP3,
		IMSRP4 AS IBSRP4,
		IMSRP5 AS IBSRP5,
		IMSRP6 AS IBSRP6,
		IMSRP7 AS IBSRP7,
		IMSRP8 AS IBSRP8,
		IMSRP9 AS IBSRP9,
		IMSRP0 AS IBSRP0,
		IMPRP1 AS IBPRP1,
		IMPRP2 AS IBPRP2,
		IMPRP3 AS IBPRP3,
		IMPRP4 AS IBPRP4,
		IMPRP5 AS IBPRP5,
		IMPRP6 AS IBPRP6,
		IMPRP7 AS IBPRP7,
		IMPRP8 AS IBPRP8,
		IMPRP9 AS IBPRP9,
		IMPRP0 AS IBPRP0,
		IMCDCD AS IBCDCD,
		IMPDGR AS IBPDGR,
		IMDSGP AS IBDSGP,
		CAST(0 AS FLOAT) AS IBVEND,
		case (ProductType)
			when 'R' then 301 
			when 'F' then 303 
			else 301
		end AS IBANPL,
		IMBUYR AS IBBUYR,
		IMGLPT AS IBGLPT,
		N'' AS IBORIG,
		0 AS IBROPI,
		0 AS IBROQI,
		0 AS IBRQMX,
		0 AS IBRQMN,
		0 AS IBWOMO,
		0 AS IBSERV,
		0 AS IBSAFE, 
		0 AS IBSLD,
		N'Y' AS IBCKAV,
		N'' AS IBSRCE,
		N'' AS IBLOTS,
		N'N' AS IBOT1Y,
		N'N' AS IBOT2Y,
		CAST(0 AS FLOAT) AS IBSTDP,
		CAST(0 AS FLOAT) AS IBFRMP,
		CAST(0 AS FLOAT) AS IBTHRP,
		N'' AS IBSTDG,
		N'' AS IBFRGD,
		N'' AS IBTHGD,
		N'' AS IBCOTY,
		CAST(0 AS FLOAT) AS IBMMPC,
		IMPRGR AS IBPRGR,
		IMRPRC AS IBRPRC,
		IMORPR AS IBORPR,
		IMBACK AS IBBACK,
		IMIFLA AS IBIFLA,
		IMABCS AS IBABCS,
		IMABCM AS IBABCM,
		IMABCI AS IBABCI,
		IMOVR AS IBOVR,
		IMSHCM AS IBSHCM,
		IMCARS AS IBCARS,
		IMCARP AS IBCARP,
		IMSHCN AS IBSHCN,
		IMSTKT AS IBSTKT,
		IMLNTY AS IBLNTY,
		IMFIFO AS IBFIFO,
		IMCYCL AS IBCYCL,
		IMINMG AS IBINMG,
		IMWARR AS IBWARR,
		IMSRNR AS IBSRNR,
		IMPCTM AS IBPCTM,
		IMCMCG AS IBCMCG,
		N'Y' AS IBFUF1,
		case (PurchasesTaxClass)
			when 'NT' then N'N'
			else N'Y'
		end AS IBTX,   -- Purchasing taxable
		case (TaxClass)
			when 'NT' then N'N'
			else N'Y'
		end AS IBTAX1, -- Sales taxable
		IMMPST AS IBMPST,
		N'' AS IBMRPD,
		N'' AS IBMRPC,
		CAST(0 AS FLOAT) AS IBUPC,
		IMSNS AS IBSNS,
		N'' AS IBMERL,
		IMLTLV AS IBLTLV,
		IMLTMF AS IBLTMF,
		IMLTCM AS IBLTCM,
		IMOPC AS IBOPC,
		IMOPV AS IBOPV,
		IMACQ AS IBACQ,
		IMMLQ AS IBMLQ,
		IMLTPU AS IBLTPU,
		IMMPSP AS IBMPSP,
		IMMRPP AS IBMRPP,
		IMITC AS IBITC,
		N'' AS IBECO,
		N'' AS IBECTY,
		0 AS IBECOD,
		300 AS IBMTF1,
		IMMTF2 AS IBMTF2,
		IMMTF3 AS IBMTF3,
		IMMTF4 AS IBMTF4,
		IMMTF5 AS IBMTF5,
		CAST(0 AS FLOAT) AS IBMOVD,
		CAST(0 AS FLOAT) AS IBQUED,
		CAST(0 AS FLOAT) AS IBSETL,
		CAST(0 AS FLOAT) AS IBSRNK,
		N'' AS IBSRKF,
		N'U' AS IBTIMB,
		CAST(0 AS FLOAT) AS IBBQTY,
		IMORDW AS IBORDW,
		IMEXPD AS IBEXPD,
		IMDEFD AS IBDEFD,
		CAST(0 AS FLOAT) AS IBMULT,
		IMSFLT AS IBSFLT,
		IMMAKE AS IBMAKE,
		0 AS IBLFDJ,
		IMLLX AS IBLLX,
		IMCMGL AS IBCMGL,
		IMURCD AS IBURCD,
		IMURDT AS IBURDT,
		IMURAT AS IBURAT,
		IMURAB AS IBURAB,
		IMURRF AS IBURRF,
		@user AS IBUSER,
		@pid AS IBPID,
		@jobn AS IBJOBN,
		@jToday AS IBUPMJ,
		@tNow AS IBTDAY,
		IMTFLA AS IBTFLA,
		IMCOMH AS IBCOMH,
		IMAVRT AS IBAVRT,
		IMPOC AS IBPOC,
		IMAING AS IBAING,
		IMBBDD AS IBBBDD,
		IMCMDM AS IBCMDM,
		IMLECM AS IBLECM,
		IMLEDD AS IBLEDD,
		N'Y' AS IBMLOT,
		IMPEFD AS IBPEFD,
		IMSBDD AS IBSBDD,
		IMU1DD AS IBU1DD,
		IMU2DD AS IBU2DD,
		IMU3DD AS IBU3DD,
		IMU4DD AS IBU4DD,
		IMU5DD AS IBU5DD,
		IMXDCK AS IBXDCK,
		IMLAF AS IBLAF,
		IMLTFM AS IBLTFM,
		IMRWLA AS IBRWLA,
		IMLNPA AS IBLNPA,
		IMLOTC AS IBLOTC,
		IMAPSC AS IBAPSC,
		IMPRI1 AS IBPRI1,
		IMPRI2 AS IBPRI2,
		CAST(0 AS FLOAT) AS IBLTCV,
		IMASHL AS IBASHL,
		IMOPTH AS IBOPTH,
		IMCUTH AS IBCUTH,
		IMUMTH AS IBUMTH,
		IMLMFG AS IBLMFG,
		IMLINE AS IBLINE,
		IMDFTPCT AS IBDFTPCT,
		IMKBIT AS IBKBIT,
		IMDFENDITM AS IBDFENDITM,
		IMKANEXLL AS IBKANEXLL,
		IMSCPSELL AS IBSCPSELL,
		IMMOPTH AS IBMOPTH,
		IMMCUTH AS IBMCUTH,
		IMCUMTH AS IBCUMTH,
		IMATPRN AS IBATPRN,
		IMATPCA AS IBATPCA,
		IMATPAC AS IBATPAC,
		IMCOORE AS IBCOORE,
		IMVCPFC AS IBVCPFC,
		IMPNYN AS IBPNYN
	from atmp.F4101
	inner join dbo.ods_CI_Item on IMLITM = ItemCode

	-- Now add in the items that we are keeping the existing F4101 record
	insert into atmp.F4102 -- Insert the new data into it
	select 
		IMITM AS IBITM,
		IMLITM AS IBLITM,
		IMAITM AS IBAITM,
		N'        3SUW' AS IBMCU,
		N'' as IBPRP1,
		IBSRP2 = (select LTRIM(RTRIM(DRKY)) 
							  from N0E9SQL01.JDE_DEVELOPMENT.TESTCTL.F0005 
							  where DRSY = N'41' and DRRT = N'S2' and
									LTRIM(RTRIM(DRDL02)) = LTRIM(RTRIM(UDF_BRAND)) collate database_default), -- ### RAL 28-Aug-2019 Added SRP2 population
		IBSRP3 = (select LTRIM(RTRIM(DRKY))
					from N0E9SQL01.JDE_DEVELOPMENT.TESTCTL.F0005 as udc
					left join dbo.ods_IM_UDT_CARTRIDGE_TECHNOLOGY as sage 
					on udc.DRSY = N'41' and udc.DRRT = N'S3' and
						udc.DRDL02 = LEFT(RTRIM(sage.UDF_DESCRIPTION),30) collate database_default
					where LTRIM(RTRIM(sage.UDF_CODE)) = LTRIM(RTRIM(i.UDF_CARTRIDGE_CODE))) collate database_default, -- ### RAL 28-Aug-2019 Added SRP3 population
		N'' as IMSRP4,
		IBSRP5 = (select LTRIM(RTRIM(DRKY)) 
					from N0E9SQL01.JDE_DEVELOPMENT.TESTCTL.F0005 
					where DRSY = N'41' and DRRT = N'S5' and
						LTRIM(RTRIM(DRDL02)) = LTRIM(RTRIM(UDF_CARTRIDGE_SIZE)) collate database_default), -- ### RAL 28-Aug-2019 Added SRP5 population 
		IBSRP6 = (select RIGHT(DRKY,6) 
					from N0E9SQL01.JDE_DEVELOPMENT.TESTCTL.F0005 
					where DRSY = N'41' and DRRT = N'06' and
						LTRIM(RTRIM(DRDL02)) = LTRIM(RTRIM(UDF_PRODUCT_STAGE)) collate database_default), -- ### RAL 28-Aug-2019 Added SRP6 population
		N'' as IBSRP7,
		N'' as IBSRP8,
		N'' as IBSRP9,
		N'' as IBSRP0,
		IBPRP1 = (select LTRIM(RTRIM(DRKY)) 
					from N0E9SQL01.JDE_DEVELOPMENT.TESTCTL.F0005 
					where DRSY = N'41' and DRRT = N'P1' and
						LTRIM(RTRIM(DRDL02)) = LTRIM(RTRIM(UDF_PRODUCT_CATEGORY)) collate database_default), -- ### RAL 28-Aug-2019 Added PRP1 population
		N'' as IBPRP2,
		N'' as IBPRP3,
		N'' as IBPRP4,
		IBPRP5 = (select LTRIM(RTRIM(DRKY)) 
					from N0E9SQL01.JDE_DEVELOPMENT.TESTCTL.F0005 
					where DRSY = N'41' and DRRT = N'P5' and
						LTRIM(RTRIM(DRDL02)) = LTRIM(RTRIM(UDF_SERIES)) collate database_default), -- ### RAL 28-Aug-2019 Added PRP5 population
		N'' as IBPRP6,
		N'SUW' as IBPRP7, -- SUW for Suwanee product code
		N'' as IBPRP8,
		case (ProductType)
			when 'F' then N'FG'
			when 'R' then N'RAW'
			else N''
		end as IMPRP9, 
		N'' AS IBPRP0,
		N'' AS IBCDCD,
		N'' AS IBPDGR,
		N'' AS IBDSGP,
		0 AS IBVEND,
		case (ProductType)
			when 'R' then 301 
			when 'F' then 303 
			else 301
		end as IBANPL,
		0 AS IBBUYR,
		N'IN3S' AS IBGLPT,
		N'' AS IBORIG,
		0 AS IBROPI,
		0 AS IBROQI,
		0 AS IBRQMX,
		0 AS IBRQMN,
		0 AS IBWOMO,
		0 AS IBSERV,
		0 AS IBSAFE, 
		0 AS IBSLD,
		N'Y' AS IBCKAV,
		N'' AS IBSRCE,
		N'' AS IBLOTS,
		N'' AS IBOT1Y,
		N'' AS IBOT2Y,
		0 AS IBSTDP,
		0 AS IBFRMP,
		0 AS IBTHRP,
		N'' AS IBSTDG,
		N'' AS IBFRGD,
		N'' AS IBTHGD,
		N'' AS IBCOTY,
		0 AS IBMMPC,
		N'SU' AS IBPRGR, 
		N'SU' AS IBRPRC, 
		N'' AS IBORPR,
		N'Y' AS IBBACK,
		N'' AS IBIFLA,
		N'' AS IBABCS,
		N'' AS IBABCM,
		N'' AS IBABCI,
		N'' AS IBOVR,
		N'' AS IBSHCM,
		0 AS IBCARS,
		0 AS IBCARP,
		N'' AS IBSHCN,
		case (ProductType)
			when 'R' then N'P' 
			when 'F' then N'M' 
			else N'' 
		end collate database_default as IBSTKT, -- Stocking Type Purchase or Manufacture
		N'S' AS IBLNTY,
		N'' AS IBFIFO,
		N'' AS IBCYCL,
		N'' AS IBINMG,
		N'' AS IBWARR, -- //TODO: ### Add Warranty code
		N'' AS IBSRNR,
		0 AS IBPCTM,
		N'' AS IBCMCG,
		N'Y' AS IBFUF1,
		case (PurchasesTaxClass)
			when 'NT' then N'N'
			else N'Y'
		end AS IBTX,   -- Purchasing taxable
		case (TaxClass)
			when 'NT' then N'N'
			else N'Y'
		end AS IBTAX1, -- Sales taxable
		N'0' AS IBMPST,
		N'' AS IBMRPD,
		N'' AS IBMRPC,
		0AS IBUPC,
		N'' AS IBSNS,
		N'' AS IBMERL,
		0 AS IBLTLV,
		0 AS IBLTMF,
		0 AS IBLTCM,
		N'0' AS IBOPC,
		0 AS IBOPV,
		1 AS IBACQ,
		0 AS IBMLQ,
		0 AS IBLTPU,
		N'G' AS IBMPSP,
		N'F' AS IBMRPP,
		N'B' AS IBITC,
		N'' AS IBECO,
		N'' AS IBECTY,
		0 AS IBECOD,
		0 AS IBMTF1,
		0 AS IBMTF2,
		0 AS IBMTF3,
		0 AS IBMTF4,
		0 AS IBMTF5,
		0 AS IBMOVD,
		0 AS IBQUED,
		0 AS IBSETL,
		0 AS IBSRNK,
		N'' AS IBSRKF,
		N'U' AS IBTIMB,
		0 AS IBBQTY,
		N'' AS IBORDW,
		0 AS IBEXPD,
		0 AS IBDEFD,
		0 AS IBMULT,
		0 AS IBSFLT,
		N'' AS IBMAKE,
		0 AS IBLFDJ,
		0 AS IBLLX,
		N'1' AS IBCMGL,
		N'2' AS IBURCD,
		0 AS IBURDT,
		0 AS IBURAT,
		0 AS IBURAB,
		N'' AS IBURRF,
		@user AS IBUSER,
		@pid AS IBPID,
		@jobn AS IBJOBN,
		@jToday AS IBUPMJ,
		@tNow AS IBTDAY,
		N'' AS IBTFLA,
		0 AS IBCOMH,
		0 AS IBAVRT,
		N'0' AS IBPOC,
		N'0' AS IBAING,
		0 AS IBBBDD,
		N'1' AS IBCMDM,
		N'1' AS IBLECM,
		0 AS IBLEDD,
		N'Y' AS IBMLOT,
		0 AS IBPEFD,
		0 AS IBSBDD,
		0 AS IBU1DD,
		0 AS IBU2DD,
		0 AS IBU3DD,
		0 AS IBU4DD,
		0 AS IBU5DD,
		N'0' AS IBXDCK,
		N'' AS IBLAF,
		N'' AS IBLTFM,
		N'' AS IBRWLA,
		N'' AS IBLNPA,
		N'' AS IBLOTC,
		N'' AS IBAPSC,
		0 AS IBPRI1,
		0 AS IBPRI2,
		0 AS IBLTCV,
		N'' AS IBASHL,
		0 AS IBOPTH,
		0 AS IBCUTH,
		N'' AS IBUMTH,
		N'0' AS IBLMFG,
		N'' AS IBLINE,
		0 AS IBDFTPCT,
		N'0' AS IBKBIT,
		N'0' AS IBDFENDITM,
		N'0' AS IBKANEXLL,
		N'0' AS IBSCPSELL,
		0 AS IBMOPTH,
		0 AS IBMCUTH,
		N'' AS IBCUMTH,
		N'' AS IBATPRN,
		N'' AS IBATPCA,
		N'' AS IBATPAC,
		0 AS IBCOORE,
		N'' AS IBVCPFC,
		N'N' AS IBPNYN
	from atmp.ItemConflicts
		join N0E9SQL01.JDE_DEVELOPMENT.TESTDTA.F4101 on PartNumber = IMLITM collate database_default
		join dbo.ods_CI_Item i on PartNumber = ItemCode
	where ActionKey = 1 -- Only select item conflicts with an existing F4101 record
END
GO
