use SelectoJDE
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ****************************************************************************************
-- Populate atmp.F0030 with dummy bank accounts for all wire transfers
--
-- History: 
--  15-Sept-2020 R.Lillback Created initial version
--  
-- ****************************************************************************************
IF EXISTS(SELECT * FROM SYS.objects WHERE TYPE = 'P' AND name = N'usp_F0030_VendorWire') begin
	print(N'dropping procedure dbo.usp_F0030_VendorWire');
	DROP PROCEDURE dbo.usp_F0030_VendorWire
end
GO

print(N'Create procedure dbo.usp_F0030_VendorWire');
go

CREATE PROCEDURE dbo.usp_F0030_VendorWire
AS
BEGIN
SET NOCOUNT ON;

	-- Set the JDE audit data
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
	-- Get the dummy variables to use from the existing Newbury vendor 822639
	declare @bktp nchar(1) = (select aybktp from n0e9sql01.JDE_DEVELOPMENT.testdta.F0030 where ayan8 = 822639);
	declare @tnst nchar(20) = (select aytnst from n0e9sql01.JDE_DEVELOPMENT.testdta.F0030 where ayan8 = 822639);
	declare @cbnk nchar(20) = (select aycbnk from n0e9sql01.JDE_DEVELOPMENT.testdta.F0030 where ayan8 = 822639);

	if object_id(N'tempdb..#F0030') is not null
		drop table #F0030

	create table #F0030 (
		[AYBKTP] [nchar](1) NULL,
		[AYTNST] [nchar](20) NULL,
		[AYCBNK] [nchar](20) NULL,
		[AYAN8] [float] NULL,
		[AYDL01] [nchar](30) NULL,
		[AYAID] [nchar](8) NULL,
		[AYNXTC] [float] NULL,
		[AYCHKD] [nchar](2) NULL,
		[AYCRCD] [nchar](3) NULL,
		[AYRLN] [nchar](18) NULL,
		[AYBACS] [float] NULL,
		[AYRFNM] [nchar](18) NULL,
		[AYBAID] [nchar](8) NULL,
		[AYMCU] [nchar](12) NULL,
		[AYSWFT] [nchar](15) NULL,
		[AYADPI] [nchar](1) NULL,
		[AYCHKQ] [nchar](10) NULL,
		[AYATTQ] [nchar](10) NULL,
		[AYDBTQ] [nchar](10) NULL,
		[AYALGN] [float] NULL,
		[AYSDTL] [float] NULL,
		[AYFLR] [float] NULL,
		[AYFLP] [float] NULL,
		[AYCKSV] [nchar](1) NULL,
		[AYUKID] [float] NULL,
		[AYCTR] [nchar](3) NULL,
		[AYNXTA] [float] NULL,
		[AYUPMJ] [numeric](18, 0) NULL,
		[AYUPMT] [float] NULL,
		[AYPID] [nchar](10) NULL,
		[AYUSER] [nchar](10) NULL,
		[AYJOBN] [nchar](10) NULL,
		[AYIBAN] [nchar](34) NULL,
		[AYAN8BK] [float] NULL,
	)

	insert into #F0030
		select
			  @bktp
			, @tnst
			, @cbnk
			, aban8
			, N''
			, N''
			, 0
			, N''
			, N''
			, N''
			, 0
			, N''
			, N''
			, N''
			, N''
			, N''
			, N''
			, N''
			, N''
			, 0
			, 0
			, 0
			, 0
			, N''
			, 0
			, N''
			, 0
			, @jToday
			, @tNow
			, @pid
			, @user
			, @jobn
			, N''
			, 0
		from atmp.F0101
		join atmp.F0401 on aban8 = a6an8
		where abat1 = N'V3' and a6pyin = N'6'

		-- Update primary Key
		declare @lastUKID float = (select max(AYUKID) from atmp.F0030); -- has to run AFTER usp_F0030_Vendor
		update x
			set x.AYUKID = x.newUKID
			from (
				  select 
					AYUKID, 
				    (@lastUKID + (ROW_NUMBER() OVER (ORDER BY AYAN8))) as newUKID
				  from #F0030
				 ) as x 

		insert into atmp.F0030
			select * from #F0030

		drop table #F0030
		
end