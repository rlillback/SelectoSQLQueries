use SelectoJDE
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ****************************************************************************************
-- Temporarily delete all but one of the sales code numbers in the flat file.
-- Amy must fix this flat file before we really use the data.
--
--    1. Copy the distinct address numbers (ABALKY) that have duplicates into to temp table
--    2. Update the sales code in the temp table by selecting the first sales code it finds
--    3. Delete all of the duplicate addresses in the flat file.
--	  4. Merge the temp file back into the flat file
--
-- History: 
-- 29-Mar-2020 R.Lillback Created Initial Version
--
-- TODO:
--  
-- ****************************************************************************************
IF EXISTS(SELECT * FROM SYS.objects WHERE TYPE = 'P' AND name = N'usp_TemporarySalesCodeFix')
	DROP PROCEDURE dbo.usp_TemporarySalesCodeFix
GO

CREATE PROCEDURE dbo.usp_TemporarySalesCodeFix
AS
BEGIN

	if OBJECT_ID(N'tempdb..#tempTable') is not NULL
	drop table #tempTable

	create table #tempTable (
		ALKY nchar(20) not null,
		AC04 nchar(4) null,
	)

	/**********************************************************************************//**
		1. Copy the distinct address numbers for all duplicate addresses
	*/
	/**************************************************************************************/
	insert into #tempTable
		select a.ABALKY, null
		from 
		(
			select ABALKY as ABALKY
			, count(ABALKY) as cnt
			from dbo.ods_SalesCodeFlatFile
			group by ABALKY
			having count(ABALKY) > 1
		) as a

	/**********************************************************************************//**
		2. Update the sales code in the temp table with the first Sales code you grab 
		   out of the flat file
	*/
	/**************************************************************************************/
	update #tempTable
		set AC04 = (select top 1 ABAC04 collate DATABASE_DEFAULT
					from dbo.ods_SalesCodeFlatFile 
					where ABALKY = ALKY collate DATABASE_DEFAULT)

	/**********************************************************************************//**
		3. Delete all of the duplicate addresses in the flat file
	*/
	/**************************************************************************************/
	delete
		from dbo.ods_SalesCodeFlatFile 
		where ABALKY in (select ALKY collate DATABASE_DEFAULT from #tempTable)

	/**********************************************************************************//**
		4. Merge the temp file back into the flat file.
	*/
	/**************************************************************************************/
	insert into dbo.ods_SalesCodeFlatFile
		select ALKY collate DATABASE_DEFAULT,
		       AC04 collate DATABASE_DEFAULT
		from #tempTable

	/**********************************************************************************//**
		5. Clean up
	*/
	/**************************************************************************************/
	drop table #tempTable

END