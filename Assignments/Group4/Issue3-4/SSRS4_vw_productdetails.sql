use ContosoRetailDW
go

create view vw_ProductDetails
as 
select p.[ProductName]
,p.[ProductDescription]
,ps.[ProductSubcategoryName]
,pc.ProductCategoryName
,p.[Manufacturer]
,p.[BrandName]
,p.[ClassName] 
,p.[ColorName]
,p.[Size]
,p.[UnitCost]
,p.[UnitPrice]
,p.[AvailableForSaleDate]
,p.[StopSaleDate]
,p.[Status]
from DimProduct p 
inner join DimProductSubcategory ps on p.ProductSubcategoryKey=ps.ProductSubcategoryKey
inner join DimProductCategory pc on pc.ProductCategoryKey =ps.ProductCategoryKey