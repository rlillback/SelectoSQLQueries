USE SelectoJDE
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF EXISTS(SELECT * FROM SYS.objects WHERE TYPE = 'P' AND name = N'usp_DeleteProdFromBackups')
	DROP PROCEDURE dbo.usp_DeleteProdFromBackups
GO

CREATE PROCEDURE [dbo].[usp_DeleteProdFromBackups] 
AS
BEGIN
-- ****************************************************************************************
-- Subtract all of the production data from the atmp BACKUP files & adjust any next
-- numbers, if required.
--
--
-- HISTORY:
--   05-Apr-2020 R.Lillback Created initial version
--	 08-Apr-2020 R.Lillback Added F30006 per Dale
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

	delete 
		from atmp.F0006_BACKUP
		where MCMCU in (select MCMCU collate database_default from N0E9SQL01.JDE_PRODUCTION.PRODDTA.F0006)

	delete
		from atmp.F0010_BACKUP
		where CCCO in (select CCCO collate database_default from N0E9SQL01.JDE_PRODUCTION.PRODDTA.F0010)

	delete atmp.F0901_BACKUP
		from atmp.F0901_BACKUP AS A
		join N0E9SQL01.JDE_PRODUCTION.PRODDTA.F0901 AS B ON
				A.GMCO = B.GMCO collate database_default AND
				A.GMMCU = B.GMMCU collate database_default  AND
				A.GMOBJ = B.GMOBJ collate database_default AND
				A.GMSUB = B.GMSUB collate database_default 

	declare @nn FLOAT = (select NNN001 from N0E9SQL01.JDE_PRODUCTION.PRODCTL.F0002 WHERE LTRIM(RTRIM(NNSY)) = N'09');
	update
		t
	set
		t.GMAID = t.newGMAID
	from (
		select GMAID, @nn + (ROW_NUMBER() OVER (ORDER BY [GMAID])) as newGMAID
		from atmp.F0901_BACKUP
	) as t

	delete atmp.F4095_BACKUP
		from atmp.F4095_BACKUP as A
		join N0E9SQL01.JDE_PRODUCTION.PRODDTA.F4095 as B ON 
			A.MLANUM = B.MLANUM AND
			A.MLCO = B.MLCO COLLATE database_default AND 
			A.MLDCTO = B.MLDCTO COLLATE database_default AND
			A.MLDCT = B.MLDCT COLLATE database_default AND
			A.MLGLPT = B.MLGLPT COLLATE database_default AND
			A.MLCOST = B.MLCOST COLLATE database_default

	delete atmp.F4100_BACKUP
		from atmp.F4100_BACKUP AS A
		join N0E9SQL01.JDE_PRODUCTION.PRODDTA.F4100 AS B ON 
			A.LMMCU = B.LMMCU COLLATE database_default AND
			A.LMLOCN = B.LMLOCN COLLATE database_default

	delete atmp.F49002_BACKUP
		from atmp.F49002_BACKUP AS A
		join N0E9SQL01.JDE_PRODUCTION.PRODDTA.F49002 AS B ON
			A.TXNMCU = B.TXNMCU COLLATE database_default

	delete atmp.F4950_BACKUP
		from atmp.F4950_BACKUP AS A
		join N0E9SQL01.JDE_PRODUCTION.PRODDTA.F4950 AS B ON
			A.RTORGN = B.RTORGN AND
			A.RTCARS = B.RTCARS AND
			A.RTMCU = B.RTMCU COLLATE database_default AND
			A.RTMOT = B.RTMOT COLLATE database_default

	SET @nn = (select NNN001 from N0E9SQL01.JDE_PRODUCTION.PRODCTL.F0002 WHERE LTRIM(RTRIM(NNSY)) = N'49');
	update
		t
	set
		t.RTRTN = t.newRTRTN
	from (
		select RTRTN, @nn + (ROW_NUMBER() OVER (ORDER BY [RTRTN])) as newRTRTN
		from atmp.F4950_BACKUP
	) as t

	delete atmp.F0005_BACKUP
		from atmp.F0005_BACKUP AS A
		join N0E9SQL01.JDE_PRODUCTION.PRODCTL.F0005 AS B ON
			A.DRSY = B.DRSY COLLATE database_default AND
			A.DRRT = B.DRRT COLLATE database_default AND
			A.DRKY = B.DRKY COLLATE database_default

	delete atmp.F40941_BACKUP
		from atmp.F40941_BACKUP AS A
		join N0E9SQL01.JDE_PRODUCTION.PRODDTA.F40941 AS B ON
			A.IKPRGR = B.IKPRGR COLLATE database_default

	delete atmp.F40942_BACKUP
		from atmp.F40942_BACKUP AS A
		join N0E9SQL01.JDE_PRODUCTION.PRODDTA.F40942 AS B ON
			A.CKCPGP = B.CKCPGP COLLATE database_default

	delete atmp.F4072_BACKUP
		from atmp.F4072_BACKUP AS A
		join N0E9SQL01.JDE_PRODUCTION.PRODDTA.F4072 AS B ON 
			a.[ADITM] = b.aditm and
			a.[ADAST] = b.adast collate database_default and
			a.[ADAN8] = b.adan8 and
			a.[ADIGID] = b.adigid and
			a.[ADCGID] = b.adcgid and
			a.[ADOGID] = b.adogid and
			a.[ADCRCD] = b.adcrcd collate database_default and
			a.[ADUOM] = b.aduom collate database_default and
			a.[ADMNQ] = b.admnq and
			a.[ADEXDJ] = b.adexdj

	delete from atmp.F4070_BACKUP
		from atmp.F4070_BACKUP AS A
		join N0E9SQL01.JDE_PRODUCTION.PRODDTA.F4070 AS B ON
			A.SNASN = B.SNASN COLLATE database_default AND
			A.SNOSEQ = B.SNOSEQ AND
			A.SNANPS = B.SNANPS

	-- ALSO, we should delete any contract pricing records in atmp.F4072_BACKUP
	-- those are populated from atmp.F4072
	delete atmp.F4072_BACKUP
		where ADITM != 0

	delete atmp.F30006_BACKUP
		from atmp.F30006_BACKUP as A
		join N0E9SQL01.JDE_PRODUCTION.PRODDTA.F30006 AS B ON
			A.IWMCU = B.IWMCU COLLATE database_default AND
			A.IWMMCU = B.IWMMCU COLLATE database_default
			
END
GO