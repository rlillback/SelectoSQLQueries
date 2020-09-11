USE SelectoJDE
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ****************************************************************************************
-- Import purchased cost data from Sage directly into JDE's cost table
-- Populate the 07 and 08 costs for the 3SUW branch plant. Note: This must be
-- done *after* running the script to create the item's primary location.
-- The cost is calculated from the Last-In cost in the EVO data.
--
-- HISTORY:
-- 09-Sep-2019 R.Lillback Created initial version
-- 27-Aug-2020 R.Lillback Updated purchasing cost to populate only COCSPO not COCSIN
-- ****************************************************************************************
IF EXISTS(SELECT * FROM SYS.objects WHERE TYPE = 'P' AND name = N'usp_F4105Add')
	DROP PROCEDURE dbo.usp_F4105Add
GO

CREATE PROCEDURE dbo.usp_F4105Add 
AS
BEGIN
	SET NOCOUNT ON;

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
	
	truncate table atmp.F4105; -- Clear the table before loading data into it

	insert into atmp.F4105 -- the 07 = Standard cost
	select
		IBITM AS COITM,
		IBLITM AS COLITM,
		IBAITM AS COAITM,
		IBMCU AS COMCU,
		N'' AS COLOCN,
		N'' AS COLOTN,
		N'' AS COLOTG,
		N'07' AS COLEDG,
		cast((StandardUnitCost * 10000) as float) AS COUNCS, 
		N'' AS COCSPO,
		CASE (StandardUnitCost)
			WHEN 0 THEN N'' 
			ELSE N'I'  
		END AS COCSIN, -- Set this as the inventory costing method if cost!=0
		N'' AS COURCD,
		0 AS COURDT,
		CAST(0 AS FLOAT) AS COURAT,
		CAST(0 AS FLOAT) AS COURAB,
		N'' AS COURRF,
		@user  AS COUSER,
		@pid  AS COPID,
		@jobn  AS COJOBN,
		@jToday AS COUPMJ,
		@tNow AS COTDAY,
		N'' AS COCCFL,
		CAST(0 AS FLOAT) AS COCRCS,
		CAST(0 AS FLOAT) AS COOSTC,
		CAST(0 AS FLOAT) AS COSTOC
	from atmp.F4102
	join dbo.ods_CI_Item on IBLITM = ItemCode


	-- Reset the audit trail
	set @user = N'RLILLBACK';
	set @pid  = N'SQLLD';
	set @jobn = N'SQLLD';
	set @jToday = dbo.fn_DateTimeToJulian(GETDATE()); -- Julian Date Today
	set @tNow  = CONVERT (
								   float,
								   datepart(hh,getdate())*10000 + 
								   datepart(mi, getdate())*100 +
								   datepart(ss, getdate())
								   ); -- Time now as held by JDE
	                                                  
	insert into atmp.F4105 -- the 08 = Purchased cost
	select
		IBITM AS COITM,
		IBLITM AS COLITM,
		IBAITM AS COAITM,
		IBMCU AS COMCU,
		N'' AS COLOCN,
		N'' AS COLOTN,
		N'' AS COLOTG,
		N'08' AS COLEDG,
		cast((StandardUnitCost * 10000) as float) AS COUNCS, 
		CASE (StandardUnitCost)
			WHEN 0 THEN N'' 
			ELSE N'P'  
		END AS COCSPO, -- Set this as the purchasing costing method if cost!=0
		N'' AS COCSIN,
		N'' AS COURCD,
		0 AS COURDT,
		CAST(0 AS FLOAT) AS COURAT,
		CAST(0 AS FLOAT) AS COURAB,
		N'' AS COURRF,
		@user  AS COUSER,
		@pid  AS COPID,
		@jobn  AS COJOBN,
		@jToday AS COUPMJ,
		@tNow AS COTDAY,
		N'' AS COCCFL,
		CAST(0 AS FLOAT) AS COCRCS,
		CAST(0 AS FLOAT) AS COOSTC,
		CAST(0 AS FLOAT) AS COSTOC
	from atmp.F4102
	join dbo.ods_CI_Item on IBLITM = ItemCode
	where
		IBSTKT = N'P'


	----------------------------------------------------------------------------------------------
	-- ######################################################################################## --
	---------------------------------------------------------------------------------------------- 
	-- Now do the same thing for those item conflicts that we had to add a -SU to the end of the PN

	insert into atmp.F4105 -- the 07 = Standard cost
	select
		IBITM AS COITM,
		IBLITM AS COLITM,
		IBAITM AS COAITM,
		IBMCU AS COMCU,
		N'' AS COLOCN,
		N'' AS COLOTN,
		N'' AS COLOTG,
		N'07' AS COLEDG,
		cast((StandardUnitCost * 10000) as float) AS COUNCS, 
		N'' AS COCSPO,
		CASE (StandardUnitCost)
			WHEN 0 THEN N'' 
			ELSE N'I'  
		END AS COCSIN, -- Set this as the inventory costing method if cost!=0
		N'' AS COURCD,
		0 AS COURDT,
		CAST(0 AS FLOAT) AS COURAT,
		CAST(0 AS FLOAT) AS COURAB,
		N'' AS COURRF,
		@user  AS COUSER,
		@pid  AS COPID,
		@jobn  AS COJOBN,
		@jToday AS COUPMJ,
		@tNow AS COTDAY,
		N'' AS COCCFL,
		CAST(0 AS FLOAT) AS COCRCS,
		CAST(0 AS FLOAT) AS COOSTC,
		CAST(0 AS FLOAT) AS COSTOC
	from atmp.F4102
	join dbo.ods_CI_Item on replace(IBLITM,N'-SU',N'') = ItemCode
	where right(ltrim(rtrim(iblitm)),3) = N'-SU'


	-- Reset the audit trail
	set @user = N'RLILLBACK';
	set @pid  = N'SQLLD';
	set @jobn = N'SQLLD';
	set @jToday = dbo.fn_DateTimeToJulian(GETDATE()); -- Julian Date Today
	set @tNow  = CONVERT (
								   float,
								   datepart(hh,getdate())*10000 + 
								   datepart(mi, getdate())*100 +
								   datepart(ss, getdate())
								   ); -- Time now as held by JDE
	                                                  
	insert into atmp.F4105 -- the 08 = Purchased cost
	select
		IBITM AS COITM,
		IBLITM AS COLITM,
		IBAITM AS COAITM,
		IBMCU AS COMCU,
		N'' AS COLOCN,
		N'' AS COLOTN,
		N'' AS COLOTG,
		N'08' AS COLEDG,
		cast((StandardUnitCost * 10000) as float) AS COUNCS, 
		CASE (StandardUnitCost)
			WHEN 0 THEN N'' 
			ELSE N'P'  
		END AS COCSPO, -- Set this as the purchasing costing method if cost!=0
		N'' AS COCSIN,
		N'' AS COURCD,
		0 AS COURDT,
		CAST(0 AS FLOAT) AS COURAT,
		CAST(0 AS FLOAT) AS COURAB,
		N'' AS COURRF,
		@user  AS COUSER,
		@pid  AS COPID,
		@jobn  AS COJOBN,
		@jToday AS COUPMJ,
		@tNow AS COTDAY,
		N'' AS COCCFL,
		CAST(0 AS FLOAT) AS COCRCS,
		CAST(0 AS FLOAT) AS COOSTC,
		CAST(0 AS FLOAT) AS COSTOC
	from atmp.F4102
	join dbo.ods_CI_Item on replace(IBLITM,N'-SU',N'') = ItemCode
	where right(ltrim(rtrim(iblitm)),3) = N'-SU' and IBSTKT = N'P'

END
GO