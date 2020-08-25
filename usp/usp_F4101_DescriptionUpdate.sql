use SelectoJDE
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ****************************************************************************************
-- Update atmp.F4101 item descriptions from Flat File
--
-- History: 
-- 24-Jul-2020 R.Lillback Created Initial Version
--
-- TODO:
--  
-- ****************************************************************************************
IF EXISTS(SELECT * FROM SYS.objects WHERE TYPE = 'P' AND name = N'usp_F4101_DescriptionUpdate')
	DROP PROCEDURE dbo.usp_F4101_DescriptionUpdate
GO

CREATE PROCEDURE dbo.usp_F4101_DescriptionUpdate
AS
BEGIN

	SET NOCOUNT ON;

	update x
		set IMDSC1 = Descr
	from atmp.F4101 as x
	join dbo.ods_ItemDescriptionFlatFile on IMLITM = Item

END
GO