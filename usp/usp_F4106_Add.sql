use SelectoJDE
go


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ****************************************************************************************
-- Import base price data from Sage directly into JDE's pricing table
--
-- HISTORY:
-- 09-Sep-2019 R.Lillback Created intital version
-- 28-Apr-2020 R.Lillback Changed price pull to use StandardUnitPrice instead of Retail 
-- 28-Apr-2020 R.Lillback Added the importing of item prices where 1A records existed
-- ****************************************************************************************
IF EXISTS(SELECT * FROM SYS.objects WHERE TYPE = 'P' AND name = N'usp_F4106Add')
	DROP PROCEDURE dbo.usp_F4106Add
GO

CREATE PROCEDURE dbo.usp_F4106Add 
AS
BEGIN
	SET NOCOUNT ON;
	
	-- Next, set up the audit trail
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
	
	truncate table atmp.F4106; -- Clear the table before loading data into it

	-- Base case, we added new part numbers
	insert into atmp.F4106
	select
		IBITM AS BPITM,
		IBLITM AS BPLITM,
		IBAITM AS BPAITM,
		IBMCU AS BPMCU,
		N'' AS BPLOCN,
		N'' AS BPLOTN,
		CAST(0 AS float) AS BPAN8,
		CAST(0 AS float) AS BPIGID,
		CAST(0 AS float) AS BPCGID,
		N'' AS BPLOTG,
		CAST(0 AS float) AS BPFRMP,
		N'USD' AS BPCRCD,
		IMUOM1 AS BPUOM,
		119001 AS BPEFTJ,
		140365 AS BPEXDJ,
		CAST((StandardUnitPrice * 10000) AS float) AS BPUPRC,
		CAST(0 AS float) AS BPACRD,
		N'' AS BPBSCD,
		N'' AS BPLEDG,
		CAST(0 AS float) AS BPFVTR,
		N'' AS BPFRMN,
		N'' AS BPURCD,
		0 AS BPURDT,
		CAST(0 AS float) AS BPURAT,
		CAST(0 AS float) AS BPURAB,
		N'' AS BPURRF,
		N'' AS BPAPRS,
		@user AS BPUSER,
		@pid AS BPPID,
		@jobn AS BPJOBN,
		@jToday AS BPUPMJ,
		@tNow AS BPTDAY
	from atmp.F4102
		inner join atmp.F4101 on IBITM = IMITM
		inner join dbo.ods_CI_Item on IMLITM = ItemCode
	where 
		right(ltrim(rtrim(iblitm)),3) != N'-SU' -- don't grab any part numbers for which we added a suffix

	-- Base case, we added new part numbers
	insert into atmp.F4106
	select
		IBITM AS BPITM,
		IBLITM AS BPLITM,
		IBAITM AS BPAITM,
		IBMCU AS BPMCU,
		N'' AS BPLOCN,
		N'' AS BPLOTN,
		CAST(0 AS float) AS BPAN8,
		CAST(0 AS float) AS BPIGID,
		CAST(0 AS float) AS BPCGID,
		N'' AS BPLOTG,
		CAST(0 AS float) AS BPFRMP,
		N'USD' AS BPCRCD,
		IMUOM1 AS BPUOM,
		119001 AS BPEFTJ,
		140365 AS BPEXDJ,
		CAST((StandardUnitPrice * 10000) AS float) AS BPUPRC,
		CAST(0 AS float) AS BPACRD,
		N'' AS BPBSCD,
		N'' AS BPLEDG,
		CAST(0 AS float) AS BPFVTR,
		N'' AS BPFRMN,
		N'' AS BPURCD,
		0 AS BPURDT,
		CAST(0 AS float) AS BPURAT,
		CAST(0 AS float) AS BPURAB,
		N'' AS BPURRF,
		N'' AS BPAPRS,
		@user AS BPUSER,
		@pid AS BPPID,
		@jobn AS BPJOBN,
		@jToday AS BPUPMJ,
		@tNow AS BPTDAY
	from atmp.F4102
		inner join atmp.F4101 on IBITM = IMITM
		inner join dbo.ods_CI_Item on replace(iblitm,N'-SU',N'') = ItemCode
	where 
		right(ltrim(rtrim(iblitm)),3) = N'-SU' -- Only grab those items for which we added a suffix

	-- Corner case where the item was already in 1A & had an item master record
	insert into atmp.F4106
	select
		IBITM AS BPITM,
		IBLITM AS BPLITM,
		IBAITM AS BPAITM,
		IBMCU AS BPMCU,
		N'' AS BPLOCN,
		N'' AS BPLOTN,
		CAST(0 AS float) AS BPAN8,
		CAST(0 AS float) AS BPIGID,
		CAST(0 AS float) AS BPCGID,
		N'' AS BPLOTG,
		CAST(0 AS float) AS BPFRMP,
		N'USD' AS BPCRCD,
		IMUOM1 AS BPUOM,
		119001 AS BPEFTJ,
		140365 AS BPEXDJ,
		CAST((StandardUnitPrice * 10000) AS float) AS BPUPRC,
		CAST(0 AS float) AS BPACRD,
		N'' AS BPBSCD,
		N'' AS BPLEDG,
		CAST(0 AS float) AS BPFVTR,
		N'' AS BPFRMN,
		N'' AS BPURCD,
		0 AS BPURDT,
		CAST(0 AS float) AS BPURAT,
		CAST(0 AS float) AS BPURAB,
		N'' AS BPURRF,
		N'' AS BPAPRS,
		@user AS BPUSER,
		@pid AS BPPID,
		@jobn AS BPJOBN,
		@jToday AS BPUPMJ,
		@tNow AS BPTDAY
	from atmp.ItemConflicts 
		inner join atmp.F4102 on PartNumber = IBLITM
		inner join N0E9SQL01.JDE_DEVELOPMENT.TESTDTA.F4101 on PartNumber = IMLITM collate database_default
		inner join dbo.ods_CI_Item on PartNumber = ItemCode
	where 
		ActionKey = 1

END
GO