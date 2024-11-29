USE bazaar
GO

CREATE NONCLUSTERED INDEX [PK_Buyers_Telephone] 
ON [dbo].[Buyers]([Telephone])
GO

CREATE NONCLUSTERED INDEX [FK_ProductPrices_ProductPointSaleID] 
ON [dbo].[ProductPrices]
(
	[ProductPointSaleID],
	[PriceUpdateDate]
)
GO

CREATE NONCLUSTERED INDEX [FK_ProductRemains_ProductPointSaleID] 
ON [dbo].[ProductRemains]
(
	[ProductPointSaleID],
	[RemainsUpdateDate]
)
GO
