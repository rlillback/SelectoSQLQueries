use SelectoJDE
go

-- ****************************************************************************************
-- Create ShipTo who's who records to populate WWALPH et al.  Without this the AB
-- program sets an alarm.
--
--
-- NOTES:
--
-- HISTORY:
--   19-Feb-2020 R.Lillback Created Initial Version
-- ****************************************************************************************

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF EXISTS(SELECT * FROM SYS.objects WHERE TYPE = 'P' AND name = N'usp_F0111_ShipTo_Load')
	DROP PROCEDURE dbo.usp_F0111_ShipTo_Load
GO

CREATE PROCEDURE dbo.usp_F0111_ShipTo_Load
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
								
							
    declare @who float;
    declare @name nchar(40);
    declare whoCursor scroll cursor for
		select aban8 from atmp.F0101 where ABAT1 in (N'S3')
	open whoCursor;
	fetch first from whoCursor into @who;
	
	while @@FETCH_STATUS = 0 begin
		set @name = (select ABALPH from atmp.F0101 where ABAN8 = @who);
		
		-- Load the name record
		insert into atmp.F0111
		(WWAN8, WWIDLN, WWDSS5, WWMLNM, WWALPH, WWTYC, WWUSER, WWPID, WWUPMJ, WWJOBN, WWUPMT, WWDDATE, WWDMON, WWDYR, WWSYNCS, WWCAAD)
		values( @who, 0, 0, @name, @name, N'.', @user, @pid, @jToday, @jobn, @tNow, 0, 0, 0, 0, 0 )

		-- fetch next record
		fetch next from whoCursor into @who;
	end
	close whoCursor;
	deallocate whoCursor;                         
END

GO


