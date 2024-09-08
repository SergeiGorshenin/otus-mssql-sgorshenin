USE PeoplesMarketplace
GO

DROP INDEX IF EXISTS [FK_PointSaleProducts_PointSaleID] ON [dbo].[PointSaleProducts]

CREATE NONCLUSTERED INDEX [FK_PointSaleProducts_PointSaleID] 
ON [dbo].[PointSaleProducts]([PointSaleID])
GO

DROP INDEX IF EXISTS [FK_Buyers_FullName] ON [dbo].Buyers

CREATE NONCLUSTERED INDEX [FK_Buyers_FullName] 
ON [dbo].Buyers(FullName)
GO

DROP INDEX IF EXISTS [FK_Sellers_Name] ON [dbo].Sellers

CREATE NONCLUSTERED INDEX [FK_Sellers_Name] 
ON [dbo].Sellers(Name)
GO

DROP INDEX IF EXISTS [FK_PointSaleProducts_Name] ON [dbo].ProductStandards

CREATE NONCLUSTERED INDEX [FK_PointSaleProducts_Name] 
ON [dbo].ProductStandards(Name)
GO