use SelectoJDE
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ****************************************************************************************
-- Populate atmp.F0030 with vendor EFT accounts from flat file
--
-- Prerequisites:  UDC 01/ST has S3 in it
--
-- History: 
--  03-Jun-2020 R.Lillback Created Initial Version
--  
-- ****************************************************************************************
IF EXISTS(SELECT * FROM SYS.objects WHERE TYPE = 'P' AND name = N'usp_F0030_Vendor')
	DROP PROCEDURE dbo.usp_F0030_Vendor
GO

CREATE PROCEDURE dbo.usp_F0030_Vendor
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
			  BKTP
			, TNST
			, CBNK
			, isnull((select ABAN8 from atmp.F0101 where ABALKY = (ALKY +' R3')),(select ABAN8 from atmp.F0101 where ABALKY = ALKY))
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
		from dbo.ods_VendorEFTFlatFile

		-- Update primary Key
		declare @lastUKID float = (select max(AYUKID) from N0E9SQL01.JDE_DEVELOPMENT.TESTDTA.F0030);
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