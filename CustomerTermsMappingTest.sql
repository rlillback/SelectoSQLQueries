use SelectoJDE
go

select
	TermsCode as SageTermsCode,
	case TermsCode
		when N'00' then N'01'
		when N'02' then N'13'
		when N'05' then N'1.6'
		when N'07' then N'Not used??'
		when N'10' then N'N10'
		when N'11' then N'1/1'
		when N'14' then N'N14' -- new code
		when N'15' then N'N15'
		when N'20' then N'N20'
		when N'21' then N'2/1'
		when N'30' then N'N30'
		when N'35' then N'235' -- new code
		when N'36' then N'N36' -- new code
		when N'45' then N'N45'
		when N'46' then N'Not used??'
		when N'60' then N'N60'
		when N'90' then N'N90'
		else N'Not defined in mapping'
	end as JDE_Terms,
	COUNT(TermsCode) as [# of Customers Using]
from dbo.ods_AR_Customer
where CustomerStatus <> N'I' -- only select active customers
group by TermsCode
order by Count(TermsCode) desc
