use SelectoJDE
go
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-----------------------------------------------------------------------------------------
--
-- Populate the intermediate table atmp.F4101 in N01A-DWSQLPD with possible JDE Data
-- ONLY For items that already exist in JDE, but will get a different IMLITM
-- this procedure appends -SU to those items that need to change.
--
-- NOTE: THIS ASSUMES A MAX PN OF 22 CHARS.
--       As of this writing, the max PN len was 10 chars.
--
-- Assumptions:
--  You've already created the backup table bkup.F4101 & populated it.
--  You've already populated the table atmp.ItemConflicts.
--  You've already populated all the UDC codes for Suwanee
--  You've already run the inital population of atmp.F4101 with new items
--
-- History:
-- 28-Aug-2019 R.Lillback Created Initial Version
-- 05-Sep-2019 R.Lillback Get max IMITM from atmp.F4101 instead of JDE_DEVELOPMENT
-- 06-Sep-2019 R.Lillback Populate planner number with 301
-- 06-Sep-2019 R.Lillback Remove double " from descriptions
--
-----------------------------------------------------------------------------------------
IF OBJECT_ID('dbo.usp_F4101AddConflicting') is not null begin
	print 'Dropping procedure dbo.usp_F4101AddConflicting';
	drop procedure dbo.usp_F4101AddConflicting
end
go

print 'Creating procedure dbo.usp_F4101AddConflicting';
go
CREATE PROCEDURE dbo.usp_F4101AddConflicting
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


		declare @rowOffset float;
		-- Make sure to go 10 numbers beyond that last number in DEVELOPMENT
		set @rowOffset = (select MAX(IMITM) from atmp.F4101) + 10; 

		-- Now set up the audit trail
		declare @user nvarchar(10) = N'RLILLBACK';
		declare @pid nvarchar(10) = N'SQLLD';
		declare @jobn nvarchar(10) = N'SQLLD';
		declare @jToday numeric(18,0)=dbo.fn_DateTimeToJulian(GETDATE()); -- Julian Date Today
		declare @tNow float = CONVERT (
										float,
										datepart(hh,getdate())*10000 + 
										datepart(mi, getdate())*100 +
										datepart(ss, getdate())
										); -- Time now as held by JDE
                           
		insert into atmp.F4101 -- Insert the new data into it
			select 
					(@rowOffset + ROW_NUMBER() OVER(ORDER BY ItemCode asc)) AS IMITM,
					LEFT(RTRIM(ItemCode),22) + N'-SU' collate database_default as IMLITM ,
					LEFT(RTRIM(ItemCode),22) + N'-SU' collate database_default as IMAITM ,
					LEFT(ItemCodeDesc,30) collate database_default as IMDSC1,
					N'' collate database_default as IMDSC2,
					LEFT(ItemCodeDesc,30) collate database_default as IMSRTX,
					N'' collate database_default as IMALN,
					RIGHT(ProductLine,3) collate database_default as IMSRP1, 
					IMSRP2 = (select LTRIM(RTRIM(DRKY)) 
							  from N0E9SQL01.JDE_DEVELOPMENT.TESTCTL.F0005 
							  where DRSY = N'41' and DRRT = N'S2' and
									LTRIM(RTRIM(DRDL02)) = LTRIM(RTRIM(UDF_BRAND)) collate database_default), 
					IMSRP3 = (select LTRIM(RTRIM(DRKY))
							  from N0E9SQL01.JDE_DEVELOPMENT.TESTCTL.F0005 as udc
							  left join dbo.ods_IM_UDT_CARTRIDGE_TECHNOLOGY as sage 
								on udc.DRSY = N'41' and udc.DRRT = N'S3' and
								   udc.DRDL02 = LEFT(RTRIM(sage.UDF_DESCRIPTION),30) collate database_default
							  where LTRIM(RTRIM(sage.UDF_CODE)) = LTRIM(RTRIM(i.UDF_CARTRIDGE_CODE))) collate database_default, 
					N'' collate database_default as IMSRP4,
					IMSRP5 = (select LTRIM(RTRIM(DRKY)) 
							  from N0E9SQL01.JDE_DEVELOPMENT.TESTCTL.F0005 
							  where DRSY = N'41' and DRRT = N'S5' and
									LTRIM(RTRIM(DRDL02)) = LTRIM(RTRIM(UDF_CARTRIDGE_SIZE)) collate database_default),  
					IMSRP6 = (select RIGHT(DRKY,6) 
							  from N0E9SQL01.JDE_DEVELOPMENT.TESTCTL.F0005 
							  where DRSY = N'41' and DRRT = N'06' and
									LTRIM(RTRIM(DRDL02)) = LTRIM(RTRIM(UDF_PRODUCT_STAGE)) collate database_default), 
					N'' collate database_default as IMSRP7,
					N'' collate database_default as IMSRP8,
					N'' collate database_default as IMSRP9,
					N'' collate database_default as IMSRP0,
					IMPRP1 = (select LTRIM(RTRIM(DRKY)) 
							  from N0E9SQL01.JDE_DEVELOPMENT.TESTCTL.F0005 
							  where DRSY = N'41' and DRRT = N'P1' and
									LTRIM(RTRIM(DRDL02)) = LTRIM(RTRIM(UDF_PRODUCT_CATEGORY)) collate database_default), 
					N'' collate database_default as IMPRP2,
					N'' collate database_default as IMPRP3,
					N'' collate database_default as IMPRP4,
					IMPRP5 = (select LTRIM(RTRIM(DRKY)) 
							  from N0E9SQL01.JDE_DEVELOPMENT.TESTCTL.F0005 
							  where DRSY = N'41' and DRRT = N'P5' and
									LTRIM(RTRIM(DRDL02)) = LTRIM(RTRIM(UDF_SERIES)) collate database_default), 
					N'' collate database_default as IMPRP6,
					N'SUW' collate database_default as IMPRP7, -- SUW for Suwanee product code
					N'' collate database_default as IMPRP8,
					case (ProductType)
						when 'F' then N'FG'
						when 'R' then N'RAW'
						else N''
					end collate database_default as IMPRP9, 
					N'' collate database_default as IMPRP0,
					N'' collate database_default as IMCDCD, 
					N'' collate database_default as IMPDGR, -- //TODO: Default this to SUW
					N'' collate database_default as IMDSGP,
					N'' collate database_default as IMPRGR, -- //TODO: Default this to SUW or some other product group
					N'' collate database_default as IMRPRC, -- //TODO: Default this to SUW or some other product group
					N'' collate database_default as IMORPR,
					CAST(0 as float) as IMBUYR,				-- //TODO: Update this in a later procedure to populate buyers
					N'' collate database_default as IMDRAW,
					N'' collate database_default as IMRVNO,
					N'' collate database_default as IMDSZE,
					CAST(0 as float) as IMVCUD, 
					CAST(0 as float) as IMCARS,
					CAST(0 as float) AS IMCARP,
					N'' collate database_default as IMSHCN,
					N'' collate database_default as IMSHCM,
					case (SalesUnitOfMeasure)
						when 'EACH' then N'EA'
						when 'BX' then N'EA' -- Convert Box to each only effects 600-061
						when 'CF' then N'CF' -- Keep cubic feet
						when 'CU' then N'CF' -- Convert CU to Cubic Feet
						when 'CT' then N'EA' -- Convert carton to EA only effects 50-003
						when 'FT' then N'FT' -- Keep FT
						when 'KG' then N'KG' -- Use KG; NOTE: This is new to Kinetico
						when 'L' then N'LT'  -- Convert L to LT for Litres
						when 'LB' then N'LB' -- Keep LBS
						when 'PK' then N'PK' -- Keep packs
						when 'ROLL' then N'RL' -- Convert Roll to JDE RL
						else N'12'			-- Default to 12 to find any errors in data conversion
					end collate database_default as IMUOM1, -- Primary UOM
					case (SalesUnitOfMeasure)
						when 'EACH' then N'EA'
						when 'BX' then N'EA' -- Convert Box to each only effects 600-061
						when 'CF' then N'CF' -- Keep cubic feet
						when 'CU' then N'CF' -- Convert CU to Cubic Feet
						when 'CT' then N'EA' -- Convert carton to EA only effects 50-003
						when 'FT' then N'FT' -- Keep FT
						when 'KG' then N'KG' -- Use KG; NOTE: This is new to Kinetico
						when 'L' then N'LT'  -- Convert L to LT for Litres
						when 'LB' then N'LB' -- Keep LBS
						when 'PK' then N'PK' -- Keep packs
						when 'ROLL' then N'RL' -- Convert Roll to JDE RL
						else N'EA'
					end collate database_default as IMUOM2, -- Secondary UOM
					case (PurchaseUnitOfMeasure)
						when 'EACH' then N'EA'
						when 'BX' then N'EA' -- Convert Box to each only effects 600-061
						when 'CF' then N'CF' -- Keep cubic feet
						when 'CU' then N'CF' -- Convert CU to Cubic Feet
						when 'CT' then N'EA' -- Convert carton to EA only effects 50-003
						when 'FT' then N'FT' -- Keep FT
						when 'KG' then N'KG' -- Use KG; NOTE: This is new to Kinetico
						when 'L' then N'LT'  -- Convert L to LT for Litres
						when 'LB' then N'LB' -- Keep LBS
						when 'PK' then N'PK' -- Keep packs
						when 'ROLL' then N'RL' -- Convert Roll to JDE RL
						else N'EA'
					end collate database_default as IMUOM3, -- Purchase UOM
					case (SalesUnitOfMeasure)
						when 'EACH' then N'EA'
						when 'BX' then N'EA' -- Convert Box to each only effects 600-061
						when 'CF' then N'CF' -- Keep cubic feet
						when 'CU' then N'CF' -- Convert CU to Cubic Feet
						when 'CT' then N'EA' -- Convert carton to EA only effects 50-003
						when 'FT' then N'FT' -- Keep FT
						when 'KG' then N'KG' -- Use KG; NOTE: This is new to Kinetico
						when 'L' then N'LT'  -- Convert L to LT for Litres
						when 'LB' then N'LB' -- Keep LBS
						when 'PK' then N'PK' -- Keep packs
						when 'ROLL' then N'RL' -- Convert Roll to JDE RL
						else N'EA'
					end collate database_default as IMUOM4, -- Pricing UOM
					case (SalesUnitOfMeasure)
						when 'EACH' then N'EA'
						when 'BX' then N'EA' -- Convert Box to each only effects 600-061
						when 'CF' then N'CF' -- Keep cubic feet
						when 'CU' then N'CF' -- Convert CU to Cubic Feet
						when 'CT' then N'EA' -- Convert carton to EA only effects 50-003
						when 'FT' then N'FT' -- Keep FT
						when 'KG' then N'KG' -- Use KG; NOTE: This is new to Kinetico
						when 'L' then N'LT'  -- Convert L to LT for Litres
						when 'LB' then N'LB' -- Keep LBS
						when 'PK' then N'PK' -- Keep packs
						when 'ROLL' then N'RL' -- Convert Roll to JDE RL
						else N'EA'
					end collate database_default as IMUOM6, -- Shipping UOM
					case (StandardUnitOfMeasure)
						when 'EACH' then N'EA'
						when 'BX' then N'EA' -- Convert Box to each only effects 600-061
						when 'CF' then N'CF' -- Keep cubic feet
						when 'CU' then N'CF' -- Convert CU to Cubic Feet
						when 'CT' then N'EA' -- Convert carton to EA only effects 50-003
						when 'FT' then N'FT' -- Keep FT
						when 'KG' then N'KG' -- Use KG; NOTE: This is new to Kinetico
						when 'L' then N'LT'  -- Convert L to LT for Litres
						when 'LB' then N'LB' -- Keep LBS
						when 'PK' then N'PK' -- Keep packs
						when 'ROLL' then N'RL' -- Convert Roll to JDE RL
						else N'EA'
					end collate database_default as IMUOM8, -- Production UOM
					case (SalesUnitOfMeasure)
						when 'EACH' then N'EA'
						when 'BX' then N'EA' -- Convert Box to each only effects 600-061
						when 'CF' then N'CF' -- Keep cubic feet
						when 'CU' then N'CF' -- Convert CU to Cubic Feet
						when 'CT' then N'EA' -- Convert carton to EA only effects 50-003
						when 'FT' then N'FT' -- Keep FT
						when 'KG' then N'KG' -- Use KG; NOTE: This is new to Kinetico
						when 'L' then N'LT'  -- Convert L to LT for Litres
						when 'LB' then N'LB' -- Keep LBS
						when 'PK' then N'PK' -- Keep packs
						when 'ROLL' then N'RL' -- Convert Roll to JDE RL
						else N'EA'
					end collate database_default as IMUOM9, -- Component UOM
					case (PurchaseUnitOfMeasure) 
						when 'KG' then N'KG'
						else N'LB' 
					end collate database_default as IMUWUM, -- Weight UOM
					case (PurchaseUnitOfMeasure)
						when 'L' then N'LT'
						else N'GA' 
					end collate database_default as IMUVM1, -- Volume UOM
					case (SalesUnitOfMeasure)
						when 'EACH' then N'EA'
						when 'BX' then N'EA' -- Convert Box to each only effects 600-061
						when 'CF' then N'CF' -- Keep cubic feet
						when 'CU' then N'CF' -- Convert CU to Cubic Feet
						when 'CT' then N'EA' -- Convert carton to EA only effects 50-003
						when 'FT' then N'FT' -- Keep FT
						when 'KG' then N'KG' -- Use KG; NOTE: This is new to Kinetico
						when 'L' then N'LT'  -- Convert L to LT for Litres
						when 'LB' then N'LB' -- Keep LBS
						when 'PK' then N'PK' -- Keep packs
						when 'ROLL' then N'RL' -- Convert Roll to JDE RL
						else N'EA'
					end collate database_default as IMSUTM, -- Stocking UOM
					N'' collate database_default as IMUMVW, 
					N'' collate database_default as IMCYCL,
					N'IN3S' collate database_default as IMGLPT, 
					N'2' collate database_default as IMPLEV,
					N'3' collate database_default as IMPPLV,
					N'2' collate database_default as IMCLEV,
					N'' collate database_default as IMPRPO,
					N'Y' collate database_default as IMCKAV,
					N'P' collate database_default as IMBPFG, -- ### RAL //TODO: Verify we can use just P, else add some logic here
					N'' collate database_default as IMSRCE,
					N'N' collate database_default as IMOT1Y,
					N'N' collate database_default as IMOT2Y,
					CAST(0 as float) as IMSTDP,
					CAST(0 as float) as IMFRMP,
					CAST(0 as float) as IMTHRP,
					N'' collate database_default as IMSTDG,
					N'' collate database_default as IMFRGD,
					N'' collate database_default as IMTHGD,
					N'' collate database_default as IMCOTY,
					case (ProcurementType)
						when 'B' then N'P' collate database_default
						when 'M' then N'M' collate database_default
					else N'' collate database_default
					end as IMSTKT, -- Stocking Type Purchase or Manufacture
					N'S' collate database_default as IMLNTY, -- All parts are stock item types
					N'N' collate database_default as IMCONT,
					N'Y' collate database_default as IMBACK,
					N'' collate database_default as IMIFLA,
					N'' collate database_default as IMTFLA,
					N'' collate database_default as IMINMG,
					N'' collate database_default as IMABCS,
					N'' collate database_default as IMABCM,
					N'' collate database_default as IMABCI,
					N'' collate database_default as IMOVR,
					N'' collate database_default as IMWARR,
					N'' collate database_default as IMCMCG,
					N'' collate database_default as IMSRNR,
					N'' collate database_default as IMPMTH,
					N'' collate database_default as IMFIFO,
					N'' collate database_default as IMLOTS,
					CAST(0 as float) as IMSLD,
					N'301' collate database_default as IMANPL, -- ### 9/6/2019
					N'0' collate database_default as IMMPST,
					CAST(0 as float) as IMPCTM,
					CAST(0 as float) as IMMMPC,
					N'' collate database_default as IMPTSC,
					N'' collate database_default as IMSNS,
					CAST(0 as float) as IMLTLV, -- ### //TODO: Are we going to add a lead time level for planning?
					CAST(0 as float) as IMLTMF,
					CAST(0 as float) as IMLTCM,
					N'0' collate database_default as IMOPC,
					CAST(0 as float) as IMOPV,
					CAST(1 as float) as IMACQ, 
					CAST(0 as float) as IMMLQ,
					CAST(0 as float) as IMLTPU,
					N'G' collate database_default as IMMPSP,
					N'F' collate database_default as IMMRPP, 
					N'B' collate database_default as IMITC,
					N'' collate database_default as IMORDW,
					CAST(0 as float) as IMMTF1,
					CAST(0 as float) as IMMTF2,
					CAST(0 as float) as IMMTF3,
					CAST(0 as float) as IMMTF4,
					CAST(0 as float) as IMMTF5,
					CAST(0 as float) as IMEXPD,
					CAST(0 as float) as IMDEFD,
					CAST(0 as float) as IMSFLT,
					N'' collate database_default as IMMAKE,
					N'C' collate database_default as IMCOBY,
					CAST(0 as float) as IMLLX,
					N'1' collate database_default as IMCMGL,
					CAST(0 as float) as IMCOMH,
					N'2' collate database_default as IMURCD,
					CAST(0 as numeric(18,0)) as IMURDT,
					CAST(0 as float) as IMURAT,
					CAST(0 as float) as IMURAB,
					N'' collate database_default as IMURRF,
					@user as IMUSER,
					@pid as IMPID,
					@jobn as IMJOBN,
					@jToday as IMUPMJ,
					@tNow as IMTDAY,
					N'' collate database_default as IMUPCN,
					N'' collate database_default as IMSCC0,
					N'' collate database_default as IMUMUP,
					N'' collate database_default as IMUMDF,
					N'' collate database_default as IMUMS0,
					N'' collate database_default as IMUMS1,
					N'' collate database_default as IMUMS2,
					N'' collate database_default as IMUMS3,
					N'' collate database_default as IMUMS4,
					N'' collate database_default as IMUMS5,
					N'' collate database_default as IMUMS6,
					N'' collate database_default as IMUMS7,
					N'' collate database_default as IMUMS8,
					N'0' collate database_default as IMPOC,
					CAST(0 as float) as IMAVRT,
					N'' collate database_default as IMEQTY,
					N'N' collate database_default as IMWTRQ,
					N'' collate database_default as IMTMPL,
					N'' collate database_default as IMSEG1,
					N'' collate database_default as IMSEG2,
					N'' collate database_default as IMSEG3,
					N'' collate database_default as IMSEG4,
					N'' collate database_default as IMSEG5,
					N'' collate database_default as IMSEG6,
					N'' collate database_default as IMSEG7,
					N'' collate database_default as IMSEG8,
					N'' collate database_default as IMSEG9,
					N'' collate database_default as IMSEG0,
					N'' collate database_default as IMMIC,
					N'0' collate database_default as IMAING,
					CAST(0 as float) as IMBBDD,
					N'1' collate database_default as IMCMDM,
					N'1' collate database_default as IMLECM,
					CAST(0 as float) as IMLEDD,
					CAST(0 as float) as IMPEFD,
					CAST(0 as float) as IMSBDD,
					CAST(0 as float) as IMU1DD,
					CAST(0 as float) as IMU2DD,
					CAST(0 as float) as IMU3DD,
					CAST(0 as float) as IMU4DD,
					CAST(0 as float) as IMU5DD,
					CAST(0 as float) as IMDLTL,
					N'0' collate database_default as IMDPPO,
					N'' collate database_default as IMDUAL,
					N'0' collate database_default as IMXDCK,
					N'' collate database_default as IMLAF,
					N'' collate database_default as IMLTFM,
					N'' collate database_default as IMRWLA,
					N'' collate database_default as IMLNPA,
					N'' collate database_default as IMLOTC,
					N'' collate database_default as IMAPSC,
					N'' collate database_default as IMAUOM,
					N'' collate database_default as IMCONB,
					N'' collate database_default as IMGCMP,
					CAST(0 as float) as IMPRI1,
					CAST(0 as float) as IMPRI2,
					N'' collate database_default as IMASHL,
					N'' collate database_default as IMVMINV,
					N'' collate database_default as IMCMETH,
					N'1' collate database_default as IMEXPI,
					CAST(0 as float) as IMOPTH,
					CAST(0 as float) as IMCUTH,
					N'' collate database_default as IMUMTH,
					N'0' collate database_default as IMLMFG,
					N'' collate database_default as IMLINE,
					CAST(0 as float) as IMDFTPCT,
					N'0' collate database_default as IMKBIT,
					N'0' collate database_default as IMDFENDITM,
					N'0' collate database_default as IMKANEXLL,
					N'0' collate database_default as IMSCPSELL,
					CAST(0 as float) as IMMOPTH,
					CAST(0 as float) as IMMCUTH,
					N'' collate database_default as IMCUMTH,
					N'' collate database_default as IMATPRN,
					N'' collate database_default as IMATPCA,
					N'' collate database_default as IMATPAC,
					CAST(0 as float) as IMCOORE,
					N'' collate database_default as IMVCPFC,
					N'N' collate database_default as IMPNYN
			from atmp.ItemConflicts as c
				inner join dbo.ods_CI_Item as i on c.PartNumber = i.ItemCode
			where
				c.ActionKey = 2 -- Only grab PN's that will have -SU appended to them
			-- END insert


		-- can't have a null SRP or PRP, so set themn to the blank version
		update atmp.F4101 
			set IMSRP2 = (select DRKY from N0E9SQL01.JDE_DEVELOPMENT.TESTCTL.F0005 where DRSY = N'41' and DRRT = N'S2' and LTRIM(RTRIM(DRKY)) = N'') 
		where 
			IMSRP2 is null

		update atmp.F4101 
			set IMSRP3 = (select DRKY from N0E9SQL01.JDE_DEVELOPMENT.TESTCTL.F0005 where DRSY = N'41' and DRRT = N'S3' and LTRIM(RTRIM(DRKY)) = N'') 
		where 
			IMSRP3 is null

		update atmp.F4101 
			set IMSRP5 = (select DRKY from N0E9SQL01.JDE_DEVELOPMENT.TESTCTL.F0005 where DRSY = N'41' and DRRT = N'S5' and LTRIM(RTRIM(DRKY)) = N'') 
		where 
			IMSRP5 is null

		update atmp.F4101 
			set IMSRP6 = (select DRKY from N0E9SQL01.JDE_DEVELOPMENT.TESTCTL.F0005 where DRSY = N'41' and DRRT = N'06' and LTRIM(RTRIM(DRKY)) = N'') 
		where IMSRP6 is null

		update atmp.F4101 
			set IMPRP1 = (select DRKY from N0E9SQL01.JDE_DEVELOPMENT.TESTCTL.F0005 where DRSY = N'41' and DRRT = N'P1' and LTRIM(RTRIM(DRKY)) = N'') 
		where 
			IMPRP1 is null

		update atmp.F4101 
			set IMPRP5 = (select DRKY from N0E9SQL01.JDE_DEVELOPMENT.TESTCTL.F0005 where DRSY = N'41' and DRRT = N'P5' and LTRIM(RTRIM(DRKY)) = N'') 
		where 
			IMPRP5 is null

		-- ### 9/6/2019
		update atmp.F4101
			set IMDSC1 = REPLACE(IMDSC1,N'""', N'"')
		where
			CHARINDEX(N'""',IMDSC1) > 0
end
go


	