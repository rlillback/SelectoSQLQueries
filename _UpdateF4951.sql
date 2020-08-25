USE [JDE_DEVELOPMENT]
GO

/****** Object:  Table [TESTDTA].[F4951]    Script Date: 7/22/2020 12:00:42 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE #F4951(
	[ZNORGN] [float] NOT NULL,
	[ZNCZON] [nchar](10) NOT NULL,
	[ZNZTO] [nchar](12) NOT NULL,
	[ZNZTH] [nchar](12) NULL,
	[ZNCTY1] [nchar](25) NOT NULL,
	[ZNADDS] [nchar](3) NOT NULL,
	[ZNCOUN] [nchar](25) NOT NULL,
	[ZNCTR] [nchar](3) NOT NULL,
	[ZNURCD] [nchar](2) NULL,
	[ZNURDT] [numeric](18, 0) NULL,
	[ZNURAT] [float] NULL,
	[ZNURAB] [float] NULL,
	[ZNURRF] [nchar](15) NULL,
	[ZNUSER] [nchar](10) NULL,
	[ZNPID] [nchar](10) NULL,
	[ZNJOBN] [nchar](10) NULL,
	[ZNUPMJ] [numeric](18, 0) NULL,
	[ZNTDAY] [float] NULL,
) 

insert into #F4951
	select * from testdta.F4951 where ZNORGN = 8000 and ZNCZON in ('ALLUS','NOTUS')

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

update #F4951
	set znorgn = 8023, znuser = @user, znpid = @pid, znjobn = @jobn, znupmj = @jToday, zntday = @tNow

insert into testdta.F4951
select * from #F4951
drop table #F4951