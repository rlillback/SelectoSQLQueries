use SelectoJDE
go

select 
	  ih.ItemCode
	, im.ItemCodeDesc
	, ih.TransactionCode
	, ih.TransactionDate
	, vm.VendorName
	, ih.TransactionQty
from dbo.ods_IM_ItemTransactionHistory as ih
join dbo.ods_CI_Item as im on ih.ItemCode = im.ItemCode
left join dbo.ods_AP_Vendor as vm on ih.VendorNo = vm.VendorNo
where im.ProcurementType = 'B'
	and im.InactiveItem = 'N'
	and ih.TransactionCode = 'PO'
order by ItemCode asc, TransactionDate desc