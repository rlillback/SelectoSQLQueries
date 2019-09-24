--
-- List BOMs that will not be imported into JDE
--
select
	BillNo, BillDesc1, i.InactiveItem as Inactive
from 
	dbo.ods_BM_BillHeader
	left join dbo.ods_CI_Item i on BillNo = ItemCode
	left join atmp.ItemConflicts c on BillNo = PartNumber
	left join atmp.ItemConflictActions a on c.ActionKey = a.ActionKey
	left join atmp.F4102 on BillNo = IBLITM
	left join atmp.F4101 on IBLITM = IMLITM
where ibitm is null and c.ActionKey is null