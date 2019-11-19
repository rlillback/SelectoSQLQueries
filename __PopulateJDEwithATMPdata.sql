use SelectoJDE
go

begin transaction Ray
	begin try 
		insert into n0e9sql01.jde_development.testdta.F3002 select * from atmp.F3002
		insert into n0e9sql01.jde_development.testdta.F3003 select * from atmp.F3003
		insert into n0e9sql01.jde_development.testdta.F4101 select * from atmp.F4101
		insert into n0e9sql01.jde_development.testdta.F4102 select * from atmp.F4102
		insert into n0e9sql01.jde_development.testdta.F41021 select * from atmp.F41021
		insert into n0e9sql01.jde_development.testdta.F4104 select * from atmp.F4104
		insert into n0e9sql01.jde_development.testdta.F4105 select * from atmp.F4105
		insert into n0e9sql01.jde_development.testdta.F4106 select * from atmp.F4106
	end try
	begin catch
		select ERROR_NUMBER() as ErrorNumber, ERROR_MESSAGE() as ErrorMessage;
		if @@TRANCOUNT > 0 rollback transaction Ray
	end catch;
if @@TRANCOUNT > 0 commit transaction Ray
