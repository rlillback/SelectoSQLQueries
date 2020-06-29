use SelectoJDE
go

select distinct
		a.ItemCode
	 ,  a.ItemCodeDesc
	 ,  a.InactiveItem
	 ,  ISNULL((select distinct TransactionCode from dbo.ods_IM_ItemTransactionHistory where ItemCode = a.ItemCode and TransactionCode = 'PO'), '') as HasPO
	 ,  ISNULL((select distinct TransactionCode from dbo.ods_IM_ItemTransactionHistory where ItemCode = a.ItemCode and TransactionCode = 'WR'), '') as HasWO
	 ,  case
			when ((select BillNo from dbo.ods_BM_BillHeader where BillNo = a.ItemCode) is null) then 'No'
			else 'Yes'
		end as HasBOM
from dbo.ods_CI_Item as a
left join dbo.ods_IM_ItemTransactionHistory as b on a.ItemCode = b.ItemCode 
where b.TransactionCode in ('PO','WR') and a.ProcurementType = 'B' and a.InactiveItem = 'N'
order by ItemCode asc

