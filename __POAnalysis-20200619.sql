use SelectoJDE
go

--select * from dbo.ods_CI_Item where ProcurementType = 'B'
-- select * from dbo.ods_PO_Detail
-- select * from dbo.ods_PO_Header
if object_id(N'tempdb..#report') is not null
	drop table #report

create table #report (
	Item nchar(30),
	Description nchar(30),
	VendorCode nchar(7),
	VendorsName nchar(50),
	LastRequired date,
	LastPOQty float null
)

insert into #report
	select 
		  a.ItemCode
		, b.ItemCodeDesc
		, c.VendorNo
		, d.VendorName
		, MAX(a.RequiredDate) as LastRequired
		, null
	from dbo.ods_PO_Detail a 
	join dbo.ods_CI_Item b on a.ItemCode = b.ItemCode 
	join dbo.ods_PO_Header c on a.PurchaseOrderNo = c.PurchaseOrderNo
	join dbo.ods_AP_Vendor d on c.VendorNo = d.VendorNo
	where b.ProcurementType = 'B'
	group by a.ItemCode, b.ItemCodeDesc, c.VendorNo, d.VendorName

update r
	set LastPOQty = a.QuantityOrdered
from #report as r
join dbo.ods_PO_Detail a on r.Item = a.ItemCode collate database_default and r.LastRequired =  a.RequiredDate 

select * from #report
order by Item asc, LastRequired desc

drop table #report