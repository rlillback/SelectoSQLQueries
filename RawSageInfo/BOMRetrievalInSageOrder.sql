use SELECTOJDE
go


-----------------------------------------------------------------------------------------
--
-- Get raw BOM data in the same order it appears on the Sage screen
--
-- History:
-- 25-Aug-2019 R.Lillback Created initial version
--
-----------------------------------------------------------------------------------------
select * from dbo.ods_BM_BillHeader as h
join dbo.ods_BM_BillDetail as d on h.BillNo = d.BillNo
order by d.BillNo asc, d.LineSeqNo asc