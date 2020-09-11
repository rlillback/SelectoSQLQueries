use SelectoJDE
go

-- ****************************************************************************************
-- Populate the customer email addresses
--
--
-- NOTES:
--
-- HISTORY:
--   09-Sep-2020 R.Lillback Created Initial Version
-- ****************************************************************************************

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF EXISTS(SELECT * FROM SYS.objects WHERE TYPE = 'P' AND name = N'usp_F0111_CustomerEmails')
	print('dropping procedure dbo.usp_F0111_CustomerEmails');
	DROP PROCEDURE dbo.usp_F0111_CustomerEmails
GO

print('creating procedure dbo.usp_F0111_CustomerEmails');
go

CREATE PROCEDURE dbo.usp_F0111_CustomerEmails
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
    declare @lineNo float;
    declare @nm nchar(40);
    declare @em1 nchar(40);
    declare @em2 nchar(40);
    declare @em3 nchar(40);
    declare @em4 nchar(40);
    declare @em5 nchar(40);
    declare @emx1 nchar(40);
    declare @emx2 nchar(40);
    declare @emx3 nchar(40);
    declare @emx4 nchar(40);
    declare @emx5 nchar(40);
    declare @emk1 nchar(40);
    declare @alky nchar(20);
    declare nameCursor scroll cursor for
		select alky, nm, em1, em2, em3, em4, em5, emx1, emx2, emx3, emx4, emx5, emk1 from dbo.ods_CustomerEmailsFlatFile
	open nameCursor;
	fetch first from nameCursor into @alky, @nm, @em1, @em2, @em3, @em4, @em5, @emx1, @emx2, @emx3, @emx4, @emx5, @emk1;
	
	while @@FETCH_STATUS = 0 begin		
		-- populate some required data
		set @who = (select aban8 from atmp.F0101 where abalky = @alky);

		-- Only populate the line if we got a record
		if (@who is not null) begin
			set @lineNo = (select (MAX(WWIDLN)) from atmp.F0111 where WWAN8 = @who); -- get the next line ID field

			-- Load the 1 email address
			if ((@em1 is not null) and ltrim(rtrim(@em1)) <> '') begin
				insert into atmp.F0111
					(WWAN8, WWIDLN, WWDSS5, WWMLNM, WWALPH, WWTYC, WWUSER, WWPID, WWUPMJ, WWJOBN, WWUPMT, WWDDATE, WWDMON, WWDYR, WWSYNCS, WWCAAD)
					values( @who, @lineNo+1, 0, @em1, @em1, N'1', @user, @pid, @jToday, @jobn, @tNow, 0, 0, 0, 0, 0 )
				set @lineNo = @lineNo+1;
			end
			-- Load the 2 email address
			if ((@em2 is not null) and ltrim(rtrim(@em2)) <> '') begin
				insert into atmp.F0111
					(WWAN8, WWIDLN, WWDSS5, WWMLNM, WWALPH, WWTYC, WWUSER, WWPID, WWUPMJ, WWJOBN, WWUPMT, WWDDATE, WWDMON, WWDYR, WWSYNCS, WWCAAD)
					values( @who, @lineNo+1, 0, @em2, @em2, N'2', @user, @pid, @jToday, @jobn, @tNow, 0, 0, 0, 0, 0 )
				set @lineNo = @lineNo+1;
			end
			-- Load the 3 email address
			if ((@em3 is not null) and ltrim(rtrim(@em3)) <> '') begin
				insert into atmp.F0111
					(WWAN8, WWIDLN, WWDSS5, WWMLNM, WWALPH, WWTYC, WWUSER, WWPID, WWUPMJ, WWJOBN, WWUPMT, WWDDATE, WWDMON, WWDYR, WWSYNCS, WWCAAD)
					values( @who, @lineNo+1, 0, @em3, @em3, N'3', @user, @pid, @jToday, @jobn, @tNow, 0, 0, 0, 0, 0 )
				set @lineNo = @lineNo+1;
			end
			-- Load the 4 email address
			if ((@em4 is not null) and ltrim(rtrim(@em4)) <> '') begin
				insert into atmp.F0111
					(WWAN8, WWIDLN, WWDSS5, WWMLNM, WWALPH, WWTYC, WWUSER, WWPID, WWUPMJ, WWJOBN, WWUPMT, WWDDATE, WWDMON, WWDYR, WWSYNCS, WWCAAD)
					values( @who, @lineNo+1, 0, @em4, @em4, N'4', @user, @pid, @jToday, @jobn, @tNow, 0, 0, 0, 0, 0 )
				set @lineNo = @lineNo+1;
			end
			-- Load the 5 email address
			if ((@em5 is not null) and ltrim(rtrim(@em5)) <> '') begin
				insert into atmp.F0111
					(WWAN8, WWIDLN, WWDSS5, WWMLNM, WWALPH, WWTYC, WWUSER, WWPID, WWUPMJ, WWJOBN, WWUPMT, WWDDATE, WWDMON, WWDYR, WWSYNCS, WWCAAD)
					values( @who, @lineNo+1, 0, @em5, @em5, N'5', @user, @pid, @jToday, @jobn, @tNow, 0, 0, 0, 0, 0 )
				set @lineNo = @lineNo+1;
			end
			-- Load the 1st x email address
			if ((@emx1 is not null) and ltrim(rtrim(@emx1)) <> '') begin
				insert into atmp.F0111
					(WWAN8, WWIDLN, WWDSS5, WWMLNM, WWALPH, WWTYC, WWUSER, WWPID, WWUPMJ, WWJOBN, WWUPMT, WWDDATE, WWDMON, WWDYR, WWSYNCS, WWCAAD)
					values( @who, @lineNo+1, 0, @emx1, @emx1, N'X', @user, @pid, @jToday, @jobn, @tNow, 0, 0, 0, 0, 0 )
				set @lineNo = @lineNo+1;
			end
			-- Load the 2nd x email address
			if ((@emx2 is not null) and ltrim(rtrim(@emx2)) <> '') begin
				insert into atmp.F0111
					(WWAN8, WWIDLN, WWDSS5, WWMLNM, WWALPH, WWTYC, WWUSER, WWPID, WWUPMJ, WWJOBN, WWUPMT, WWDDATE, WWDMON, WWDYR, WWSYNCS, WWCAAD)
					values( @who, @lineNo+1, 0, @emx2, @emx2, N'X', @user, @pid, @jToday, @jobn, @tNow, 0, 0, 0, 0, 0 )
				set @lineNo = @lineNo+1;
			end
			-- Load the 3rd x email address
			if ((@emx3 is not null) and ltrim(rtrim(@emx3)) <> '') begin
				insert into atmp.F0111
					(WWAN8, WWIDLN, WWDSS5, WWMLNM, WWALPH, WWTYC, WWUSER, WWPID, WWUPMJ, WWJOBN, WWUPMT, WWDDATE, WWDMON, WWDYR, WWSYNCS, WWCAAD)
					values( @who, @lineNo+1, 0, @emx3, @emx3, N'X', @user, @pid, @jToday, @jobn, @tNow, 0, 0, 0, 0, 0 )
				set @lineNo = @lineNo+1;
			end
			-- Load the 4th x email address
			if ((@emx4 is not null) and ltrim(rtrim(@emx4)) <> '') begin
				insert into atmp.F0111
					(WWAN8, WWIDLN, WWDSS5, WWMLNM, WWALPH, WWTYC, WWUSER, WWPID, WWUPMJ, WWJOBN, WWUPMT, WWDDATE, WWDMON, WWDYR, WWSYNCS, WWCAAD)
					values( @who, @lineNo+1, 0, @emx4, @emx4, N'X', @user, @pid, @jToday, @jobn, @tNow, 0, 0, 0, 0, 0 )
				set @lineNo = @lineNo+1;
			end
			-- Load the 5th x email address
			if ((@emx5 is not null) and ltrim(rtrim(@emx5)) <> '') begin
				insert into atmp.F0111
					(WWAN8, WWIDLN, WWDSS5, WWMLNM, WWALPH, WWTYC, WWUSER, WWPID, WWUPMJ, WWJOBN, WWUPMT, WWDDATE, WWDMON, WWDYR, WWSYNCS, WWCAAD)
					values( @who, @lineNo+1, 0, @emx5, @emx5, N'X', @user, @pid, @jToday, @jobn, @tNow, 0, 0, 0, 0, 0 )
				set @lineNo = @lineNo+1;
			end
			-- Load the key contact information
			if ((@emk1 is not null) and ltrim(rtrim(@emk1)) <> '') begin
				insert into atmp.F0111
					(WWAN8, WWIDLN, WWDSS5, WWMLNM, WWALPH, WWTYC, WWUSER, WWPID, WWUPMJ, WWJOBN, WWUPMT, WWDDATE, WWDMON, WWDYR, WWSYNCS, WWCAAD)
					values( @who, @lineNo+1, 0, @emk1, @emk1, N'K', @user, @pid, @jToday, @jobn, @tNow, 0, 0, 0, 0, 0 )
				set @lineNo = @lineNo+1;
			end
		end else begin
			insert into [dbo].[error_CustomerEmailLoad]
				values('Custom Error', 'Custom Error',cast((@alky + ' was not found in the address book F0101') as varchar(4000)),N'Error populating customer in dbo.usp_F0111_CustomerEmails')
		end

		-- fetch next record
		fetch next from nameCursor into @alky, @nm, @em1, @em2, @em3, @em4, @em5, @emx1, @emx2, @emx3, @emx4, @emx5, @emk1;
	end
	close nameCursor;
	deallocate nameCursor;                         
END

GO