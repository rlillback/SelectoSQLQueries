use SelectoJDE
go

-- ****************************************************************************************
-- Create vendor who's who records to populate WWALPH et al.  Without this the AB
-- program sets an alarm.
--
--
-- NOTES:
--
-- HISTORY:
--   11-Feb-2020 R.Lillback Created Initial Version
-- ****************************************************************************************

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF EXISTS(SELECT * FROM SYS.objects WHERE TYPE = 'P' AND name = N'usp_F0111_Vendor_Load')
	DROP PROCEDURE dbo.usp_F0111_Vendor_Load
GO

CREATE PROCEDURE dbo.usp_F0111_Vendor_Load
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

	declare @email nchar(40) = N'customerservice@selecto.com';
								
							
    declare @who float;
    declare @name nchar(40);
    declare whoCursor scroll cursor for
		select aban8 from atmp.F0101 where ABAT1 in (N'V3')
	open whoCursor;
	fetch first from whoCursor into @who;
	
	while @@FETCH_STATUS = 0 begin
		set @name = (select ABALPH from atmp.F0101 where ABAN8 = @who);
		-- Load the name record
		insert into atmp.F0111
		(WWAN8, WWIDLN, WWDSS5, WWMLNM, WWALPH, WWTYC, WWUSER, WWPID, WWUPMJ, WWJOBN, WWUPMT, WWDDATE, WWDMON, WWDYR, WWSYNCS, WWCAAD)
		values( @who, 0, 0, @name, @name, N'.', @user, @pid, @jToday, @jobn, @tNow, 0, 0, 0, 0, 0 )

		if ( 1 = 0 ) begin -- don't need this section for vendors, but we do for customers
			-- Load the A record
			insert into atmp.F0111
			(WWAN8, WWIDLN, WWDSS5, WWMLNM, WWALPH, WWTYC, WWUSER, WWPID, WWUPMJ, WWJOBN, WWUPMT, WWDDATE, WWDMON, WWDYR, WWSYNCS, WWCAAD)
			values( @who, 1, 0, @email, @email, N'A', @user, @pid, @jToday, @jobn, @tNow, 0, 0, 0, 0, 0 )

			-- Load the 1 record
			insert into atmp.F0111
			(WWAN8, WWIDLN, WWDSS5, WWMLNM, WWALPH, WWTYC, WWUSER, WWPID, WWUPMJ, WWJOBN, WWUPMT, WWDDATE, WWDMON, WWDYR, WWSYNCS, WWCAAD)
			values( @who, 2, 0, @email, @email, N'1', @user, @pid, @jToday, @jobn, @tNow, 0, 0, 0, 0, 0 )

			-- Load the 2 record
			insert into atmp.F0111
			(WWAN8, WWIDLN, WWDSS5, WWMLNM, WWALPH, WWTYC, WWUSER, WWPID, WWUPMJ, WWJOBN, WWUPMT, WWDDATE, WWDMON, WWDYR, WWSYNCS, WWCAAD)
			values( @who, 3, 0, @email, @email, N'2', @user, @pid, @jToday, @jobn, @tNow, 0, 0, 0, 0, 0 )

			-- Load the 3 record
			insert into atmp.F0111
			(WWAN8, WWIDLN, WWDSS5, WWMLNM, WWALPH, WWTYC, WWUSER, WWPID, WWUPMJ, WWJOBN, WWUPMT, WWDDATE, WWDMON, WWDYR, WWSYNCS, WWCAAD)
			values( @who, 4, 0, @email, @email, N'3', @user, @pid, @jToday, @jobn, @tNow, 0, 0, 0, 0, 0 )

			-- Load the 4 record
			insert into atmp.F0111
			(WWAN8, WWIDLN, WWDSS5, WWMLNM, WWALPH, WWTYC, WWUSER, WWPID, WWUPMJ, WWJOBN, WWUPMT, WWDDATE, WWDMON, WWDYR, WWSYNCS, WWCAAD)
			values( @who, 5, 0, @email, @email, N'4', @user, @pid, @jToday, @jobn, @tNow, 0, 0, 0, 0, 0 )

			-- Load the 5 record
			insert into atmp.F0111
			(WWAN8, WWIDLN, WWDSS5, WWMLNM, WWALPH, WWTYC, WWUSER, WWPID, WWUPMJ, WWJOBN, WWUPMT, WWDDATE, WWDMON, WWDYR, WWSYNCS, WWCAAD)
			values( @who, 6, 0, @email, @email, N'5', @user, @pid, @jToday, @jobn, @tNow, 0, 0, 0, 0, 0 )

			-- Load the 6 record
			insert into atmp.F0111
			(WWAN8, WWIDLN, WWDSS5, WWMLNM, WWALPH, WWTYC, WWUSER, WWPID, WWUPMJ, WWJOBN, WWUPMT, WWDDATE, WWDMON, WWDYR, WWSYNCS, WWCAAD)
			values( @who, 7, 0, @email, @email, N'6', @user, @pid, @jToday, @jobn, @tNow, 0, 0, 0, 0, 0 )

			-- Load the 7 record
			insert into atmp.F0111
			(WWAN8, WWIDLN, WWDSS5, WWMLNM, WWALPH, WWTYC, WWUSER, WWPID, WWUPMJ, WWJOBN, WWUPMT, WWDDATE, WWDMON, WWDYR, WWSYNCS, WWCAAD)
			values( @who, 8, 0, @email, @email, N'7', @user, @pid, @jToday, @jobn, @tNow, 0, 0, 0, 0, 0 )

			-- Load the 8 record
			insert into atmp.F0111
			(WWAN8, WWIDLN, WWDSS5, WWMLNM, WWALPH, WWTYC, WWUSER, WWPID, WWUPMJ, WWJOBN, WWUPMT, WWDDATE, WWDMON, WWDYR, WWSYNCS, WWCAAD)
			values( @who, 9, 0, @email, @email, N'8', @user, @pid, @jToday, @jobn, @tNow, 0, 0, 0, 0, 0 )

		end -- if

		-- fetch next record
		fetch next from whoCursor into @who;
	end
	close whoCursor;
	deallocate whoCursor;                         
END

GO


