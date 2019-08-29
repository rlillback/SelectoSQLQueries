use SelectoJDE
go

-----------------------------------------------------------------------------------------
--
-- List all the item conflicts and resolutions
--
-- History:
-- 28-Aug-2019 Created initial version
--
-----------------------------------------------------------------------------------------
select 
	c.PartNumber,
	c.SelectoDescr,
	c.SelectoExtendedDescr,
	c.JDEDescription,
	a.ActionDescription 
from atmp.ItemConflicts as c
	 left join atmp.ItemConflictActions as a on c.ActionKey = a.ActionKey