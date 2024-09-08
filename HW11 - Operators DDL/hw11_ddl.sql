
CREATE DATABASE PeoplesMarketplace;
GO

USE PeoplesMarketplace;
GO

SET XACT_ABORT ON

BEGIN TRANSACTION QUICKDBD

CREATE TABLE [Buyers] (
    [ID] int  NOT NULL ,
    [FullName] nvarchar(250)  NOT NULL ,
    [Address] nvarchar(250)  NOT NULL ,
    CONSTRAINT [PK_Buyers] PRIMARY KEY CLUSTERED (
        [ID] ASC
    )
)

CREATE TABLE [Sellers] (
    [ID] int  NOT NULL ,
    [Name] nvarchar(250)  NOT NULL ,
    [INN] nvarchar(70)  NOT NULL ,
    CONSTRAINT [PK_Sellers] PRIMARY KEY CLUSTERED (
        [ID] ASC
    )
)

CREATE TABLE [PointsSale] (
    [ID] int  NOT NULL ,
    [SellerID] int  NOT NULL ,
    [Geolocation] geography  NOT NULL ,
    [Photo] binary  NOT NULL ,
    [AmountOrderForDeliveryCourier] int  NOT NULL ,
    CONSTRAINT [PK_PointsSale] PRIMARY KEY CLUSTERED (
        [ID] ASC
    )
)

CREATE TABLE [ProductStandards] (
    [ID] bigint  NOT NULL ,
    [Name] nvarchar(70)  NOT NULL ,
    CONSTRAINT [PK_ProductStandards] PRIMARY KEY CLUSTERED (
        [ID] ASC
    )
)

CREATE TABLE [TypesPrices] (
    [ID] int  NOT NULL ,
    [Name] nvarchar(70)  NOT NULL ,
    CONSTRAINT [PK_TypesPrices] PRIMARY KEY CLUSTERED (
        [ID] ASC
    )
)

CREATE TABLE [PointSaleProducts] (
    [ID] bigint  NOT NULL ,
    [PointSaleID] int  NOT NULL ,
    [ProductStandardID] bigint  NOT NULL ,
    [ProductInSellerSystemID] nvarchar(70)  NOT NULL ,
    [ProductInSellerSystemName] nvarchar(70)  NOT NULL ,
    [ProductPricesID] int  NOT NULL ,
    [UnitMeasurement] nvarchar(30)  NOT NULL ,
    [Remains] int  NOT NULL ,
    [RemainsUpdateDate] datetime2  NOT NULL ,
    CONSTRAINT [PK_PointSaleProducts] PRIMARY KEY CLUSTERED (
        [ID] ASC
    )
)

CREATE TABLE [ProductPrices] (
    [ID] int  NOT NULL ,
    [PriceTypeID] int  NOT NULL ,
    [ProductPointSaleID] bigint  NOT NULL ,
    [Price] decimal(18,2)  NOT NULL ,
    [PriceUpdateDate] datetime2  NOT NULL ,
    CONSTRAINT [PK_ProductPrices] PRIMARY KEY CLUSTERED (
        [ID] ASC
    )
)

CREATE TABLE [OrderStatuses] (
    [ID] int  NOT NULL ,
    [Name] nvarchar(70)  NOT NULL ,
    CONSTRAINT [PK_OrderStatuses] PRIMARY KEY CLUSTERED (
        [ID] ASC
    )
)

CREATE TABLE [Orders] (
    [ID] bigint  NOT NULL ,
    [Date] datetime2  NOT NULL ,
    [PointSaleID] int  NOT NULL ,
    [BuyerID] int  NOT NULL ,
    [OrderStatusID] int  NOT NULL ,
    [DeliveryCourier] bit  NOT NULL ,
    CONSTRAINT [PK_Orders] PRIMARY KEY CLUSTERED (
        [ID] ASC
    )
)

CREATE TABLE [LineOrders] (
    [OrderID] bigint  NOT NULL ,
    [ProductPointSaleID] bigint  NOT NULL ,
    [ProductPriceID] int  NOT NULL ,
    [QuantityOrdered] int  NOT NULL ,
    [QuantityActual] int  NOT NULL ,
    [Price] decimal(18,2)  NOT NULL ,
    [Amount] int  NOT NULL ,
    CONSTRAINT [PK_LineOrders] PRIMARY KEY CLUSTERED (
        [OrderID] ASC
    )
)

ALTER TABLE [PointsSale] WITH CHECK ADD CONSTRAINT [FK_PointsSale_SellerID] FOREIGN KEY([SellerID])
REFERENCES [Sellers] ([ID])

ALTER TABLE [PointsSale] CHECK CONSTRAINT [FK_PointsSale_SellerID]

ALTER TABLE [PointSaleProducts] WITH CHECK ADD CONSTRAINT [FK_PointSaleProducts_PointSaleID] FOREIGN KEY([PointSaleID])
REFERENCES [PointsSale] ([ID])

ALTER TABLE [PointSaleProducts] CHECK CONSTRAINT [FK_PointSaleProducts_PointSaleID]

ALTER TABLE [PointSaleProducts] WITH CHECK ADD CONSTRAINT [FK_PointSaleProducts_ProductStandardID] FOREIGN KEY([ProductStandardID])
REFERENCES [ProductStandards] ([ID])

ALTER TABLE [PointSaleProducts] CHECK CONSTRAINT [FK_PointSaleProducts_ProductStandardID]

ALTER TABLE [PointSaleProducts] WITH CHECK ADD CONSTRAINT [FK_PointSaleProducts_ProductPricesID] FOREIGN KEY([ProductPricesID])
REFERENCES [ProductPrices] ([ID])

ALTER TABLE [PointSaleProducts] CHECK CONSTRAINT [FK_PointSaleProducts_ProductPricesID]

ALTER TABLE [ProductPrices] WITH CHECK ADD CONSTRAINT [FK_ProductPrices_PriceTypeID] FOREIGN KEY([PriceTypeID])
REFERENCES [TypesPrices] ([ID])

ALTER TABLE [ProductPrices] CHECK CONSTRAINT [FK_ProductPrices_PriceTypeID]

ALTER TABLE [Orders] WITH CHECK ADD CONSTRAINT [FK_Orders_PointSaleID] FOREIGN KEY([PointSaleID])
REFERENCES [PointsSale] ([ID])

ALTER TABLE [Orders] CHECK CONSTRAINT [FK_Orders_PointSaleID]

ALTER TABLE [Orders] WITH CHECK ADD CONSTRAINT [FK_Orders_BuyerID] FOREIGN KEY([BuyerID])
REFERENCES [Buyers] ([ID])

ALTER TABLE [Orders] CHECK CONSTRAINT [FK_Orders_BuyerID]

ALTER TABLE [Orders] WITH CHECK ADD CONSTRAINT [FK_Orders_OrderStatusID] FOREIGN KEY([OrderStatusID])
REFERENCES [OrderStatuses] ([ID])

ALTER TABLE [Orders] CHECK CONSTRAINT [FK_Orders_OrderStatusID]

ALTER TABLE [LineOrders] WITH CHECK ADD CONSTRAINT [FK_LineOrders_OrderID] FOREIGN KEY([OrderID])
REFERENCES [Orders] ([ID])

ALTER TABLE [LineOrders] CHECK CONSTRAINT [FK_LineOrders_OrderID]

ALTER TABLE [LineOrders] WITH CHECK ADD CONSTRAINT [FK_LineOrders_ProductPointSaleID] FOREIGN KEY([ProductPointSaleID])
REFERENCES [PointSaleProducts] ([ID])

ALTER TABLE [LineOrders] CHECK CONSTRAINT [FK_LineOrders_ProductPointSaleID]

ALTER TABLE [LineOrders] WITH CHECK ADD CONSTRAINT [FK_LineOrders_ProductPriceID] FOREIGN KEY([ProductPriceID])
REFERENCES [ProductPrices] ([ID])

ALTER TABLE [LineOrders] CHECK CONSTRAINT [FK_LineOrders_ProductPriceID]

--индексы

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

--запреты

ALTER TABLE [Buyers] ADD CONSTRAINT [constr_Buyers_FullName] CHECK([FullName]>'');
ALTER TABLE [Sellers] ADD CONSTRAINT [constr_Sellers_Name] CHECK([Name]>'');
ALTER TABLE [ProductStandards] ADD CONSTRAINT [constr_ProductStandards_Name] CHECK([Name]>'');

COMMIT TRANSACTION QUICKDBD

