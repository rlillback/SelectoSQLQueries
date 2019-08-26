use SelectoJDE
go

-----------------------------------------------------------------------------------------
--
-- Grab purchase orders placed since 1-Aug-2018 and consolidate by part number.
-- Don't include comment lines or non-stock purchase orders
-- Summarize by PN, Descr, Vendor, Vendor PN
-- Agregate by sum ordered
--
-- History:
-- 26-Aug-2019 R.Lillback Created initial version
--
-----------------------------------------------------------------------------------------
select
	d.ItemCode as PN,
	i.ItemCodeDesc as Descr,
	h.PurchaseName as Vendor,
	d.VendorAliasItemNo as VendPN,
	d.CommentText as CommentText,
	CAST(SUM(d.QuantityOrdered) as numeric(20,2)) as QORD

	--, *
from dbo.ods_PO_Header as h
join dbo.ods_PO_Detail as d on h.PurchaseOrderNo = d.PurchaseOrderNo
join dbo.ods_CI_Item as i on d.ItemCode = i.ItemCode
where rtrim(d.ItemCode) <> N'/C' and	-- don't grab comments
      rtrim(d.ItemCode) <> N'/MISC'		-- don't grab non-stock items
group by d.ItemCode, i.ItemCodeDesc, h.PurchaseName, d.VendorAliasItemNo, d.CommentText
order by PN asc, QORD desc