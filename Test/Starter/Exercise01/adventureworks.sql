USE [AdventureWorksDW2008]
GO
/****** Object:  View [dbo].[vProductProfitability]    Script Date: 01/17/2007 09:20:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Object:  View [dbo].[vProductProfitability]    Script Date: 01/17/2007 09:20:36 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vProductProfitability]'))
DROP VIEW [dbo].[vProductProfitability]
GO

/****** Object:  View dbo.vProductProfitability    Script Date: 9/8/2003 3:03:29 PM ******/
                   
CREATE VIEW [dbo].[vProductProfitability]
AS
SELECT     dbo.DimProduct.EnglishProductName AS Product, dbo.DimProductSubCategory.EnglishProductSubCategoryName AS SubCategory, 
                      dbo.DimProductCategory.ProductCategoryKey AS CategoryKey, dbo.DimProductCategory.EnglishProductCategoryName AS Category, 
                      SUM(dbo.FactResellerSales.TotalProductCost) AS CostAmount, SUM(dbo.FactResellerSales.SalesAmount) AS SalesAmount, 
                      SUM(dbo.FactResellerSales.OrderQuantity) AS OrderQuantity, LEFT(dbo.DimDate.EnglishMonthName, 3) AS [Month], dbo.DimDate.MonthNumberOfYear, 
                      dbo.DimDate.CalendarYear AS [Year]
FROM         dbo.FactResellerSales INNER JOIN
                      dbo.DimProduct ON dbo.FactResellerSales.ProductKey = dbo.DimProduct.ProductKey INNER JOIN
                      dbo.DimProductSubCategory ON dbo.DimProduct.ProductSubCategoryKey = dbo.DimProductSubCategory.ProductSubCategoryKey INNER JOIN
                      dbo.DimProductCategory ON dbo.DimProductSubCategory.ProductCategoryKey = dbo.DimProductCategory.ProductCategoryKey INNER JOIN
                      dbo.DimDate ON dbo.FactResellerSales.OrderDateKey = dbo.DimDate.DateKey
GROUP BY dbo.DimProduct.EnglishProductName, dbo.DimProductSubCategory.EnglishProductSubCategoryName, dbo.DimProductCategory.EnglishProductCategoryName, 
                      dbo.DimProductCategory.ProductCategoryKey, dbo.DimDate.MonthNumberOfYear, LEFT(dbo.DimDate.EnglishMonthName, 3), dbo.DimDate.CalendarYear
GO


/****** Object:  View [dbo].[vResellerSales]    Script Date: 01/17/2007 14:39:04 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vResellerSales]'))
DROP VIEW [dbo].[vResellerSales]
GO

/****** Object:  View [dbo].[vResellerSales]    Script Date: 01/17/2007 14:38:57 ******/
CREATE VIEW [dbo].[vResellerSales]
AS
SELECT     dbo.DimReseller.ResellerName AS Reseller, dbo.DimGeography.EnglishCountryRegionName AS Country, 
                      ISNULL(dbo.DimGeography.StateProvinceName,dbo.DimGeography.EnglishCountryRegionName) AS State, 
                      SUM(dbo.FactResellerSales.SalesAmount) AS SalesAmount, SUM(dbo.FactResellerSales.OrderQuantity) AS OrderQuantity, 
                      SUM(dbo.FactResellerSales.ExtendedAmount) AS ListAmount, SUM(FactResellerSales.DiscountAmount*10) AS DiscountAmount, 
                      dbo.DimDate.MonthNumberOfYear, LEFT(dbo.DimDate.EnglishMonthName, 3) AS [Month], dbo.DimDate.CalendarYear AS [Year]
FROM         dbo.FactResellerSales INNER JOIN
                      dbo.DimReseller ON dbo.FactResellerSales.ResellerKey = dbo.DimReseller.ResellerKey INNER JOIN
                      dbo.DimGeography ON dbo.DimReseller.GeographyKey = dbo.DimGeography.GeographyKey INNER JOIN
                      dbo.DimDate ON dbo.FactResellerSales.OrderDateKey = dbo.DimDate.DateKey
GROUP BY dbo.DimReseller.ResellerName, dbo.DimGeography.EnglishCountryRegionName, dbo.DimGeography.StateProvinceName, 
                      dbo.DimDate.MonthNumberOfYear, LEFT(dbo.DimDate.EnglishMonthName, 3), dbo.DimDate.CalendarYear
GO


/****** Object:  View [dbo].[vSalesandQuota]    Script Date: 01/24/2007 09:01:17 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vSalesandQuota]'))
DROP VIEW [dbo].[vSalesandQuota]
GO

/****** Object:  View [dbo].[vSalesandQuota]    Script Date: 01/24/2007 09:01:12 ******/
CREATE VIEW [dbo].[vSalesandQuota] 
AS
SELECT
    employeekey,
    orderdatekey,
    NULL AS SalesQuota,
    SUM(salesamount) AS ActualSales
FROM 
   FactResellerSales
GROUP BY 
   employeekey, orderdatekey
UNION
SELECT 
   employeekey,
   TimeKey,
   salesamountquota AS SalesQuota,
   NULL AS ActualSales
FROM
   FactSalesQuota
GO

/****** Object:  StoredProcedure [dbo].[sp_ActualVsQuota]    Script Date: 01/24/2007 08:55:02 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_ActualVsQuota]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[sp_ActualVsQuota]
GO

/****** Object:  StoredProcedure [dbo].[sp_ActualVsQuota]    Script Date: 01/24/2007 08:54:53 ******/
CREATE   PROCEDURE [dbo].[sp_ActualVsQuota] @CalendarYear char(4), @Group nvarchar(50)
AS

SELECT
  DimEmployee.FirstName,
  DimEmployee.LastName,
  DimSalesTerritory.SalesTerritoryCountry AS Country, 
  DimSalesTerritory.SalesTerritoryRegion AS Region,
  DimDate.CalendarYear AS Year, 'Qtr ' + CONVERT(varchar,
  DimDate.CalendarQuarter) AS Quarter, 
  SUM(vSalesandQuota.ActualSales) AS ActualSales,
  SUM(vSalesandQuota.SalesQuota) AS SalesQuota, 
  DimSalesTerritory.SalesTerritoryGroup AS [Group],
  CAST(DimEmployee.HireDate AS varchar(11)) AS HireDate,
  DimEmployee.Phone, 
  DimEmployee.Title,
  DimEmployee.EmailAddress,
  DimEmployee.FirstName + ' ' + DimEmployee.LastName As Employee,
  SUM(vSalesandQuota.ActualSales)/SUM(vSalesandQuota.SalesQuota) AS PercentOfQuota  
FROM
  vSalesandQuota INNER JOIN
  DimEmployee ON DimEmployee.EmployeeKey = vSalesandQuota.employeekey INNER JOIN
  DimSalesTerritory ON DimEmployee.SalesTerritoryKey = DimSalesTerritory.SalesTerritoryKey INNER JOIN
  DimDate ON vSalesandQuota.orderdatekey = DimDate.DateKey
WHERE     (DimDate.CalendarYear = @CalendarYear) AND (DimSalesTerritory.SalesTerritoryGroup = @Group)
GROUP BY
  DimEmployee.FirstName,
  DimEmployee.LastName,
  DimSalesTerritory.SalesTerritoryCountry,
  DimSalesTerritory.SalesTerritoryRegion, 
  DimDate.CalendarYear, 'Qtr ' + CONVERT(varchar, DimDate.CalendarQuarter),
  DimSalesTerritory.SalesTerritoryGroup, 
  CAST(DimEmployee.HireDate AS varchar(11)),
  DimEmployee.Phone,
  DimEmployee.Title,
  DimEmployee.EmailAddress
ORDER BY
    DimEmployee.FirstName,
    DimEmployee.LastName,
    DimSalesTerritory.SalesTerritoryGroup,
    DimDate.CalendarYear,
    'Qtr ' + CONVERT(varchar, DimDate.CalendarQuarter)
GO



USE [AdventureWorks2008]
GO
/****** Object:  View [dbo].[vOrderDetails]    Script Date: 01/26/2007 17:09:14 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vOrderDetails]'))
DROP VIEW [dbo].[vOrderDetails]
GO
/****** Object:  View [dbo].[vOrderDetails]    Script Date: 01/26/2007 17:09:07 ******/
CREATE VIEW [dbo].[vOrderDetails]
AS
SELECT
    Sales.SalesOrderHeader.SalesPersonID,
	Sales.SalesOrderHeader.SalesOrderNumber,
    Sales.SalesOrderHeader.OrderDate,
    Sales.SalesOrderHeader.ShipDate, 
    Sales.SalesOrderDetail.UnitPrice,
    Sales.SalesOrderDetail.OrderQty,
    Production.Product.Name AS Product
FROM
    Sales.SalesOrderHeader INNER JOIN Sales.SalesOrderDetail ON Sales.SalesOrderHeader.SalesOrderID = Sales.SalesOrderDetail.SalesOrderID
    INNER JOIN Production.Product ON Sales.SalesOrderDetail.ProductID =  Production.Product.ProductID
GO


USE Master
GO
IF  EXISTS (SELECT * FROM sys.server_principals WHERE name = N'ReportExecution')
DROP LOGIN [ReportExecution]
GO
CREATE LOGIN ReportExecution WITH PASSWORD = 'Pa$$w0rd'
GO

USE [AdventureWorks2008]
GO
/****** Object:  User [ReportExecution]    Script Date: 01/31/2007 16:52:53 ******/
IF  EXISTS (SELECT * FROM sys.database_principals WHERE name = N'ReportExecution')
DROP USER [ReportExecution]
GO
CREATE USER [ReportExecution] FOR LOGIN [ReportExecution] WITH DEFAULT_SCHEMA=[dbo]
GO
EXEC sp_addrolemember N'db_datareader', N'ReportExecution'
GO

USE [AdventureWorksDW2008]
GO
/****** Object:  User [ReportExecution]    Script Date: 01/31/2007 16:52:53 ******/
IF  EXISTS (SELECT * FROM sys.database_principals WHERE name = N'ReportExecution')
DROP USER [ReportExecution]
GO
CREATE USER [ReportExecution] FOR LOGIN [ReportExecution] WITH DEFAULT_SCHEMA=[dbo]
GO
EXEC sp_addrolemember N'db_datareader', N'ReportExecution'
GO

use AdventureWorksDW2008 

/* Create and Populate SubscriptionGroupDirector Table */

if exists (select * from dbo.sysobjects where id = object_id(N'[SubscriptionGroupDirector]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [SubscriptionGroupDirector]
GO


CREATE TABLE [SubscriptionGroupDirector] (
	[To] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[IncludeReport] [bit] NULL ,
	[RenderFormat] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[IncludeLink] [bit] NULL ,
	[GroupParameter] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL 
) ON [PRIMARY]
GO


INSERT INTO SubscriptionGroupDirector
Values( 'Student@adventure-works.com', 1, 'MHTML', 0, 'North America' )

INSERT INTO SubscriptionGroupDirector
Values( 'Student@adventure-works.com', 0, 'Excel', 1, 'Pacific')

INSERT INTO SubscriptionGroupDirector
Values( 'Student@adventure-works.com', 1, 'IMAGE', 0, 'Europe')
GO

/* Create and populate PermissionsSalesTerritory Table */

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PermissionsSalesTerritory]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[PermissionsSalesTerritory]
GO

CREATE TABLE [dbo].[PermissionsSalesTerritory] (
	[UserId] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[SalesTerritoryGroup] [nvarchar] (50) COLLATE Latin1_General_CS_AS NULL 
) ON [PRIMARY]
GO

declare @sales as varchar(50)
set @sales = @@SERVERNAME
INSERT INTO 
[dbo].[PermissionsSalesTerritory] VALUES 
(@sales + '\Administrator', 'Europe')
GO

declare @sales as varchar(50)
set @sales = @@SERVERNAME
INSERT INTO 
[dbo].[PermissionsSalesTerritory] VALUES 
(@sales + '\EuropeDirector', 'Europe')
GO

declare @sales as varchar(50)
set @sales = @@SERVERNAME
INSERT INTO 
[dbo].[PermissionsSalesTerritory] VALUES 
(@sales + '\NADirector', 'North America')
GO

declare @sales as varchar(50)
set @sales = @@SERVERNAME
INSERT INTO 
[dbo].[PermissionsSalesTerritory] VALUES 
(@sales + '\Administrator', 'North America')	
GO

declare @sales as varchar(50)
set @sales = @@SERVERNAME
INSERT INTO 
[dbo].[PermissionsSalesTerritory] VALUES 
(@sales + '\PacificDirector', 'Pacific')	
GO

declare @sales as varchar(50)
set @sales = @@SERVERNAME
INSERT INTO 
[dbo].[PermissionsSalesTerritory] VALUES 
(@sales + '\Administrator', 'Pacific')
GO