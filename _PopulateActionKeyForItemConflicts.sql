--select * from atmp.ItemConflictActions
--select * from atmp.ItemConflicts

update atmp.ItemConflicts set ActionKey = 1
update atmp.ItemConflicts set ActionKey = 3 where ltrim(rtrim(PartNumber)) = '300-054'
update atmp.ItemConflicts set ActionKey = 2 where ltrim(rtrim(PartNumber))in ('10028','10045','10078','10089','108-010','108-014','11028','11045','11078','11089','16532','16627','200000','80-6100','80-6140','WET')