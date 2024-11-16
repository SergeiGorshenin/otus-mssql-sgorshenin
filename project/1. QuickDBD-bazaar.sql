CREATE DATABASE bazaar
COLLATE SQL_Latin1_General_CP1_CI_AS;
GO

use bazaar;
GO

SET XACT_ABORT ON

BEGIN TRANSACTION QUICKDBD

CREATE TABLE [Buyers] (
    [ID] bigint  NOT NULL IDENTITY(1, 1),
    [Name] nvarchar(250)  NOT NULL ,
    [Address] nvarchar(250)  NULL ,
    [Telephone] nvarchar(70)  NULL ,
    CONSTRAINT [PK_Buyers] PRIMARY KEY CLUSTERED (
        [ID] ASC
    )
)

CREATE TABLE [Sellers] (
    [ID] bigint  NOT NULL IDENTITY(1, 1),
    [Name] nvarchar(250)  NOT NULL ,
    [INN] nvarchar(70)  NULL ,
    [Address] nvarchar(250)  NOT NULL ,
    CONSTRAINT [PK_Sellers] PRIMARY KEY CLUSTERED (
        [ID] ASC
    )
)

CREATE TABLE [PointsSale] (
    [ID] bigint  NOT NULL IDENTITY(1, 1),
    [SellerID] bigint  NOT NULL ,
    [Name] nvarchar(250)  NOT NULL ,
    [Address] nvarchar(250)  NOT NULL ,
    [Telephone] nvarchar(70)  NULL ,
    CONSTRAINT [PK_PointsSale] PRIMARY KEY CLUSTERED (
        [ID] ASC
    )
)

CREATE TABLE [ProductStandards] (
    [ID] int  NOT NULL IDENTITY(1, 1),
    [Name] nvarchar(250)  NOT NULL ,
    [Description] nvarchar(1000)  NULL ,
    CONSTRAINT [PK_ProductStandards] PRIMARY KEY CLUSTERED (
        [ID] ASC
    )
)

CREATE TABLE [PointSaleProducts] (
    [ID] bigint  NOT NULL IDENTITY(1, 1),
    [PointSaleID] bigint  NOT NULL ,
    [ProductStandardID] int  NOT NULL ,
    [ProductInSellerSystemID] nvarchar(70)  NULL ,
    [ProductInSellerSystemName] nvarchar(250)  NULL ,
    [DescriptionSmall] nvarchar(70)  NULL ,
    [DescriptionFull] nvarchar(1000)  NULL ,
    CONSTRAINT [PK_PointSaleProducts] PRIMARY KEY CLUSTERED (
        [ID] ASC
    )
)

CREATE TABLE [ProductPrices] (
    [ID] bigint  NOT NULL IDENTITY(1, 1),
    [ProductPointSaleID] bigint  NOT NULL ,
    [Price] decimal(18,2)  NOT NULL ,
    [PriceUpdateDate] datetime2  NOT NULL ,
    CONSTRAINT [PK_ProductPrices] PRIMARY KEY CLUSTERED (
        [ID] ASC
    )
)

CREATE TABLE [ProductRemains] (
    [ProductPointSaleID] bigint  NOT NULL ,
    [Remains] decimal(18,3)  NOT NULL ,
    [RemainsUpdateDate] datetime2  NOT NULL 
)

CREATE TABLE [OrderStatuses] (
    [ID] int  NOT NULL IDENTITY(1, 1),
    [Name] nvarchar(70)  NOT NULL ,
    [Description] nvarchar(250)  NULL ,
    CONSTRAINT [PK_OrderStatuses] PRIMARY KEY CLUSTERED (
        [ID] ASC
    )
)

CREATE TABLE [Orders] (
    [ID] bigint  NOT NULL IDENTITY(1, 1),
    [Date] datetime2  NOT NULL ,
    [PointSaleID] bigint  NOT NULL ,
    [BuyerID] bigint  NOT NULL ,
    [OrderStatusID] int  NOT NULL ,
    [DeliveryCourier] bit  NOT NULL ,
    CONSTRAINT [PK_Orders] PRIMARY KEY CLUSTERED (
        [ID] ASC
    )
)

CREATE TABLE [LineOrders] (
    [OrderID] bigint  NOT NULL ,
	[RowID] int  NOT NULL, 
    [ProductPointSaleID] bigint  NOT NULL ,
    [ProductPriceID] bigint  NOT NULL ,
    [QuantityOrdered] decimal(18,3)  NOT NULL ,
    [QuantityActual] decimal(18,3)  NOT NULL ,
    [Price] decimal(18,2)  NOT NULL ,
    [Amount] decimal(18,3)  NOT NULL ,
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

ALTER TABLE [ProductPrices] WITH CHECK ADD CONSTRAINT [FK_ProductPrices_ProductPointSaleID] FOREIGN KEY([ProductPointSaleID])
REFERENCES [PointSaleProducts] ([ID])

ALTER TABLE [ProductPrices] CHECK CONSTRAINT [FK_ProductPrices_ProductPointSaleID]

ALTER TABLE [ProductRemains] WITH CHECK ADD CONSTRAINT [FK_ProductRemains_ProductPointSaleID] FOREIGN KEY([ProductPointSaleID])
REFERENCES [PointSaleProducts] ([ID])

ALTER TABLE [ProductRemains] CHECK CONSTRAINT [FK_ProductRemains_ProductPointSaleID]

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

COMMIT TRANSACTION QUICKDBD