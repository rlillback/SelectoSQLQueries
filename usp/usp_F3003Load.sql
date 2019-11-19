use SelectoJDE
go

------------------------------------------------------------------------
--
-- Populate the initial routers for Selecto by making all the routers
-- the same and in the same workcenter 'SUW-ASSY'.
--
-- 1-Oct-2019 R.Lillback Created initial version
------------------------------------------------------------------------
IF EXISTS(SELECT * FROM SYS.objects WHERE TYPE = 'P' AND name = N'usp_F3003Load')
	DROP PROCEDURE dbo.usp_F3003Load
GO

CREATE PROCEDURE dbo.usp_F3003Load
AS
BEGIN
	if OBJECT_ID(N'tempdb..#mfgItems') is not null
		drop table #mfgItems
		
	if OBJECT_ID(N'tempdb..#tmpRouter') is not null
		drop table #tmpRouter
		
	create table #mfgItems (
		itemNum float null,
	)

	CREATE TABLE #tmpRouter(
		[IRTRT] [nchar](3) NOT NULL,
		[IRKIT] [float] NOT NULL,
		[IRKITL] [nchar](25) NULL,
		[IRKITA] [nchar](25) NULL,
		[IRMMCU] [nchar](12) NOT NULL,
		[IRALD] [nchar](4) NULL,
		[IRDSC1] [nchar](30) NULL,
		[IRLINE] [nchar](12) NOT NULL,
		[IRMCU] [nchar](12) NULL,
		[IROPSQ] [float] NOT NULL,
		[IREFFF] [numeric](18, 0) NOT NULL,
		[IREFFT] [numeric](18, 0) NULL,
		[IRBFPF] [nchar](1) NULL,
		[IRLAMC] [nchar](1) NULL,
		[IRTIMB] [nchar](1) NULL,
		[IROPSR] [float] NULL,
		[IRBQTY] [float] NOT NULL,
		[IRUOM] [nchar](2) NULL,
		[IRRUNM] [float] NULL,
		[IRRUNL] [float] NULL,
		[IRSETL] [float] NULL,
		[IRPWRT] [float] NULL,
		[IRSETC] [float] NULL,
		[IRMOVD] [float] NULL,
		[IRQUED] [float] NULL,
		[IRLTPC] [float] NULL,
		[IRPOVR] [float] NULL,
		[IRNXOP] [float] NULL,
		[IROPYP] [float] NULL,
		[IRCPYP] [float] NULL,
		[IRAPID] [nchar](12) NULL,
		[IRSHNO] [nchar](10) NULL,
		[IROPSC] [nchar](2) NOT NULL,
		[IRINPE] [nchar](2) NULL,
		[IRJBCD] [nchar](6) NULL,
		[IRAN8] [float] NULL,
		[IRVEND] [float] NULL,
		[IRPOY] [nchar](1) NULL,
		[IRCOST] [nchar](3) NULL,
		[IROMCU] [nchar](12) NULL,
		[IROBJ] [nchar](6) NULL,
		[IRSUB] [nchar](8) NULL,
		[IRRREV] [nchar](3) NULL,
		[IRURCD] [nchar](2) NULL,
		[IRURDT] [numeric](18, 0) NULL,
		[IRURAT] [float] NULL,
		[IRURRF] [nchar](15) NULL,
		[IRURAB] [float] NULL,
		[IRUSER] [nchar](10) NULL,
		[IRPID] [nchar](10) NULL,
		[IRUPMJ] [numeric](18, 0) NULL,
		[IRTDAY] [float] NULL,
		[IRJOBN] [nchar](10) NULL,
		[IRWMCU] [nchar](12) NULL,
		[IRLOCN] [nchar](20) NULL,
		[IRRUC] [float] NULL,
		[IRCAPU] [nchar](2) NULL,
		[IRACTB] [nchar](10) NULL,
		[IRNUMB] [float] NULL,
		[IRCBCO] [numeric](18, 0) NULL,
		[IRCICO] [numeric](18, 0) NULL,
		[IRIMCO] [numeric](18, 0) NULL,
		[IRMPRO] [float] NULL,
		[IRAPSC] [nchar](1) NULL,
		[IRMNSP] [float] NULL,
		[IRMXSP] [float] NULL,
		[IRCMPE] [nchar](3) NULL,
		[IRCMPC] [nchar](10) NULL,
		[IRCPLVLFR] [float] NULL,
		[IRCPLVLTO] [float] NULL,
		[IRCMRQ] [nchar](1) NULL,
		[IRANSA] [float] NULL,
		[IRANPA] [float] NULL,
		[IRANP] [float] NULL,
		[IRWSCHF] [nchar](1) NULL,
		[IRTRAF] [nchar](1) NULL,
		[IRDFOPC] [nchar](1) NULL,
	) ON [PRIMARY]

	declare @thisItem float;
	declare @thisLITM nchar(25);
	declare @tmpMCU nchar(12) = (select distinct IBMCU from atmp.F4102 where LTRIM(RTRIM(IBMCU)) = N'3SUW');
	declare @tmpWC nchar(12) = (select MCMCU from N0E9SQL01.JDE_DEVELOPMENT.TESTDTA.F0006 where MCSTYL = N'WC' and LTRIM(rtrim(MCMCU)) = 'SUW-ASSY');

	declare itmCursor scroll cursor for	select itemNum from #mfgItems;
		
	-- Audit data
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

	-- get all the manufactured items
	insert into 
		#mfgItems
			select distinct
				IBITM
			from
				atmp.F4102 as br
				join atmp.F3002 as bom on br.IBITM = bom.IXKIT
			where
				LTRIM(RTRIM(br.IBMCU)) = N'3SUW'
					and
				br.IBSTKT = N'M'
					and
				bom.IXTBM = N'M'
				

	open itmCursor;
	fetch first from itmCursor into @thisItem;

	while @@FETCH_STATUS = 0 begin
		set @thisLITM = (select IMLITM from atmp.F4101 where IMITM = @thisItem);
		insert into #tmpRouter 
			select
				N'M' COLLATE DATABASE_DEFAULT AS IRTRT,
				CAST(@thisItem AS FLOAT) AS IRKIT,
				@thisLITM COLLATE DATABASE_DEFAULT AS IRKITL,
				@thisLITM COLLATE DATABASE_DEFAULT AS IRKITA,
				@tmpMCU COLLATE DATABASE_DEFAULT AS IRMMCU,
				N'' COLLATE DATABASE_DEFAULT AS IRALD,
				N'MAKE PART' COLLATE DATABASE_DEFAULT AS IRDSC1,
				N'' COLLATE DATABASE_DEFAULT AS IRLINE,
				@tmpWC COLLATE DATABASE_DEFAULT AS IRMCU,
				CAST(1000 AS FLOAT) AS IROPSQ,
				118001 AS IREFFF,
				140365 AS IREFFT,
				N'B' COLLATE DATABASE_DEFAULT AS IRBFPF,
				N'' COLLATE DATABASE_DEFAULT AS IRLAMC,
				N'3' COLLATE DATABASE_DEFAULT AS IRTIMB,
				CAST(0 AS FLOAT) AS IROPSR,
				CAST(0 AS FLOAT) AS IRBQTY,
				N'EA' COLLATE DATABASE_DEFAULT AS IRUOM,
				CAST(0 AS FLOAT) AS IRRUNM,
				CAST(1 AS FLOAT) AS IRRUNL,
				CAST(0 AS FLOAT) AS IRSETL,
				CAST(0 AS FLOAT) AS IRPWRT,
				CAST(10 AS FLOAT) AS IRSETC,
				CAST(0 AS FLOAT) AS IRMOVD,
				CAST(0 AS FLOAT) AS IRQUED,
				CAST(0 AS FLOAT) AS IRLTPC,
				CAST(0 AS FLOAT) AS IRPOVR,
				CAST(0 AS FLOAT) AS IRNXOP,
				CAST(10000 AS FLOAT) AS IROPYP,
				CAST(10000 AS FLOAT) AS IRCPYP,
				N'' COLLATE DATABASE_DEFAULT AS IRAPID,
				N'' COLLATE DATABASE_DEFAULT AS IRSHNO,
				N'' COLLATE DATABASE_DEFAULT AS IROPSC,
				N'' COLLATE DATABASE_DEFAULT AS IRINPE,
				N'' COLLATE DATABASE_DEFAULT AS IRJBCD,
				CAST(0 AS FLOAT) AS IRAN8,
				CAST(0 AS FLOAT) AS IRVEND,
				N'' COLLATE DATABASE_DEFAULT AS IRPOY,
				N'' COLLATE DATABASE_DEFAULT AS IRCOST,
				N'' COLLATE DATABASE_DEFAULT AS IROMCU,
				N'' COLLATE DATABASE_DEFAULT AS IROBJ,
				N'' COLLATE DATABASE_DEFAULT AS IRSUB,
				N'' COLLATE DATABASE_DEFAULT AS IRRREV,
				N'' COLLATE DATABASE_DEFAULT AS IRURCD,
				0 AS IRURDT,
				CAST(0 AS FLOAT) AS IRURAT,
				N'' COLLATE DATABASE_DEFAULT AS IRURRF,
				CAST(0 AS FLOAT) AS IRURAB,
				@user COLLATE DATABASE_DEFAULT AS IRUSER,
				@pid COLLATE DATABASE_DEFAULT AS IRPID,
				@jToday AS IRUPMJ,
				CAST(@tNow AS FLOAT) AS IRTDAY,
				@jobn COLLATE DATABASE_DEFAULT AS IRJOBN,
				@tmpMCU COLLATE DATABASE_DEFAULT AS IRWMCU,
				N'' COLLATE DATABASE_DEFAULT AS IRLOCN,
				CAST(0 AS FLOAT) AS IRRUC,
				N'' COLLATE DATABASE_DEFAULT AS IRCAPU,
				N'' COLLATE DATABASE_DEFAULT AS IRACTB,
				CAST(0 AS FLOAT) AS IRNUMB,
				0 AS IRCBCO,
				0 AS IRCICO,
				0 AS IRIMCO,
				CAST(0 AS FLOAT) AS IRMPRO,
				N'' COLLATE DATABASE_DEFAULT AS IRAPSC,
				CAST(0 AS FLOAT) AS IRMNSP,
				CAST(0 AS FLOAT) AS IRMXSP,
				N'' COLLATE DATABASE_DEFAULT AS IRCMPE,
				N'' COLLATE DATABASE_DEFAULT AS IRCMPC,
				CAST(0 AS FLOAT) AS IRCPLVLFR,
				CAST(0 AS FLOAT) AS IRCPLVLTO,
				N'1' COLLATE DATABASE_DEFAULT AS IRCMRQ,
				CAST(0 AS FLOAT) AS IRANSA,
				CAST(0 AS FLOAT) AS IRANPA,
				CAST(0 AS FLOAT) AS IRANP,
				N'' COLLATE DATABASE_DEFAULT AS IRWSCHF,
				N'0' COLLATE DATABASE_DEFAULT AS IRTRAF,
				N'Y' COLLATE DATABASE_DEFAULT AS IRDFOPC

		fetch next from itmCursor into @thisItem;
	end

	close itmCursor;
	deallocate itmCursor;

	-- Now update any item numbers that are not populated because they were already in JDE
	update rtr
	set IRKITL = (select IMLITM from N0E9SQL01.JDE_DEVELOPMENT.TESTDTA.F4101 where IMITM = IRKIT),
	    IRKITA = (select IMAITM from N0E9SQL01.JDE_DEVELOPMENT.TESTDTA.F4101 where IMITM = IRKIT)
	from #tmpRouter as rtr
	where IRKITL is null


	truncate table atmp.F3003;  -- truncate the table before adding data into it.
	insert into atmp.F3003 select * from #tmpRouter

	drop table #mfgItems
	drop table #tmpRouter
end
