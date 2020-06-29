use SelectoJDE
go
-- ****************************************************************************************
-- Update vendor numbers in F4102 and vendor part number cross reference in F4104
--
-- HISTORY:
--   22-Feb-2020 R.Lillback Created initial version
-- ****************************************************************************************
IF EXISTS(SELECT * FROM SYS.objects WHERE TYPE = 'P' AND name = N'usp_F4104_VendorXref')
	DROP PROCEDURE dbo.usp_F4104_VendorXref
GO

CREATE PROCEDURE dbo.usp_F4104_VendorXref 
AS
BEGIN
	SET NOCOUNT ON;
	
	if OBJECT_ID(N'tempdb..#tempVend') is not null
		drop table #tempVend
	
	create table #tempVend (
		LITM nchar(25),
		ALKY nchar(25)
	)

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
								   

	insert into atmp.F4104 
	select 
		ABAN8 as IVAN8,
		N'VN' as IVXRT,
		IMITM as IVITM,
		140365 as IVEXDJ,
		119001 as IVEFTJ,
		(select top 1 IVMCU from N0E9SQL01.JDE_DEVELOPMENT.testdta.F4104) as IVMCU,
		VendorAliasItemNo as IVCITM,
		IMDSC1 as IVDSC1,
		IMDSC2 as IVDSC2,
		N'' as IVALN,
		IMLITM as IVLITM,
		IMAITM as IVAITM,
		N'' as IVURCD,
		0 as IVURDT,
		0 as IVURAT,
		0 as IVURAB,
		N'' as IVURRF,
		@user as IVUSER,
		@pid as IVPID,
		@jobn as IVJOBN,
		@jToday as IVUPMJ,
		@tNow as IVTDAY,
		0 as IVRATO,
		0 as IVAPSP,
		N'' as IVIDEM,
		N'' as IVAPPS,
		N'' as IVCIRV,
		N'' as IVADIND,
		N'' as IVBPIND,
		N'' as IVCARDNO
		from 
			dbo.ods_IM_ItemVendor
			inner join atmp.F4101 on LTRIM(RTRIM(ItemCode)) = IMLITM
			inner join atmp.F0101 on LTRIM(RTRIM(VendorNo)) = ABALKY and ABAT1 = N'V3'
		
	-- Update F4102 to set the vendor number correctly
	insert into #tempVend	
		select distinct ItemCode, N'' from dbo.ods_IM_ItemVendor
		
	update 
		tv
	set
		tv.ALKY = tv.NewALKY
	from
		(
			select ALKY,
		    (select top 1 sub.VendorNo as Vend from dbo.ods_IM_ItemVendor as sub where t.LITM = sub.ItemCode collate DATABASE_DEFAULT order by [LastReceiptDate] desc) AS NewALKY
			from #tempVend t 
		 ) as tv
		
	update
		ib
	set 
		IBVEND = ABAN8
	from
		#tempVend
		inner join atmp.F4102 as ib on LTRIM(RTRIM(LITM)) = ib.IBLITM collate DATABASE_DEFAULT
		inner join atmp.F0101 on LTRIM(RTRIM(ALKY)) = ABALKY collate DATABASE_DEFAULT and ABAT1 = N'V3'
	
	drop table #tempVend	
END
	