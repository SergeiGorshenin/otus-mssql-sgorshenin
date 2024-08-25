USE PeoplesMarketplace
GO

DROP INDEX IF EXISTS [FK_PointSaleProducts_PointSaleID] ON [dbo].[PointSaleProducts]

CREATE NONCLUSTERED INDEX [FK_PointSaleProducts_PointSaleID] 
ON [dbo].[PointSaleProducts]([PointSaleID])
GO
