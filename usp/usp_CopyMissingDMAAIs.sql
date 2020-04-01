use SelectoJDE
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ****************************************************************************************
-- Populate missing DMAAIs from the pre-data load backup 
--
-- History: 
-- 29-Mar-2020 - R.Lillback Created Initial Version
--
-- TODO:
--  
-- ****************************************************************************************
IF EXISTS(SELECT * FROM SYS.objects WHERE TYPE = 'P' AND name = N'usp_CopyMissingDMAAIs')
	DROP PROCEDURE dbo.usp_CopyMissingDMAAIs
GO

CREATE PROCEDURE dbo.usp_CopyMissingDMAAIs
AS
BEGIN
	insert into N0E9SQL01.JDE_DEVELOPMENT.TESTDTA.F4095
		select a.*
		from atmp.F4095_BACKUP as a
		left join N0E9SQL01.JDE_DEVELOPMENT.TESTDTA.F4095 as b on
				a.MLANUM = b.MLANUM and
				a.MLCO = b.MLCO collate database_default and
				a.MLDCTO = b.MLDCTO collate database_default and
				a.MLDCT = b.MLDCT collate database_default and
				a.MLGLPT = b.MLGLPT collate database_default and
				a.MLCOST = b.MLCOST collate database_default
		where b.MLANUM is null
END