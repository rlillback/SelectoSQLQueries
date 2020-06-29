use SelectoJDE
go

select
	  PartNumber
	, rtrim(SelectoDescr) as SelectoDescription
	, ISNULL(rtrim(SelectoExtendedDescr), '') as SelectoExtendedDescr
	, rtrim(JDEDescription) as JDEDescription
	, rtrim(ActionDescription) as ActionDescription
from atmp.ItemConflicts a
join atmp.ItemConflictActions b on a.ActionKey = b.ActionKey
