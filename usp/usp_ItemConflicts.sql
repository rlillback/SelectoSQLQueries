use SelectoJDE
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-----------------------------------------------------------------------------------------
--
-- Grab all items in Sage that have a corresponding item number in JDE already
--
-- History:
-- 25-Aug-2019 R.Lillback Created Initial Version
-- 26-Aug-2019 R.Lillback Modified to show both ExtendedDescription and JDE Description
-- 27-Aug-2019 R.Lillback Populated atmp.ItemConflicts and moved location of sql script
--
-----------------------------------------------------------------------------------------
IF OBJECT_ID('dbo.usp_ItemConflicts') is not null begin
	print 'Dropping procedure dbo.usp_ItemConflicts';
	drop procedure dbo.usp_ItemConflicts
end
go

print 'Creating procedure dbo.usp_ItemConflicts';
go
CREATE PROCEDURE dbo.usp_ItemConflicts
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	truncate table atmp.ItemConflicts;

	declare @dt datetime = getdate();

	insert into atmp.ItemConflicts
		select CI.ItemCode as PartNumber, 
			   CI.ItemCodeDesc as SelectoDescr, 
			   RTRIM(e.ExtendedDescriptionText) as SelectoExtendedDescr, 
			   IMDSC1 as JDEDescription,
			   null as ActionKey,
			   @dt as DateUpdated
		from ods_CI_Item as CI
			join N0E9SQL01.JDE_PRODUCTION.PRODDTA.F4101 on LTRIM(RTRIM(ItemCode)) = LTRIM(RTRIM(IMLITM)) collate database_default
			left join ods_CI_ExtendedDescription as e on CI.ExtendedDescriptionKey = e.ExtendedDescriptionKey
		where InactiveItem = N'N'
END
GO
