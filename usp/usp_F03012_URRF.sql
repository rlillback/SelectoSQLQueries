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
end
go