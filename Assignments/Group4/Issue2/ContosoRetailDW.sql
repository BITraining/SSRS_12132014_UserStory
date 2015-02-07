

USE [ContosoRetailDW]
GO



IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[v_ProductTopSell]'))
DROP VIEW [dbo].[v_ProductTopSell]
GO


create view [dbo].[V_ProductTopSell]
AS
select DimProduct.ProductName,Sum(FactSales.SalesAmount) as SumNetRevenue,
Sum(FactSales.SalesQuantity-FactSales.ReturnQuantity-FactSales.DiscountQuantity) as SumNetQuantity,DimDate.CalendarYear,DimSalesTerritory.SalesTerritoryCountry,DimProduct.ProductKey
 from FactSales inner Join DimProduct on FactSales.ProductKey=DimProduct.ProductKey
 Inner join DimDate on FactSales.DateKey=DimDate.DateKey 
 Inner join DimStore on FactSales.Storekey=DimStore.StoreKey 
 Inner join DimSalesTerritory on DimStore.GeographyKey=DimSalesTerritory.GeographyKey
where DimSalesTerritory.SalesTerritoryCountry='United States' 
group by DimProduct.ProductName,DimDate.CalendarYear,DimSalesTerritory.SalesTerritoryCountry,DimProduct.ProductKey
GO
