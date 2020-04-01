USE SelectoJDE
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF EXISTS(SELECT * FROM SYS.objects WHERE TYPE = 'P' AND name = N'usp_F0150_Load')
	DROP PROCEDURE dbo.usp_F0150_Load
GO

CREATE PROCEDURE [dbo].[usp_F0150_Load] 
AS
BEGIN
-- ****************************************************************************************
-- Create customer parent child relations.
--
--
-- HISTORY:
--   05-Mar-2019 R.Lillback Created initial version
-- ****************************************************************************************
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
	                               
	insert into atmp.F0150
		(MAOSTP, MAPA8, MAAN8, MADSS7, MABEFD, MAEEFD, MARMK, MAUSER, MAUPMJ, MAPID, MAJOBN, MAUPMT, MASYNCS)
	select 
		N'', ABAN85, ABAN8, 0, 0, 0, N'', @user, @jToday, @pid, @jobn, @tNow, 0 
	from 
		atmp.F0101
	where ABAT1 in (N'S3')
		
END

GO


