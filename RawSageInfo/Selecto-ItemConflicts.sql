use SELECTOJDE
go

-----------------------------------------------------------------------------------------
--
-- Grab all items in Sage that have a corresponding item number in JDE already
--
-- History:
-- 25-Aug-2019 R.Lillback Created Initial Version
-- 26-Aug-2019 R.Lillback Modified to show both ExtendedDescription and JDE Description
--
-----------------------------------------------------------------------------------------
select CI.ItemCode as PN, CI.ItemCodeDesc as SageDesc, RTRIM(e.ExtendedDescriptionText) as SageExtDesc, IMDSC1 as JDEDesc from ods_CI_Item as CI
join N0E9SQL01.JDE_PRODUCTION.PRODDTA.F4101 on LTRIM(RTRIM(ItemCode)) = LTRIM(RTRIM(IMLITM)) collate database_default
left join ods_CI_ExtendedDescription as e on CI.ExtendedDescriptionKey = e.ExtendedDescriptionKey
where InactiveItem = N'N'
order by ItemCode asc