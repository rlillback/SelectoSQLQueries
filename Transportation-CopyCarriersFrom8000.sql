use JDE_DEVELOPMENT
go

declare @startRTRN float = (select max(RTRTN) from testdta.F4950)

if object_id(N'tempdb..#F4950') is not NULL
	drop table #F4950

CREATE TABLE #F4950(
	[RTORGN] [float] NULL,
	[RTADDO] [nchar](12) NULL,
	[RTCTRO] [nchar](3) NULL,
	[RTCARS] [float] NULL,
	[RTNMCU] [nchar](12) NULL,
	[RTRTN] [float] NOT NULL,
	[RTMOT] [nchar](3) NULL,
	[RTCTY1] [nchar](25) NULL,
	[RTCOUN] [nchar](25) NULL,
	[RTADDS] [nchar](3) NULL,
	[RTADDZ] [nchar](12) NULL,
	[RTZON] [nchar](3) NULL,
	[RTCTR] [nchar](3) NULL,
	[RTCZON] [nchar](10) NULL,
	[RTSHAN] [float] NULL,
	[RTROUT] [nchar](3) NULL,
	[RTRSLA] [nchar](1) NULL,
	[RTDESC] [nchar](30) NULL,
	[RTFRSI] [nchar](8) NULL,
	[RTFRSC] [nchar](8) NULL,
	[RTFRCI] [float] NULL,
	[RTFRCG] [float] NULL,
	[RTCRCD] [nchar](3) NULL,
	[RTFRTP] [nchar](1) NULL,
	[RTRTGB] [nchar](1) NULL,
	[RTRTUM] [nchar](2) NULL,
	[RTDSTN] [float] NULL,
	[RTUMD1] [nchar](2) NULL,
	[RTLTDL] [float] NULL,
	[RTLTDT] [float] NULL,
	[RTPRFM] [float] NULL,
	[RTEFTJ] [numeric](18, 0) NULL,
	[RTEXDJ] [numeric](18, 0) NULL,
	[RTMCU] [nchar](12) NULL,
	[RTFCNM] [nchar](32) NULL,
	[RTURCD] [nchar](2) NULL,
	[RTURDT] [numeric](18, 0) NULL,
	[RTURAT] [float] NULL,
	[RTURAB] [float] NULL,
	[RTURRF] [nchar](15) NULL,
	[RTUSER] [nchar](10) NULL,
	[RTPID] [nchar](10) NULL,
	[RTJOBN] [nchar](10) NULL,
	[RTUPMJ] [numeric](18, 0) NULL,
	[RTTDAY] [float] NULL,
	[RTPRTE] [nchar](1) NULL,
	[RTCNMR] [nchar](24) NULL,
	[RTTX] [nchar](1) NULL,
	[RTTXA1] [nchar](10) NULL,
	[RTEXR1] [nchar](2) NULL,
	[RTTAX1] [nchar](1) NULL,
	[RTTXA2] [nchar](10) NULL,
	[RTEXR2] [nchar](2) NULL,
)

insert into #F4950
	select * from testdta.F4950 where RTORGN = 8000

update #F4950 
	set RTORGN = 8023

update x
	set x.RTRTN = x.NewRTRTN
from (
	   select 
			RTRTN,
			(@startRTRN + ROW_NUMBER() over (order by RTRTN)) as NewRTRTN
	   from #F4950
     ) as x

insert into testdta.F4950
	select * from #F4950

drop table #F4950