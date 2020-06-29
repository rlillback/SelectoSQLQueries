use jde_development
go

if object_id(N'tempdb..#temprules') is not null
	drop table #temprules

CREATE TABLE #temprules(
	[ADAST] [nchar](8) NOT NULL,
	[ADITM] [float] NOT NULL,
	[ADLITM] [nchar](25) NULL,
	[ADAITM] [nchar](25) NULL,
	[ADAN8] [float] NOT NULL,
	[ADIGID] [float] NOT NULL,
	[ADCGID] [float] NOT NULL,
	[ADOGID] [float] NOT NULL,
	[ADCRCD] [nchar](3) NOT NULL,
	[ADUOM] [nchar](2) NOT NULL,
	[ADMNQ] [float] NOT NULL,
	[ADEFTJ] [numeric](18, 0) NULL,
	[ADEXDJ] [numeric](18, 0) NOT NULL,
	[ADBSCD] [nchar](1) NULL,
	[ADLEDG] [nchar](2) NULL,
	[ADFRMN] [nchar](10) NULL,
	[ADFVTR] [float] NULL,
	[ADFGY] [nchar](1) NULL,
	[ADATID] [float] NULL,
	[ADURCD] [nchar](2) NULL,
	[ADURDT] [numeric](18, 0) NULL,
	[ADURAT] [float] NULL,
	[ADURAB] [float] NULL,
	[ADURRF] [nchar](15) NULL,
	[ADNBRORD] [float] NULL,
	[ADUOMVID] [nchar](2) NULL,
	[ADFVUM] [nchar](2) NULL,
	[ADPARTFG] [nchar](1) NULL,
	[ADAPRS] [nchar](1) NULL,
	[ADUSER] [nchar](10) NULL,
	[ADPID] [nchar](10) NULL,
	[ADJOBN] [nchar](10) NULL,
	[ADUPMJ] [numeric](18, 0) NOT NULL,
	[ADTDAY] [float] NOT NULL,
	[ADBKTPID] [float] NULL,
	[ADCRCDVID] [nchar](3) NULL,
	[ADRULENAME] [nchar](10) NULL,
	)

insert into #temprules
	select 
		a.* 
	from testdta.F4072 a
	join testdta.F40941 on ADIGID = IKIGID
	where IKPRGR = N'SU'

update #temprules
	set ADAST = N'DISCDOL', ADBSCD = '5', ADFVTR = 0

insert into testdta.F4072
	select * from #temprules

drop table #temprules

