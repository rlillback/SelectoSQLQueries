use SELECTOJDE
go

select * from ods_CI_Item
where 
	left(ItemCode,1) <> N'/' and			-- doesn't start with a slash
	InactiveItem = N'N' and					-- Is an active item
	len(rtrim(ItemCode)) in (3,4,5,6) and   -- Is in a range that Kinetico may have a part number
	charindex(N'-', ItemCode) = 0 and	    -- Doesn't have a dash in it
	ItemCode not like '[a-zA-z]%'	        -- Doesn't start with an alpha character
order by ItemCode asc