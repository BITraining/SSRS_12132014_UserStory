
create view vw_ProductTotal
as 
select p.productkey
,pc.productcategoryname
,ps.ProductSubcategoryName
,sum(fs.salesamount)  SalesTotal
from
dbo.FactSales fs 
inner join dbo.DimProduct p on p.ProductKey=fs.ProductKey
inner join dbo.DimProductSubcategory ps on ps.ProductSubcategoryKey =p.ProductSubcategoryKey
inner join dbo.DimProductCategory pc on ps.ProductcategoryKey=pc.ProductCategoryKey
inner join dbo.DimStore s on s.storekey=fs.StoreKey
inner join dbo.DimGeography g  on s.GeographyKey =g.GeographyKey
where  g.RegionCountryName ='United States'
group by p.ProductKey, pc.productcategoryname, ps.ProductSubcategoryName
--order by pc.ProductCategoryName,ps.ProductSubcategoryName ;