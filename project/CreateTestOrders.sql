USE bazaar
GO

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

-- main variables
DECLARE @PointSaleID_min bigint
DECLARE @PointSaleID_max bigint
DECLARE @BuyerID_min bigint
DECLARE @BuyerID_max bigint
DECLARE @OrderStatusID_min bigint
DECLARE @OrderStatusID_max bigint

DECLARE @QuantityOrders int
SET @QuantityOrders = 1

WHILE (@QuantityOrders <= 5000)
BEGIN
	SELECT @PointSaleID_min   = MIN(ID) FROM dbo.PointsSale;
	SELECT @PointSaleID_max   = MAX(ID) FROM dbo.PointsSale
	SELECT @BuyerID_min		  = MIN(ID) FROM dbo.Buyers;
	SELECT @BuyerID_max		  = MAX(ID) FROM dbo.Buyers
	SELECT @OrderStatusID_min = MIN(ID) FROM dbo.OrderStatuses;
	SELECT @OrderStatusID_max = MAX(ID) FROM dbo.OrderStatuses

	SET @Date			 = dbo.fGetRandomDate(RAND()) 
	SET @PointSaleID	 = dbo.fGetRandomINT(RAND(), @PointSaleID_min, @PointSaleID_max) 
	SET @BuyerID		 = dbo.fGetRandomINT(RAND(), @BuyerID_min, @BuyerID_max) 
	SET @OrderStatusID	 = dbo.fGetRandomINT(RAND(), @OrderStatusID_min, @OrderStatusID_max)  
	SET @DeliveryCourier = dbo.fGetRandomINT(RAND(), 0, 1) 

	DECLARE @MaxRowsInOrder int
	SET @MaxRowsInOrder = dbo.fGetRandomINT(RAND(), 1, 15)
	SET @NewOrderID = 1

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

	WHILE (@MaxRowsInOrder > 0)
	BEGIN
		print(@MaxRowsInOrder)

		-- PointSaleProducts
		DECLARE @rand float
		SET @rand = RAND()
		EXEC @ProductPointSaleID = pGetRandomPointSaleProducts @rand, @PointSaleID;

		-- ProductPriceID
		SELECT
			@ProductPriceID = t_price.id,
			@Price = t_price.Price
		FROM dbo.fGetPrice(@ProductPointSaleID, @Date) as t_price

		-- ProductRemains
		DECLARE @QuantityOrdered_max decimal(18,3)
		SET @QuantityOrdered_max = dbo.fGetRemain(@ProductPointSaleID, @Date)

		SET @QuantityOrdered = dbo.fGetRandomINT(RAND(), 1, @QuantityOrdered_max);
		SET @QuantityActual  = dbo.fGetRandomINT(RAND(), 1, @QuantityOrdered);
		SET @Amount = @QuantityActual * @Price

		INSERT INTO @LineOrders(OrderID, RowID, ProductPointSaleID, ProductPriceID, QuantityOrdered, QuantityActual, Price, Amount)
		VALUES (@NewOrderID, @MaxRowsInOrder, @ProductPointSaleID, @ProductPriceID, @QuantityOrdered, @QuantityActual, @Price, @Amount);
	
		SET @MaxRowsInOrder = @MaxRowsInOrder - 1;
	END

	BEGIN TRANSACTION create_order

	-- Create Order
	INSERT INTO dbo.Orders(Date, PointSaleID, BuyerID, OrderStatusID, DeliveryCourier)
	VALUES (@Date, @PointSaleID, @BuyerID, @OrderStatusID, @DeliveryCourier);
	SELECT @NewOrderID = SCOPE_IDENTITY();

	;
	WITH cte_minrow AS
	(
		SELECT
			MAX(LineOrders.RowID) as RowID, 
			LineOrders.ProductPointSaleID
		FROM @LineOrders AS LineOrders
		GROUP BY LineOrders.ProductPointSaleID
	)

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
	FROM @LineOrders AS LineOrders
	inner join cte_minrow as cte_minrow
		on LineOrders.RowID = cte_minrow.RowID
		and LineOrders.ProductPointSaleID = cte_minrow.ProductPointSaleID;

	COMMIT TRANSACTION create_order
	
	SET @QuantityOrders = @QuantityOrders + 1;
END

