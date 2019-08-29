use SelectoJDE
go

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
order by ItemCode asc