USE bazaar
select 
	PointSaleProducts.ProductStandardID,
	ProductStandards.Name,
	ProductPrices.ProductPointSaleID, 
	min(ProductPrices.Price), 
	max(ProductPrices.price),
	min(ProductRemains.Remains), 
	max(ProductRemains.Remains) 
from dbo.ProductPrices as ProductPrices
	left join dbo.PointSaleProducts as PointSaleProducts
			on PointSaleProducts.ID = ProductPrices.ProductPointSaleID
	left join dbo.ProductStandards as ProductStandards
			on PointSaleProducts.ProductStandardID = ProductStandards.ID
	left join dbo.ProductRemains as ProductRemains
			on PointSaleProducts.ID = ProductRemains.ProductPointSaleID
group by 
	ProductStandards.Name,
	PointSaleProducts.ProductStandardID,
	ProductPrices.ProductPointSaleID

select * from dbo.ProductPrices

select * from dbo.ProductRemains where ProductPointSaleID = 131

USE bazaar
select * from dbo.Orders
select * from dbo.LineOrders