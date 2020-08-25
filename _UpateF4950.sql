USE [JDE_DEVELOPMENT]
GO

/****** Object:  Table [TESTDTA].[F4950]    Script Date: 7/22/2020 1:39:34 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

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

delete testdta.F4950 where RTORGN = 8023

insert into #F4950
select * from jde_production.proddta.F4950 where rtorgn = 8000 order by rtrtn

-- Set the JDE audit data
declare @user nvarchar(10) = N'RLILLBACK';
declare @pid nvarchar(10) = N'SQLLD';
declare @jobn nvarchar(10) = N'SQLLD';
declare @jToday numeric(18,0)= dbo.fn_DateTimeToJulian(GETDATE()); -- Julian Date Today
declare @tNow float = CONVERT (
								float,
								datepart(hh,getdate())*10000 + 
								datepart(mi, getdate())*100 +
								datepart(ss, getdate())
								); -- Time now as held by JDE
declare @mcu nchar(12) = (select MCMCU from testdta.F0006 where ltrim(rtrim(MCMCU)) = N'3SUW');
declare @startingRoute float = (select max(RTRTN) from jde_production.proddta.F4950);

update #F4950
set RTORGN = 8023, RTNMCU = @mcu, RTADDZ = N'*', RTCZON = N'', RTRSLA = 1, RTMCU = @mcu,
    RTUSER = @user, RTPID = @pid, RTJOBN = @jobn, RTUPMJ = @jToday, RTTDAY = @tNow

update x
set RTRTN = newRTRTN
from (
	select RTRTN, 
	(@startingRoute + ROW_NUMBER() OVER (ORDER BY RTRTN)) as newRTRTN
	from #F4950
) as x

insert into testdta.F4950
select * from #F4950 
drop table #F4950