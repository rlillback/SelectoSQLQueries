use SelectoJDE

-----------------------------------------------------------------------------------------
--
-- Grab all active users in the Sage system at Selecto
--
-- History:
-- 25-Aug-2019 R.Lillback Created initial version
--
-----------------------------------------------------------------------------------------
select 
	* 
from ods_SY_User
where Active = N'Y' and -- The user is active
      LastActivityDate is not null -- The user logged into the system on or after 5/1/2019