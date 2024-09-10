
-- for iss data
 
SET NOCOUNT ON
declare @securityIdentifier as [vendor].[securityIdentifier] 
declare @vendorItem as [vendor].[vendorItem]
declare @vd as [vendor].[vdList]


insert into @securityIdentifier (stoxxid)
SELECT a.stoxxId FROM (values ('{}')) AS a(stoxxId)

insert into @vendorItem (itemName)
values('ClimateScope1Emissions'),('ClimateScope2Emissions'),('ClimateScope3Emissions')

insert into @vd 
values({})--cutoffdate


select  * from [vendor].[tvfVendorData] (@securityIdentifier ,@vendorItem, @vd ,'ISS')



