-- Exported from QuickDBD: https://www.quickdatabasediagrams.com/
-- Link to schema: https://app.quickdatabasediagrams.com/#/d/iqbw2t
-- NOTE! If you have used non-SQL datatypes in your design, you will have to change these here.


SET XACT_ABORT ON

BEGIN TRANSACTION QUICKDBD

CREATE TABLE [Buyers] (
    [ID] int  NOT NULL ,
    [FullName] nvarchar(70)  NOT NULL ,
    [Address] nvarchar(250)  NOT NULL ,
    CONSTRAINT [PK_Buyers] PRIMARY KEY CLUSTERED (
        [ID] ASC
    )
)

CREATE TABLE [Sellers] (
    [ID] int  NOT NULL ,
    [Name] nvarchar(70)  NOT NULL ,
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
    [ID] int  NOT NULL ,
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
    [ID] int  NOT NULL ,
    [PointSaleID] int  NOT NULL ,
    [ProductStandardID] int  NOT NULL ,
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
    [ProductPointSaleID] int  NOT NULL ,
    [Price] int  NOT NULL ,
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
    [ID] int  NOT NULL ,
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
    [OrderID] int  NOT NULL ,
    [ProductPointSaleID] int  NOT NULL ,
    [ProductPriceID] int  NOT NULL ,
    [QuantityOrdered] int  NOT NULL ,
    [QuantityActual] int  NOT NULL ,
    [Price] int  NOT NULL ,
    [Amount] int  NOT NULL ,
    CONSTRAINT [PK_LineOrders] PRIMARY KEY CLUSTERED (
        [OrderID] ASC
    )
)

ALTER TABLE [Buyers] WITH CHECK ADD CONSTRAINT [FK_Buyers_ID] FOREIGN KEY([ID])
REFERENCES [Orders] ([BuyerID])

ALTER TABLE [Buyers] CHECK CONSTRAINT [FK_Buyers_ID]

ALTER TABLE [Sellers] WITH CHECK ADD CONSTRAINT [FK_Sellers_ID] FOREIGN KEY([ID])
REFERENCES [PointsSale] ([SellerID])

ALTER TABLE [Sellers] CHECK CONSTRAINT [FK_Sellers_ID]

ALTER TABLE [PointsSale] WITH CHECK ADD CONSTRAINT [FK_PointsSale_ID] FOREIGN KEY([ID])
REFERENCES [PointSaleProducts] ([PointSaleID])

ALTER TABLE [PointsSale] CHECK CONSTRAINT [FK_PointsSale_ID]

ALTER TABLE [ProductStandards] WITH CHECK ADD CONSTRAINT [FK_ProductStandards_ID] FOREIGN KEY([ID])
REFERENCES [PointSaleProducts] ([ProductStandardID])

ALTER TABLE [ProductStandards] CHECK CONSTRAINT [FK_ProductStandards_ID]

ALTER TABLE [TypesPrices] WITH CHECK ADD CONSTRAINT [FK_TypesPrices_ID] FOREIGN KEY([ID])
REFERENCES [ProductPrices] ([PriceTypeID])

ALTER TABLE [TypesPrices] CHECK CONSTRAINT [FK_TypesPrices_ID]

ALTER TABLE [PointSaleProducts] WITH CHECK ADD CONSTRAINT [FK_PointSaleProducts_ID] FOREIGN KEY([ID])
REFERENCES [LineOrders] ([ProductPointSaleID])

ALTER TABLE [PointSaleProducts] CHECK CONSTRAINT [FK_PointSaleProducts_ID]

ALTER TABLE [PointSaleProducts] WITH CHECK ADD CONSTRAINT [FK_PointSaleProducts_PointSaleID] FOREIGN KEY([PointSaleID])
REFERENCES [Orders] ([PointSaleID])

ALTER TABLE [PointSaleProducts] CHECK CONSTRAINT [FK_PointSaleProducts_PointSaleID]

ALTER TABLE [PointSaleProducts] WITH CHECK ADD CONSTRAINT [FK_PointSaleProducts_ProductPricesID] FOREIGN KEY([ProductPricesID])
REFERENCES [ProductPrices] ([ProductPointSaleID])

ALTER TABLE [PointSaleProducts] CHECK CONSTRAINT [FK_PointSaleProducts_ProductPricesID]

ALTER TABLE [ProductPrices] WITH CHECK ADD CONSTRAINT [FK_ProductPrices_ID] FOREIGN KEY([ID])
REFERENCES [LineOrders] ([ProductPriceID])

ALTER TABLE [ProductPrices] CHECK CONSTRAINT [FK_ProductPrices_ID]

ALTER TABLE [OrderStatuses] WITH CHECK ADD CONSTRAINT [FK_OrderStatuses_ID] FOREIGN KEY([ID])
REFERENCES [Orders] ([OrderStatusID])

ALTER TABLE [OrderStatuses] CHECK CONSTRAINT [FK_OrderStatuses_ID]

ALTER TABLE [Orders] WITH CHECK ADD CONSTRAINT [FK_Orders_ID] FOREIGN KEY([ID])
REFERENCES [LineOrders] ([OrderID])

ALTER TABLE [Orders] CHECK CONSTRAINT [FK_Orders_ID]

COMMIT TRANSACTION QUICKDBD