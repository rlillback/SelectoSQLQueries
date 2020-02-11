use SelectoJDE
go

create table dbo.ods_VendorFlatFile (
	ALKY nchar(20) not NULL,
	AT1 nchar(3) NULL, -- Code as I for inactive, R3 remit only, or V3 Vendor
	CM nchar(2) NULL,
	MCUP nchar(12) NULL, -- NOTE: This isn't the padded format
	OBAP nchar(6) NULL,
	AIDP nchar(8) NULL,
	PYIN nchar(1) NULL,
	ADD1 nchar(40) NULL,
	ADD2 nchar(40) NULL,
	CTY1 nchar(25) NULL,
	ADDS nchar(3) NULL,
	ADDZ nchar(12) NULL,
	CTR nchar(3) NULL,
	PRE nchar(6) NULL,
	PH1 nchar(20) NULL,
)