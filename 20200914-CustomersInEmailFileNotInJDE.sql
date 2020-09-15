use selectojde
go

select 
	substring(data,1,patindex('% %',data)-1) as [Customer Number],
	(select top 1 nm from dbo.ods_CustomerEmailsFlatFile where alky = substring(data,1,patindex('% %',data)-1)) as [Customer Name],
	ltrim(substring(data,patindex('% %',data), len(data))) as error
from dbo.error_CustomerEmailLoad 
where 
	reason = N'Error populating customer in dbo.usp_F0111_CustomerEmails'