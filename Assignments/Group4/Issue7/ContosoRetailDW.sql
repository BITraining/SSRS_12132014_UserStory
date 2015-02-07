
/***********Task7:Selling Product under each subcategory category and Quarter and yearly based on the Country**********/
/***********Creator: Megan**************************************/
USE [ContosoRetailDW]
GO


IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[V_ProductSellQuarterSubcategory]'))
DROP VIEW [dbo].[V_ProductSellQuarterSubcategory] 
GO

Create view [dbo].[V_ProductSellQuarterSubcategory]
AS



Select Sum(fs.SalesAmount) as SumRevenue,Sum(fs.SalesQuantity-fs.ReturnQuantity-fs.DiscountQuantity) as SumQuantity, p.ProductName as ProductName,pc.ProductCategoryName as Category,ps.ProductSubcategoryName as Subcategory,dg.RegionCountryName as RegionCountryName,dd.FiscalQuarterLabel as FiscalQuarter,
dd.FiscalYear as FiscalYear
from FactSales as fs inner join DimProduct as p on fs.ProductKey=p.ProductKey
inner join DimProductSubcategory as ps on p.ProductSubcategoryKey=ps.ProductSubcategoryKey
inner join DimProductCategory as pc on ps.ProductCategoryKey=pc.ProductCategoryKey
Inner join DimStore ds on fs.Storekey=ds.StoreKey 
 Inner join DimGeography as dg on ds.GeographyKey=dg.GeographyKey
 Inner join DimDate as dd on fs.DateKey=dd.DateKey 

group by pc.ProductCategoryKey, pc.ProductCategoryName,ps.ProductSubcategoryName,ps.ProductSubcategoryKey,dg.RegionCountryName,dd.FiscalQuarterLabel,dd.FiscalYear,p.ProductName

