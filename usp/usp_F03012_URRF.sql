use SelectoJDE
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-------------------------------------------------------------------------------------------
-- Update the Customer Master JDE_DEVELOPMENT.TESTDTA.F03012
--
-- HISTORY:
-- 24-Jun-2020 R.Lillback Created initial version
-- 06-Jul-2020 R.Lillback Added S3s to the update
--
--------------------------------------------------------------------------------------------
IF EXISTS(SELECT * FROM SYS.objects WHERE TYPE = 'P' AND name = N'usp_F03012_URRF')
	DROP PROCEDURE atmp.usp_F03012_URRF
GO

CREATE PROCEDURE atmp.usp_F03012_URRF
AS
BEGIN

update a
set a.AIURRF = TaxSchedule 
from N0E9SQL01.JDE_DEVELOPMENT.TESTDTA.F03012 as a
join N0E9SQL01.JDE_DEVELOPMENT.TESTDTA.F0101 on ABAN8 = AIAN8
join dbo.ods_AR_Customer on (ltrim(rtrim(substring(CustomerNo, patindex('%[^0]%',CustomerNo), 20)))) = ABALKY collate database_default

--
-- Now do the S3s
--
if OBJECT_ID(N'tempdb..#tempIntermediate') is not null
		drop table #tempIntermediate
	
	CREATE TABLE #tempIntermediate (
		[ShipToCode] [nvarchar](20) NULL,
		[CustCode] [nvarchar](25) NULL,
		UKID nchar(40) NULL,
		JDEAssociated float NULL,
		TaxSchedule nchar(9) NULL,
	) 

	insert into #tempIntermediate 
		select 
		    ShipToCode as ShipToCode
		   ,ltrim(rtrim(substring(CustomerNo, patindex('%[^0]%', CustomerNo), 20))) as CustCode
		   ,(ltrim(rtrim(substring(CustomerNo, patindex('%[^0]%', CustomerNo), 20))) + '-' + ltrim(rtrim(ShipToCode))) as UKID
		   ,NULL as JDEAssociated
		   , TaxSchedule
		from dbo.ods_SO_ShipToAddress
		join atmp.F0101 on (ltrim(rtrim(substring(CustomerNo, patindex('%[^0]%', CustomerNo), 20)))) = ABALKY COLLATE DATABASE_DEFAULT

update a
set a.AIURRF = TaxSchedule 
from N0E9SQL01.JDE_DEVELOPMENT.TESTDTA.F03012 as a
join N0E9SQL01.JDE_DEVELOPMENT.TESTDTA.F0101 on ABAN8 = AIAN8
join #tempIntermediate on UKID = ABALKY collate database_default
where ABAT1 = N'S3'

drop table #tempIntermediate
end


go