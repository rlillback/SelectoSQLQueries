use SelectoJDE
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-------------------------------------------------------------------------------------------
-- Delete R3 data from the temporary tables F0101, F0111, F0115, F0116
--
-- 12-Feb-2020 R.Lillback Created Initial Version
--------------------------------------------------------------------------------------------
IF EXISTS(SELECT * FROM SYS.objects WHERE TYPE = 'P' AND name = N'usp_DeleteR3DataFromAB')
	DROP PROCEDURE dbo.usp_DeleteR3DataFromAB
GO

CREATE PROCEDURE dbo.usp_DeleteR3DataFromAB
AS
BEGIN
	if OBJECT_ID(N'tempdb..#AN8sToRemove') is not NULL
		drop table #AN8sToRemove

	create table #AN8sToRemove (
		AN8 float not NULL,
	)

	insert into #AN8sToRemove
		select ABAN8 from atmp.F0101 where ABAT1 = N'R3'

	delete from atmp.F0101
		where ABAN8 in (select AN8 from #AN8sToRemove)

	delete from atmp.F0116
		where ALAN8 in (select AN8 from #AN8sToRemove)

	delete from atmp.F0115
		where WPAN8 in (select AN8 from #AN8sToRemove)

	delete from atmp.F0111
		where WWAN8 in (select AN8 from #AN8sToRemove)

	delete from atmp.F0401
		where A6AN8 in (select AN8 from #AN8sToRemove)

	drop table #AN8sToRemove
END
