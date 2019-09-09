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
		CAST((SuggestedRetailPrice * 10000) AS float) AS BPUPRC,
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
		CAST((SuggestedRetailPrice * 10000) AS float) AS BPUPRC,
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

END
GO