use SelectoJDE
go

-- ****************************************************************************************
-- Populate the vendor's lead times into F4102 & update the message display fence
--
--
-- NOTES:
--
-- HISTORY:
--   11-Sep-2020 R.Lillback Created Initial Version
-- ****************************************************************************************

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF EXISTS(SELECT * FROM SYS.objects WHERE TYPE = 'P' AND name = N'usp_F4102_VendorLeadTimes') begin
	print('dropping procedure dbo.usp_F4102_VendorLeadTimes');
	DROP PROCEDURE dbo.usp_F4102_VendorLeadTimes
end
GO

print('creating procedure dbo.usp_F4102_VendorLeadTimes');
go

CREATE PROCEDURE dbo.usp_F4102_VendorLeadTimes
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
							
    declare @itm float;
    declare @litm nchar(25);
    declare @leadtime float;
    declare itmCursor scroll cursor for
		select litm, LeadTime from dbo.ods_VendorLeadTimes
	open itmCursor;
	fetch first from itmCursor into @litm, @leadtime;
	
	while @@FETCH_STATUS = 0 begin		
		-- populate some required data
		set @itm = (select ibitm from atmp.F4102 where iblitm = @litm and ltrim(ibmcu) = N'3SUW');

		-- Only populate the line if we got a record
		if (@itm is not null) begin
			-- Update the message time fence and lead time fields
			update atmp.F4102
				set ibmtf3 = @leadtime + 14,
				    ibltlv = @LeadTime
			where ltrim(ibmcu) = N'3SUW' and
			      ibitm = @itm
		end else begin
			insert into [dbo].[error_CustomerEmailLoad]
				values('Custom Item Error', 'Custom Item Error',cast((@litm + ' was not found in the branch plant 3SUW') as varchar(4000)),N'Error updating lead time in dbo.usp_F4102_VendorLeadTimes')
		end

		-- fetch next record
		fetch next from itmCursor into @litm, @leadtime;
	end
	close itmCursor;
	deallocate itmCursor;                         
END

GO