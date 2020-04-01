use SelectoJDE
go

select distinct '[dbo].[ods_AP_Terms]' as [Table], DataRefreshedOn from [dbo].[ods_AP_Terms]
union all
select distinct '[dbo].[ods_AP_Vendor]' as [Table], DataRefreshedOn from [dbo].[ods_AP_Vendor]
union all
select distinct '[dbo].[ods_AP_VendorRemit]' as [Table], DataRefreshedOn from [dbo].[ods_AP_VendorRemit]
union all
select distinct '[dbo].[ods_AR_Customer]' as [Table], DataRefreshedOn from [dbo].[ods_AR_Customer]
union all
select distinct '[dbo].[ods_AR_CustomerContact]' as [Table], DataRefreshedOn from [dbo].[ods_AR_CustomerContact]
union all
select distinct '[dbo].[ods_AR_CustomerMemo]' as [Table], DataRefreshedOn from [dbo].[ods_AR_CustomerMemo]
union all
select distinct '[dbo].[ods_AR_Salesperson]' as [Table], DataRefreshedOn from [dbo].[ods_AR_Salesperson]
union all
select distinct '[dbo].[ods_AR_TermsCode]' as [Table], DataRefreshedOn from [dbo].[ods_AR_TermsCode]
union all
select distinct '[dbo].[ods_BM_BillDetail]' as [Table], DataRefreshedOn from [dbo].[ods_BM_BillDetail]
union all
select distinct '[dbo].[ods_BM_BillHeader]' as [Table], DataRefreshedOn from [dbo].[ods_BM_BillHeader]
union all
select distinct '[dbo].[ods_CI_ExtendedDescription]' as [Table], DataRefreshedOn from [dbo].[ods_CI_ExtendedDescription]
union all
select distinct '[dbo].[ods_CI_Item]' as [Table], DataRefreshedOn from [dbo].[ods_CI_Item]
union all
select distinct '[dbo].[ods_GL_Bank]' as [Table], DataRefreshedOn from [dbo].[ods_GL_Bank]
union all
select distinct '[dbo].[ods_IM_AliasItem]' as [Table], DataRefreshedOn from [dbo].[ods_IM_AliasItem]
union all
select distinct '[dbo].[ods_IM_AlternateItem]' as [Table], DataRefreshedOn from [dbo].[ods_IM_AlternateItem]
union all
select distinct '[dbo].[ods_IM_ItemVendor]' as [Table], DataRefreshedOn from [dbo].[ods_IM_ItemVendor]
union all
select distinct '[dbo].[ods_IM_PriceCode]' as [Table], DataRefreshedOn from [dbo].[ods_IM_PriceCode]
union all
select distinct '[dbo].[ods_IM_ProductLine]' as [Table], DataRefreshedOn from [dbo].[ods_IM_ProductLine]
union all
select distinct '[dbo].[ods_IM_UDT_Brand]' as [Table], DataRefreshedOn from [dbo].[ods_IM_UDT_Brand]
union all
select distinct '[dbo].[ods_IM_UDT_CARTRIDGE_SIZE]' as [Table], DataRefreshedOn from [dbo].[ods_IM_UDT_CARTRIDGE_SIZE]
union all
select distinct '[dbo].[ods_IM_UDT_HEADS]' as [Table], DataRefreshedOn from [dbo].[ods_IM_UDT_HEADS]
union all
select distinct '[dbo].[ods_IM_UDT_PRODUCT_CATEGORY]' as [Table], DataRefreshedOn from [dbo].[ods_IM_UDT_PRODUCT_CATEGORY]
union all
select distinct '[dbo].[ods_IM_UDT_PRODUCT_STAGE]' as [Table], DataRefreshedOn from [dbo].[ods_IM_UDT_PRODUCT_STAGE]
union all
select distinct '[dbo].[ods_IM_UDT_SERIES]' as [Table], DataRefreshedOn from [dbo].[ods_IM_UDT_SERIES]
union all
select distinct '[dbo].[ods_IM404_BinLocation]' as [Table], DataRefreshedOn from [dbo].[ods_IM404_BinLocation]
union all
select distinct '[dbo].[ods_IM404_ItemLocationQuantity]' as [Table], DataRefreshedOn from [dbo].[ods_IM404_ItemLocationQuantity]
union all
select distinct '[dbo].[ods_PO_Detail]' as [Table], DataRefreshedOn from [dbo].[ods_PO_Detail]
union all
select distinct '[dbo].[ods_PO_Header]' as [Table], DataRefreshedOn from [dbo].[ods_PO_Header]
union all
select distinct '[dbo].[ods_SO_ShipToAddress]' as [Table], DataRefreshedOn from [dbo].[ods_SO_ShipToAddress]
union all
select distinct '[dbo].[ods_SY_ActivityLog]' as [Table], DataRefreshedOn from [dbo].[ods_SY_ActivityLog]
union all
select distinct '[dbo].[ods_SY_User]' as [Table], DataRefreshedOn from [dbo].[ods_SY_User]