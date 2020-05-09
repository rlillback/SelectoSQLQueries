use SelectoJDE
go

-- ****************************************************************************************
-- Modify stocking type for WIP cartridges
--
--
-- NOTES:
--
-- HISTORY:
--   09-May-2020 R.Lillback Created Initial Version
-- ****************************************************************************************

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF EXISTS(SELECT * FROM SYS.objects WHERE TYPE = 'P' AND name = N'usp_F4102_UpdateCartridges')
	print('DROP PROCEDURE dbo.usp_F4102_UpdateCartridges');
	DROP PROCEDURE dbo.usp_F4102_UpdateCartridges
GO

print('CREATE PROCEDURE dbo.usp_F4102_UpdateCartridges')
GO
CREATE PROCEDURE dbo.usp_F4102_UpdateCartridges
AS
BEGIN
	SET NOCOUNT ON;
	update atmp.F4102
		set IBSTKT = N'M', IBANPL = 303, IBPRP9 = N'WIP'
		where IBLITM in (N'101-390-C' , N'108-067CH' , N'108C010' , N'108C010NS' , N'108C014' , N'108C014NS' , 
			             N'108C020' , N'108C020NS' , N'108C067' , N'108C067AF' , N'108C220' , N'108C600' , N'108C620')     

	update N0E9SQL01.JDE_DEVELOPMENT.TESTDTA.F4102
		set IBSTKT = N'M', IBANPL = 303, IBPRP9 = N'WIP'
		where IBLITM in (N'101-390-C' , N'108-067CH' , N'108C010' , N'108C010NS' , N'108C014' , N'108C014NS' , 
			             N'108C020' , N'108C020NS' , N'108C067' , N'108C067AF' , N'108C220' , N'108C600' , N'108C620')  
		       AND ltrim(rtrim(IBMCU)) = N'3SUW'
END

GO


