Use ContosoRetailDW
Go

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
-- drop procedure usp_GetProdcutRankinCategory
create procedure usp_GetProdcutRankinCategory
as 

BEGIN TRY DROP TABLE ##salesCategoryRank END TRY BEGIN CATCH END CATCH

select  p.productkey,pc.productcategoryname, sum(fs.salesamount)  SalesTotal,  sum(fs.salesQuantity) SalesQty,
DENSE_RANK() OVER (PARTITION BY pc.productcategoryname ORDER BY sum(fs.salesamount) DESC) AS SalesRank
into ##salesCategoryRank
from
dbo.FactSales fs 
inner join dbo.DimProduct p on p.ProductKey=fs.ProductKey
inner join dbo.DimProductSubcategory ps on ps.ProductSubcategoryKey =p.ProductSubcategoryKey
inner join dbo.DimProductCategory pc on ps.ProductcategoryKey=pc.ProductCategoryKey
inner join dbo.DimStore s on s.storekey=fs.StoreKey
inner join dbo.DimGeography g  on s.GeographyKey =g.GeographyKey
where  g.RegionCountryName ='United States'
group by p.productkey, pc.productcategoryname ;


select p.productkey, p.ProductLabel, p.productname, p.ProductURL,r.ProductCategoryName, r.SalesTotal, r.SalesQty, r.SalesRank
 from dbo.DimProduct p 
 inner join  ##salesCategoryRank r on r.productkey=p.productkey
 where r.salesrank<=3;


-- exec usp_GetProdcutRankinCategory;
