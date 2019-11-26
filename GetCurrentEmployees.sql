use SelectoJDE
go

if object_id(N'tempdb..#tmpUser') is not null
	drop table #tmpUser

create table #tmpUser (
	UserLogon nchar(60) null,
)

insert into #tmpUser
Select 
	distinct UserLogon 
from 
	ods_SY_ActivityLog 
where 
	LogDate >= '2019-05-30' 
		and 
	CompanyCode = 'SSI'
		and
	UserLogon not in ('mba', 'rlillback')

select 
	890000-1+ROW_NUMBER() over (order by UserKey) as ABNum,
	(LEFT(FirstName,1)+UPPER(LastName)) as JDE_Login,
	u.* 
from 
	dbo.ods_SY_User as u
	inner join #tmpUser as t on u.UserLogon = t.UserLogon collate database_default

drop table #tmpUser