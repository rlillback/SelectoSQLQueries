use SelectoJDE
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-----------------------------------------------------------------------------------------
--
-- Update JDE_DEVELOPMENT with data entered by Laura, Ray, Dale, and Nancy
--
-- History:
-- 05-Apr-2020 R.Lillback Created initial version
-- 18-Apr-2020 R.Lillback Added F0012
-- 18-Apr-2020 R.Lillback Added F41001
-- 01-May-2020 R.Lillback Added containers F46091 per my testing
-- 24-Jul-2020 R.Lillback Updated per Dale
-----------------------------------------------------------------------------------------
IF OBJECT_ID('dbo.usp_SuwaneeConstants') is not null begin
	print 'Dropping procedure dbo.usp_SuwaneeConstants';
	drop procedure dbo.usp_SuwaneeConstants
end
go

print 'Creating procedure dbo.usp_SuwaneeConstants';
go
CREATE PROCEDURE dbo.usp_SuwaneeConstants
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- In this case, I may have added UDC codes in other scripts
	-- Make sure you don't try and double write them into the system
	insert into N0E9SQL01.JDE_DEVELOPMENT.TESTCTL.F0005
		select A.* 
		from atmp.F0005_BACKUP as A
		left join N0E9SQL01.JDE_DEVELOPMENT.TESTCTL.F0005 as B ON
			A.DRSY = B.DRSY COLLATE database_default AND
			A.DRRT = B.DRRT COLLATE database_default AND
			A.DRKY = B.DRKY COLLATE database_default
		where B.DRSY is null

	insert into N0E9SQL01.JDE_DEVELOPMENT.TESTDTA.F0006
		select A.* 
		from atmp.F0006_BACKUP AS A
		left join N0E9SQL01.JDE_DEVELOPMENT.TESTDTA.F0006 AS B ON
			A.MCMCU = B.MCMCU COLLATE database_default
		WHERE B.MCMCU IS NULL

	insert into N0E9SQL01.JDE_DEVELOPMENT.TESTDTA.F0010
		select A.* 
		from atmp.F0010_BACKUP AS A
		left join N0E9SQL01.JDE_DEVELOPMENT.TESTDTA.F0010 AS B ON
			A.CCCO = B.CCCO COLLATE database_default
		WHERE B.CCCO IS NULL

	-- The GMAIDs were set in another procedure; so, we only
	-- need to update the next number associated with them
	insert into N0E9SQL01.JDE_DEVELOPMENT.TESTDTA.F0901
		select A.* 
		from atmp.F0901_BACKUP AS A
		left join N0E9SQL01.JDE_DEVELOPMENT.TESTDTA.F0901 AS B ON
			A.GMCO = B.GMCO collate database_default AND
			A.GMMCU = B.GMMCU collate database_default  AND
			A.GMOBJ = B.GMOBJ collate database_default AND
			A.GMSUB = B.GMSUB collate database_default
		WHERE B.GMCO IS NULL
	update N0E9SQL01.JDE_DEVELOPMENT.TESTCTL.F0002
		set NNN001 = (select (max(GMAID) + 1) from atmp.F0901_BACKUP)
		where LTRIM(RTRIM(NNSY)) = N'09'

	insert into N0E9SQL01.JDE_DEVELOPMENT.TESTDTA.F4095
		select A.* 
		from atmp.F4095_BACKUP AS A
		left join N0E9SQL01.JDE_DEVELOPMENT.TESTDTA.F4095 AS B ON
			A.[MLANUM] = B.MLANUM AND
			A.[MLCO] = B.MLCO COLLATE database_default AND
			A.[MLDCTO] = B.MLDCTO COLLATE database_default AND
			A.[MLDCT]  = B.MLDCT COLLATE database_default AND
			A.[MLGLPT] = B.MLGLPT COLLATE database_default AND
			A.MLCOST = B.MLCOST COLLATE database_default
		where B.MLANUM is null

	insert into N0E9SQL01.JDE_DEVELOPMENT.TESTDTA.F4100
		select A.* 
		from atmp.F4100_BACKUP AS A
		left join N0E9SQL01.JDE_DEVELOPMENT.TESTDTA.F4100 AS B ON
			A.LMMCU = B.LMMCU COLLATE database_default AND
			A.LMLOCN = B.LMLOCN COLLATE database_default
		WHERE B.LMMCU IS NULL


	insert into N0E9SQL01.JDE_DEVELOPMENT.TESTDTA.F49002
		select A.* 
		from atmp.F49002_BACKUP AS A
		left join N0E9SQL01.JDE_DEVELOPMENT.TESTDTA.F49002 AS B ON
			A.TXNMCU = B.TXNMCU COLLATE database_default
		WHERE B.TXNMCU IS NULL

	insert into N0E9SQL01.JDE_DEVELOPMENT.TESTDTA.F4070
		select A.* 
		from atmp.F4070_BACKUP AS A
		left join N0E9SQL01.JDE_DEVELOPMENT.TESTDTA.F4070 AS B ON
			A.[SNASN] = B.SNASN COLLATE database_default AND
			A.[SNOSEQ] = B.SNOSEQ AND
			A.[SNANPS] = B.SNANPS
		WHERE B.SNASN IS NULL

	-- The next number for RTRTN was set in another procedure.
	-- So, update the next number, since that procedure didn't
	insert into N0E9SQL01.JDE_DEVELOPMENT.TESTDTA.F4950
		select A.* 
		from atmp.F4950_BACKUP AS A
		left join N0E9SQL01.JDE_DEVELOPMENT.TESTDTA.F4950 AS B ON
			A.RTORGN = B.RTORGN AND
			A.RTCARS = B.RTCARS AND
			A.RTMCU = B.RTMCU COLLATE database_default AND
			A.RTMOT = B.RTMOT COLLATE database_default
	update N0E9SQL01.JDE_DEVELOPMENT.TESTCTL.F0002
		set NNN008 = (select (max(RTRTN) + 1) from atmp.F4950_BACKUP)
		where LTRIM(RTRIM(NNSY)) = N'49'

	-- Update the next numbers based on production datavalues
	declare @itemIdShift float = (select min(IKIGID) from atmp.F40941_BACKUP);
	set @itemIdShift = (select (max(IKIGID) - @itemIdShift + 1) from N0E9SQL01.JDE_DEVELOPMENT.TESTDTA.F40941);
	update atmp.F4072_BACKUP
		set ADIGID = (ADIGID + @itemIdShift)
	update atmp.F40941_BACKUP
		set IKIGID = (IKIGID + @itemIdShift)
	insert into N0E9SQL01.JDE_DEVELOPMENT.TESTDTA.F40941
		select A.* 
		from atmp.F40941_BACKUP AS A
		left join N0E9SQL01.JDE_DEVELOPMENT.TESTDTA.F40941 AS B ON
			A.IKPRGR = B.IKPRGR COLLATE database_default
		WHERE B.IKPRGR IS NULL
	update N0E9SQL01.JDE_DEVELOPMENT.TESTCTL.F0002
		set NNN003 = (SELECT (MAX(IKIGID) + 1) FROM atmp.F40941_BACKUP)
		where ltrim(rtrim(NNSY)) = N'45'

	declare @custIdShift float = (select min(CKCGID) from atmp.F40942_BACKUP);
	set @custIdShift = (select (max(CKCGID) - @custIdShift + 1) from N0E9SQL01.JDE_DEVELOPMENT.TESTDTA.F40942);
	update atmp.F4072_BACKUP
		set ADCGID = (ADCGID + @custIdShift)
	update atmp.F40942_BACKUP
		set CKCGID = (CKCGID + @custIdShift)
	insert into N0E9SQL01.JDE_DEVELOPMENT.TESTDTA.F40942
		select A.* 
		from atmp.F40942_BACKUP AS A
		left join N0E9SQL01.JDE_DEVELOPMENT.TESTDTA.F40942 AS B ON 
			A.CKCPGP = B.CKCPGP COLLATE database_default
		WHERE B.CKCPGP IS NULL
	update N0E9SQL01.JDE_DEVELOPMENT.TESTCTL.F0002
		set NNN002 = (SELECT (MAX(CKCGID) + 1) FROM atmp.F40942_BACKUP)
		where ltrim(rtrim(NNSY)) = N'45'

	declare @maxrule FLOAT = (select MAX(ADATID) from atmp.F4072);
	update
		t
	set
		t.ADATID = t.newATID
	from (
		select ADATID, @maxrule + (ROW_NUMBER() OVER (ORDER BY [ADAST])) as newATID
		from atmp.F4072_BACKUP
	) as t
	insert into N0E9SQL01.JDE_DEVELOPMENT.TESTDTA.F4072
		select * from atmp.F4072_BACKUP
	update N0E9SQL01.JDE_DEVELOPMENT.TESTCTL.F0002
		set NNN006 = (SELECT (MAX(ADATID) + 1) FROM atmp.F4072_BACKUP)
		where ltrim(rtrim(NNSY)) = N'40'

	insert into N0E9SQL01.JDE_DEVELOPMENT.TESTDTA.F0012
			select * from atmp.F0012_BACKUP

	insert into N0E9SQL01.JDE_DEVELOPMENT.TESTDTA.F41001
			select * from atmp.F41001_BACKUP

	insert into N0E9SQL01.JDE_DEVELOPMENT.TESTDTA.F46091
			select * from atmp.F46091_BACKUP

	insert into N0E9SQL01.JDE_DEVELOPMENT.TESTDTA.F0007
			select * from atmp.F0007_BACKUP

	insert into N0E9SQL01.JDE_DEVELOPMENT.TESTDTA.F3009
			select * from atmp.F3009_BACKUP

	insert into N0E9SQL01.JDE_DEVELOPMENT.TESTDTA.F30006
			select * from atmp.F30006_BACKUP

end
go