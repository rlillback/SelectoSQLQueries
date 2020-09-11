use SelectoJDE
go

-- ****************************************************************************************
-- Populate the vendor's ACH email addresses (Type Code = H)
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

IF EXISTS(SELECT * FROM SYS.objects WHERE TYPE = 'P' AND name = N'usp_F0111_VendorACHemails')
	print('dropping procedure dbo.usp_F0111_VendorACHemails');
	DROP PROCEDURE dbo.usp_F0111_VendorACHemails
GO

print('creating procedure dbo.usp_F0111_VendorACHemails');
go

CREATE PROCEDURE dbo.usp_F0111_VendorACHemails
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
    declare @email nchar(40);
    declare @alky nchar(20);
    declare nameCursor scroll cursor for
		select alky, mlnm from dbo.ods_VendorACHemails
	open nameCursor;
	fetch first from nameCursor into @alky, @email;
	
	while @@FETCH_STATUS = 0 begin		
		-- populate some required data
		set @who = (select aban8 from atmp.F0101 where abalky = @alky);

		-- Only populate the line if we got a record
		if (@who is not null) begin
			set @lineNo = (select (MAX(WWIDLN) + 1) from atmp.F0111 where WWAN8 = @who); -- get the next line ID field

			-- Load the ACH email address
			insert into atmp.F0111
			(WWAN8, WWIDLN, WWDSS5, WWMLNM, WWALPH, WWTYC, WWUSER, WWPID, WWUPMJ, WWJOBN, WWUPMT, WWDDATE, WWDMON, WWDYR, WWSYNCS, WWCAAD)
			values( @who, @lineNo, 0, @email, @email, N'H', @user, @pid, @jToday, @jobn, @tNow, 0, 0, 0, 0, 0 )
		end else begin
			insert into [dbo].[error_CustomerEmailLoad]
				values('Custom Error', 'Custom Error',cast((@alky + ' was not found in the address book F0101') as varchar(4000)),N'Error populating vendor in dbo.usp_F0111_VendorACHemails')
		end

		-- fetch next record
		fetch next from nameCursor into @alky, @email;
	end
	close nameCursor;
	deallocate nameCursor;                         
END

GO