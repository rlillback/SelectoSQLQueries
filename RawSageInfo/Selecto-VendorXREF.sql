use SelectoJDE
go

-----------------------------------------------------------------------------------------
--
-- Grab all "Buy" items that don't have a vendor crossreference number followed by
-- all "Buy" items that do have a vendor crossreference number
--
-- History:
-- 25-Aug-2019 R.Lillback Created Initial Version
--
-----------------------------------------------------------------------------------------
select
	N'No' as XREF,
	v.VendorNo as Vendor,
	*
from dbo.ods_CI_Item as i
	left join dbo.ods_IM_ItemVendor as v on i.ItemCode = v.ItemCode
where i.InactiveItem = N'N' and			-- active items only
      left(i.ItemCode,1) <> N'/' and	-- not a dummy item
	  i.ProcurementType = N'B' and		-- Purchased item??
	  v.ItemCode is null
union all
select
	N'Yes' as XREF,
	v.VendorNo as Vendor,
	*
from dbo.ods_CI_Item as i
	left join dbo.ods_IM_ItemVendor as v on i.ItemCode = v.ItemCode
where i.InactiveItem = N'N' and			-- active items only
      left(i.ItemCode,1) <> N'/' and	-- not a dummy item
	  i.ProcurementType = N'B' and		-- Purchased item??
	  v.ItemCode is not null
order by XREF asc, i.ItemCode asc


	  
      