use SELECTOJDE
go

-----------------------------------------------------------------------------------------
--
-- Grab all items in Sage that have a corresponding item number in JDE already
--
-- History:
-- 25-Aug-2019 R.Lillback Created Initial Version
--
-----------------------------------------------------------------------------------------
select CI.* from ods_CI_Item as CI
join N0E9SQL01.JDE_PRODUCTION.PRODDTA.F4101 on LTRIM(RTRIM(ItemCode)) = LTRIM(RTRIM(IMLITM)) collate database_default
where InactiveItem = N'N'
order by ItemCode asc