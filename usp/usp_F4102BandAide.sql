use SelectoJDE
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-----------------------------------------------------------------------------------------
--
-- Change the stocking type and PRP9 field from a flat file
--
-- History:
-- 20200916 R.Lillback Created Initial Version
--
-----------------------------------------------------------------------------------------
IF OBJECT_ID('dbo.usp_F4102BandAide') is not null begin
	print 'Dropping procedure dbo.usp_F4102BandAide';
	drop procedure dbo.usp_F4102BandAide
end
go

print 'Creating procedure dbo.usp_F4102BandAide';
go

CREATE PROCEDURE dbo.usp_F4102BandAide
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	update x
		set IBSTKT = stocking, IBPRP9 = code
	from atmp.F4102 as x
	join dbo.ods_ItemBandAidFlatFile on IBLITM = item

	update x
		set IMSTKT = stocking, IMPRP9 = code
	from atmp.F4101 as x
	join dbo.ods_ItemBandAidFlatFile on IMLITM = item 

end
go