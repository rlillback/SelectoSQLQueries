use SelectoJDE
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ****************************************************************************************
-- Import BOM data from Sage into a temporary table called atmp.F3002
--
-- Assumptions:  atmp.F4101 and atmp.F4102 have all of the items loaded into them
--
-- HISTORY:
--   24-Sep-2019 R.Lillback Created initial version
--   26-Nov-2019 R.Lillback Fixed bug where BOM lines did not populate if the PN already
--               exists in JDE; therefore, atmp.F4101 is null.  If NULL, then grab
--	             IMUOM1 from JDE_DEVELOPMENT.
--   15-Sep-2020 R.Lillback Removed 1452 from being replaced in the BOMs
-- ****************************************************************************************
IF EXISTS(SELECT * FROM SYS.objects WHERE TYPE = 'P' AND name = N'usp_F3002Load')
	DROP PROCEDURE dbo.usp_F3002Load
GO

CREATE PROCEDURE dbo.usp_F3002Load 
AS
BEGIN
	SET NOCOUNT ON;
	-- First, let's create a couple of temporary tables
	if OBJECT_ID(N'tempdb..#BOMList') is not null
		drop table #BOMList
	if OBJECT_ID(N'tempdb..#BOMTemp') is not null
		drop table #BOMTemp


	-- This table holds all the Items that have a BOM in Sage	
	create table #BOMList (
		ParentNum varchar(25),
	)
	-- This table is a transform of the Sage BOM that matches up with JDE
	create table #BOMTemp (
		ParentNum nvarchar(25) collate database_default, -- This is IXKITL
		ChildNum nvarchar(25) collate database_default, -- This is IXLITM
		Reference nvarchar(30) collate database_default, -- This is IXDSC1
		LineNumShort float, -- This is IXCPNT & 100 times this is IXCPNB
		LineQty float, -- This is IXQNTY
	)


	-- Get all the items that have a BOM
	insert into #BOMList
		select
			left(ltrim(rtrim(BillNo)),25)
		from 
			dbo.ods_BM_BillHeader
			left join atmp.F4102 on BillNo = IBLITM
		where IBLITM is not null


	-- delcare a variable to loop through all the items that have a BOM
	declare @current varchar(25);
	declare bom_cursor cursor for
		select ParentNum from #BOMList
		
	-- build the temporary BOM list and translate the list into JDE speak
	open bom_cursor
		fetch next from bom_cursor into @current
		while @@FETCH_STATUS = 0 begin
			insert into #BOMTemp(ParentNum, ChildNum, Reference, LineNumShort, LineQty)
				select 
					@current as ParentNum,
					left(ltrim(rtrim(ComponentItemCode)),25) as ChildNum,
					left(ltrim(rtrim(ISNULL(CommentText, N''))),30) as Reference,					
					cast(LineSeqNo as float)/1000000 as LineNumShort,
					CAST(QuantityPerBill as float) as LineQty
				from dbo.ods_BM_BillDetail as Sage
				where Sage.BillNo = @current
			fetch next from bom_cursor into @current
		end
	close bom_cursor
	deallocate bom_cursor

	-- Now add the -SU suffix to those items that had item conflicts
	update 
		bom
	set 
		ChildNum = rtrim(ChildNum) + N'-SU'
	from 
		#BOMTemp bom
		inner join atmp.ItemConflicts on ChildNum = PartNumber collate database_default
	where
		ActionKey = 2

-- Do NOT do anything with 300-054


	-- truncate the table first
	truncate table atmp.F3002

	-- Set up the audit trail
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
	                               
	insert into atmp.F3002
	select
			N'M' COLLATE database_default AS IXTBM,
			CAST( IB1.IBITM AS FLOAT) AS IXKIT,
			LEFT(Sage.ParentNum,25) COLLATE database_default AS IXKITL,
			IB1.IBAITM COLLATE database_default AS IXKITA,
			IB1.IBMCU COLLATE database_default AS IXMMCU,
			CAST( IB2.IBITM AS FLOAT) AS IXITM,
			LEFT(Sage.ChildNum,25) COLLATE database_default AS IXLITM,
			IB2.IBAITM COLLATE database_default AS IXAITM,
			IB2.IBMCU COLLATE database_default AS IXCMCU,
			CAST( Sage.LineNumShort * 10 AS FLOAT) AS IXCPNT,
			CAST( 0 AS FLOAT) AS IXSBNT,
			N'Y' COLLATE database_default AS IXPRTA,
			CAST( Sage.LineQty AS FLOAT) AS IXQNTY,
			-- ### RAL Modified the following line to account for items that exist alredy in JDE
			ISNULL(IM2.IMUOM1, (SELECT IMUOM1 FROM N0E9SQL01.JDE_DEVELOPMENT.TESTDTA.F4101 WHERE Sage.ChildNum collate database_default = IMLITM)) COLLATE database_default AS IXUM,
			CAST( 0 AS FLOAT) AS IXBQTY,
			N'EA' COLLATE database_default AS IXUOM,
			N'V' COLLATE database_default AS IXFVBT,
			118001 AS IXEFFF,
			140365 AS IXEFFT,
			N'' COLLATE database_default AS IXFSER,
			N'' COLLATE database_default AS IXTSER,
			N'B' COLLATE database_default AS IXITC,
			N'N' COLLATE database_default AS IXFTRC,
			N'S' COLLATE database_default AS IXOPTK,
			N'' COLLATE database_default AS IXFORV,
			N'' COLLATE database_default AS IXCSTM,
			N'' COLLATE database_default AS IXCSMP,
			N'' COLLATE database_default AS IXORDW,
			N'V' COLLATE database_default AS IXFORQ,
			N'' COLLATE database_default AS IXCOBY,
			N'' COLLATE database_default AS IXCOTY,
			CAST( 0 AS FLOAT) AS IXFRMP,
			CAST( 0 AS FLOAT) AS IXTHRP,
			N'' COLLATE database_default AS IXFRGD,
			N'' COLLATE database_default AS IXTHGD,
			CAST( 1000 AS FLOAT) AS IXOPSQ,
			CAST( 0 AS FLOAT) AS IXBSEQ,
			CAST( 10000 AS FLOAT) AS IXFTRP,
			CAST( 10000 AS FLOAT) AS IXF$RP,
			CAST( 0 AS FLOAT) AS IXRSCP,
			CAST( 0 AS FLOAT) AS IXSCRP,
			CAST( 0 AS FLOAT) AS IXREWP,
			CAST( 0 AS FLOAT) AS IXASIP,
			CAST( 10000 AS FLOAT) AS IXCPYP,
			CAST( 0 AS FLOAT) AS IXSTPP,
			CAST( 0 AS FLOAT) AS IXLOVD,
			N'' COLLATE database_default AS IXECO,
			N'' COLLATE database_default AS IXECTY,
			0 AS IXECOD,
			LEFT(Sage.Reference, 20) COLLATE database_default AS IXDSC1,
			N'S' COLLATE database_default AS IXLNTY,
			CAST( 0 AS FLOAT) AS IXPRIC,
			CAST( 0 AS FLOAT) AS IXUNCS,
			CAST( 0 AS FLOAT) AS IXPCTK,
			N'' COLLATE database_default AS IXSHNO,
			N'' COLLATE database_default AS IXOMCU,
			N'' COLLATE database_default AS IXOBJ,
			N'' COLLATE database_default AS IXSUB,
			N'' COLLATE database_default AS IXBREV,
			N'' COLLATE database_default AS IXCMRV,
			N'' COLLATE database_default AS IXRVNO,
			CAST( 0 AS FLOAT) AS IXUUPG,
			N'' COLLATE database_default AS IXURCD,
			0 AS IXURDT,
			CAST( 0 AS FLOAT) AS IXURAT,
			N'' COLLATE database_default AS IXURRF,
			CAST( 0 AS FLOAT) AS IXURAB,
			@user COLLATE database_default AS IXUSER,
			@pid COLLATE database_default AS IXPID,
			@jobn COLLATE database_default AS IXJOBN,
			@jToday AS IXUPMJ,
			CAST( @tNow AS FLOAT) AS IXTDAY,
			N'' COLLATE database_default AS IXAING,
			0 AS IXSUCO,
			CAST( 0 AS FLOAT) AS IXSTRC,
			CAST( 0 AS FLOAT) AS IXENDC,
			N'' COLLATE database_default AS IXAPSC,
			CAST( (Sage.LineNumShort * 10) AS FLOAT) AS IXCPNB,
			N'' COLLATE database_default AS IXBSEQAN,
			N'1' COLLATE database_default AS IXBCHAR,
			N'' COLLATE database_default AS IXBOSTR
	from #BOMTemp as Sage
		join atmp.F4102 AS IB1 ON Sage.ParentNum collate database_default = IB1.IBLITM AND 
															   LTRIM(RTRIM(IB1.IBMCU)) = N'3SUW' collate database_default
		join atmp.F4102 AS IB2 ON Sage.ChildNum collate database_default = IB2.IBLITM AND 
															   LTRIM(RTRIM(IB2.IBMCU)) = N'3SUW' collate database_default
		left join atmp.F4101 AS IM2 ON Sage.ChildNum collate database_default = IM2.IMLITM
		order by IXKIT asc, IXCPNT asc
		


	drop table #BOMList
	drop table #BOMTemp
END
GO
