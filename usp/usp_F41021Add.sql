use SelectoJDE
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ****************************************************************************************
-- Create primary bin locations for all branch items created via SQL
--
-- HISTORY:
-- 09-Sep-2019 R.Lillback Created initial version
-- ****************************************************************************************
IF EXISTS(SELECT * FROM SYS.objects WHERE TYPE = 'P' AND name = N'usp_F41021Add')
	DROP PROCEDURE dbo.usp_F41021Add
GO

CREATE PROCEDURE dbo.usp_F41021Add 
AS
BEGIN
	SET NOCOUNT ON;
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

	truncate table atmp.F41021; -- Clear the table before loading data into it

	insert into atmp.F41021
	select 
		IBITM AS LIITM,
		IBMCU AS LIMCU,
		case (IBSTKT)
			when N'P' then (N'SUREC               ') 
			else (N'SUFG                ')
		end COLLATE DATABASE_DEFAULT AS LILOCN,
		(N'                              ') COLLATE DATABASE_DEFAULT AS LILOTN,
		(N'P') COLLATE DATABASE_DEFAULT AS LIPBIN,
		IBGLPT AS LIGLPT,
		(N' ') COLLATE DATABASE_DEFAULT AS LILOTS,
		0 AS LILRCJ,
		CAST(0 AS FLOAT) AS LIPQOH,
		CAST(0 AS FLOAT) AS LIPBCK,
		CAST(0 AS FLOAT) AS LIPREQ,
		CAST(0 AS FLOAT) AS LIQWBO,
		CAST(0 AS FLOAT) AS LIOT1P,
		CAST(0 AS FLOAT) AS LIOT2P,
		CAST(0 AS FLOAT) AS LIOT1A,
		CAST(0 AS FLOAT) AS LIHCOM,
		CAST(0 AS FLOAT) AS LIPCOM,
		CAST(0 AS FLOAT) AS LIFCOM,
		CAST(0 AS FLOAT) AS LIFUN1,
		CAST(0 AS FLOAT) AS LIQOWO,
		CAST(0 AS FLOAT) AS LIQTTR,
		CAST(0 AS FLOAT) AS LIQTIN,
		CAST(0 AS FLOAT) AS LIQONL,
		CAST(0 AS FLOAT) AS LIQTRI,
		CAST(0 AS FLOAT) AS LIQTRO,
		0 AS LINCDJ,
		CAST(0 AS FLOAT) AS LIQTY1,
		CAST(0 AS FLOAT) AS LIQTY2,
		CAST(0 AS FLOAT) AS LIURAB,
		N'' COLLATE DATABASE_DEFAULT AS LIURRF,
		CAST(0 AS FLOAT) AS LIURAT,
		N'' COLLATE DATABASE_DEFAULT AS LIURCD,
		@jobn COLLATE DATABASE_DEFAULT AS LIJOBN,
		@pid COLLATE DATABASE_DEFAULT AS LIPID,
		@jToday AS LIUPMJ,
		@user COLLATE DATABASE_DEFAULT AS LIUSER,
		@tNow AS LITDAY,
		0 AS LIURDT,
		CAST(0 AS FLOAT) AS LIQTO1,
		CAST(0 AS FLOAT) AS LIQTO2,
		CAST(0 AS FLOAT) AS LIHCMS,
		CAST(0 AS FLOAT) AS LIPJCM,
		CAST(0 AS FLOAT) AS LIPJDM,
		CAST(0 AS FLOAT) AS LISCMS,
		CAST(0 AS FLOAT) AS LISIBW,
		CAST(0 AS FLOAT) AS LISOBW,
		CAST(0 AS FLOAT) AS LISQOH,
		CAST(0 AS FLOAT) AS LISQWO,
		CAST(0 AS FLOAT) AS LISREQ,
		CAST(0 AS FLOAT) AS LISWHC,
		CAST(0 AS FLOAT) AS LISWSC,
		N'' COLLATE DATABASE_DEFAULT AS LICHDF,
		N'' COLLATE DATABASE_DEFAULT AS LIWPDF,
		N'' COLLATE DATABASE_DEFAULT AS LICFGSID
	from atmp.F4102
END
GO
