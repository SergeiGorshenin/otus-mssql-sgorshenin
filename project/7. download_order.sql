USE bazaar
GO

DECLARE @json NVARCHAR(max);
DECLARE @json_LinesOrder NVARCHAR(max);

SELECT @json = BulkColumn
FROM OPENROWSET
(BULK 'D:\courses\otus-mssql-sgorshenin\project\json\orders\19912.json', SINGLE_CLOB)
AS DATA;

-- Order
DECLARE @NewOrderID bigint
DECLARE @Date datetime2
DECLARE @PointSaleID bigint
DECLARE @BuyerID bigint
DECLARE @OrderStatusID int
DECLARE @DeliveryCourier bit

-- Order Line
DECLARE @OrderID bigint
DECLARE @RowID int
DECLARE @ProductPointSaleID bigint
DECLARE @ProductPriceID bigint
DECLARE @QuantityOrdered decimal(18,3)
DECLARE @QuantityActual decimal(18,3)
DECLARE @Price decimal(18,2)
DECLARE @Amount decimal(18,3)

DECLARE @LineOrders TABLE(
	[OrderID] bigint  NOT NULL ,
	[RowID] int  NOT NULL, 
	[ProductPointSaleID] bigint  NOT NULL ,
	[ProductPriceID] bigint  NOT NULL ,
	[QuantityOrdered] decimal(18,3)  NOT NULL ,
	[QuantityActual] decimal(18,3)  NOT NULL ,
	[Price] decimal(18,2)  NOT NULL ,
	[Amount] decimal(18,3)  NOT NULL
)

SET @NewOrderID = 0

SELECT 
	@Date = Date,
	@PointSaleID = PointSaleID,
	@BuyerID = BuyerID,
	@OrderStatusID = OrderStatusID,
	@DeliveryCourier = DeliveryCourier
FROM OPENJSON(@json)
WITH (
	Date datetime2,
	PointSaleID bigint,
	BuyerID bigint,
	OrderStatusID int,
	DeliveryCourier bit
);

DECLARE cursor_LinesOrder CURSOR FOR 
	SELECT 
		value 
	FROM 
	OPENJSON(@json, '$.LinesOrder');

OPEN cursor_LinesOrder;

FETCH NEXT FROM cursor_LinesOrder 
	INTO @json_LinesOrder

WHILE @@FETCH_STATUS = 0
BEGIN
	
	SELECT 
		@RowID = RowID,
		@ProductPointSaleID = ProductPointSaleID,
		@ProductPriceID = ProductPriceID,
		@QuantityOrdered = QuantityOrdered,
		@QuantityActual = QuantityActual,
		@Price = Price,
		@Amount = Amount
	FROM OPENJSON(@json_LinesOrder)
	WITH (
		RowID int,
		ProductPointSaleID bigint,
		ProductPriceID bigint,
		QuantityOrdered decimal(18,3),
		QuantityActual decimal(18,3),
		Price decimal(18,2),
		Amount decimal(18,3)
	)	

	INSERT INTO @LineOrders(OrderID, RowID, ProductPointSaleID, ProductPriceID, QuantityOrdered, QuantityActual, Price, Amount)
	VALUES (@NewOrderID, @RowID, @ProductPointSaleID, @ProductPriceID, @QuantityOrdered, @QuantityActual, @Price, @Amount);
	
	-- Обработка данных
	FETCH NEXT FROM cursor_LinesOrder 
	INTO @json_LinesOrder;
END;

CLOSE cursor_LinesOrder;

DEALLOCATE cursor_LinesOrder;

BEGIN TRANSACTION create_order

-- Create Order
INSERT INTO dbo.Orders(Date, PointSaleID, BuyerID, OrderStatusID, DeliveryCourier)
VALUES (@Date, @PointSaleID, @BuyerID, @OrderStatusID, @DeliveryCourier);
SELECT @NewOrderID = SCOPE_IDENTITY();

INSERT INTO dbo.LineOrders
SELECT
	@NewOrderID as OrderID, 
	LineOrders.RowID, 
	LineOrders.ProductPointSaleID, 
	LineOrders.ProductPriceID, 
	LineOrders.QuantityOrdered, 
	LineOrders.QuantityActual, 
	LineOrders.Price, 
	LineOrders.Amount
FROM @LineOrders AS LineOrders;

COMMIT TRANSACTION create_order
	
DELETE FROM @LineOrders;