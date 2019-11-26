Use SelectoJDE
Go

declare @doItems nchar(1) = N'N';
declare @doCustomers nchar(1) = N'N';
declare @doVendors nchar(1) = N'N';
declare @doBaseAddressBooks nchar(1) = N'N';

if ( N'Y' = @doItems ) begin
	truncate table bkup.F4101
	insert into bkup.F4101 select * from N0E9SQL01.JDE_DEVELOPMENT.TESTDTA.F4101
	truncate table bkup.F4102
	insert into bkup.F4102 select * from N0E9SQL01.JDE_DEVELOPMENT.TESTDTA.F4102
	truncate table bkup.F41021
	insert into bkup.F41021 select * from N0E9SQL01.JDE_DEVELOPMENT.TESTDTA.F41021
	truncate table bkup.F4105
	insert into bkup.F4105 select * from N0E9SQL01.JDE_DEVELOPMENT.TESTDTA.F4105
	truncate table bkup.F4106
	insert into bkup.F4106 select * from N0E9SQL01.JDE_DEVELOPMENT.TESTDTA.F4106
	truncate table bkup.F4104
	insert into bkup.F4104 select * from N0E9SQL01.JDE_DEVELOPMENT.TESTDTA.F4104
	truncate table bkup.F3002
	insert into bkup.F3002 select * from N0E9SQL01.JDE_DEVELOPMENT.TESTDTA.F3002
	truncate table bkup.F3003
	insert into bkup.F3003 select * from N0E9SQL01.JDE_DEVELOPMENT.TESTDTA.F3003
end

if ( N'Y' = @doBaseAddressBooks ) begin
	truncate table bkup.F0101
	truncate table bkup.F0111
	truncate table bkup.F0115
	truncate table bkup.F0116
	insert into bkup.F0101 select * from N0E9SQL01.JDE_DEVELOPMENT.TESTDTA.F0101
	insert into bkup.F0111 select * from N0E9SQL01.JDE_DEVELOPMENT.TESTDTA.F0111
	insert into bkup.F0115 select * from N0E9SQL01.JDE_DEVELOPMENT.TESTDTA.F0115
	insert into bkup.F0116 select * from N0E9SQL01.JDE_DEVELOPMENT.TESTDTA.F0116
end

if ( N'Y' = @doVendors ) begin
	truncate table bkup.F0401
	insert into bkup.F0401 select * from N0E9SQL01.JDE_DEVELOPMENT.TESTDTA.F0401
end

if ( N'Y' = @doCustomers ) begin
	truncate table bkup.F03012
	insert into bkup.F03012 select * from N0E9SQL01.JDE_DEVELOPMENT.TESTDTA.F03012
end