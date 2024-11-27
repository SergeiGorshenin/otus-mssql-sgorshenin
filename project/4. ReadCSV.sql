USE bazaar
GO

EXEC dbo.pFirstFillTableBuyers; 
EXEC dbo.pFirstFillTableSellers; 
EXEC dbo.pFirstFillTableProductStandards;
EXEC dbo.pFirstFillTableOrderStatuses;
EXEC dbo.pFirstFillTablePointsSale;

-- Fill PointSaleProducts
DECLARE @ProductStandards_min int
DECLARE @ProductStandards_max int
DECLARE @ProductStandardID_rand_1 int
DECLARE @ProductStandardID_rand_2 int
DECLARE @PointSaleID bigint
DECLARE @ProductStandardID nvarchar(250)
DECLARE @ProductInSellerSystemID nvarchar(70)
DECLARE @ProductInSellerSystemName nvarchar(250)
DECLARE @DescriptionSmall nvarchar(70)
DECLARE @DescriptionFull nvarchar(1000) 

DECLARE cursor_temp_pointsSale CURSOR FOR 
	select 
		PointsSale.ID 
	from dbo.PointsSale as PointsSale;
OPEN cursor_temp_pointsSale;

FETCH NEXT FROM cursor_temp_pointsSale 
	INTO @PointSaleID;

WHILE @@FETCH_STATUS = 0
BEGIN

	SELECT @ProductStandards_min   = isnull(min(ID), 1) from dbo.ProductStandards
	SELECT @ProductStandards_max   = isnull(max(ID), 1) from dbo.ProductStandards
	SELECT @ProductStandardID_rand_1 = dbo.fGetRandomINT(RAND(), @ProductStandards_min, @ProductStandards_max)
	SELECT @ProductStandardID_rand_2 = dbo.fGetRandomINT(RAND(), @ProductStandards_min, @ProductStandards_max)

	SET @ProductStandards_min = LEAST(@ProductStandardID_rand_1, @ProductStandardID_rand_2);
	SET @ProductStandards_max = GREATEST(@ProductStandardID_rand_1, @ProductStandardID_rand_2);

	WHILE (@ProductStandards_min <= @ProductStandards_max)
	BEGIN
		exec dbo.pMergeTablePointSaleProducts 
						@PointSaleID ,
						@ProductStandards_min ,
						@ProductInSellerSystemID  ,
						@ProductInSellerSystemName  ,
						@DescriptionSmall ,
						@DescriptionFull;		
		SET @ProductStandards_min = @ProductStandards_min + 1;
	END

	-- Обработка данных
	FETCH NEXT FROM cursor_temp_pointsSale 
		INTO @PointSaleID;
END;

CLOSE cursor_temp_pointsSale;

DEALLOCATE cursor_temp_pointsSale;


-- Fill ProductPrices
DECLARE @ID bigint
DECLARE @PriceUpdateDate datetime2
DECLARE @sign int
DECLARE @quantity_prices int
DECLARE @quantity_prices_min int
DECLARE @quantity_prices_max int
DECLARE @price_min int
DECLARE @price_max int
DECLARE @price_new decimal(18, 2)
DECLARE @percent_price_change decimal(18, 2)
DECLARE @percent_price_change_min decimal(18, 2)
DECLARE @percent_price_change_max decimal(18, 2)

SET @quantity_prices_min = 50
SET @quantity_prices_max = 300
SET @price_min = 70
SET @price_max = 500
SET @percent_price_change_min = 0.5
SET @percent_price_change_max = 5.0

DECLARE cursor_temp_PointSaleProducts CURSOR FOR 
	select 
		PointSaleProducts.ID 
	from dbo.PointSaleProducts as PointSaleProducts;
OPEN cursor_temp_PointSaleProducts;

FETCH NEXT FROM cursor_temp_PointSaleProducts 
	INTO @ID;

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @quantity_prices = dbo.fGetRandomINT(RAND(), @quantity_prices_min, @quantity_prices_max)
	
	WHILE (@quantity_prices >= 1)
	BEGIN
		
		SELECT @PriceUpdateDate = dbo.fGetRandomDate(RAND())
		SELECT @sign = dbo.fGetSign(RAND())
		SELECT @price_new = isnull(AVG(Price), dbo.fGetRandomDECIMAL_18_2(RAND(), @price_min, @price_max)) from dbo.ProductPrices where ProductPointSaleID = @ID

		SET @percent_price_change = dbo.fGetRandomDECIMAL_18_2(RAND(), @percent_price_change_min, @percent_price_change_max)
		SET @price_new = @price_new + (@price_new * (@percent_price_change/100)) * @sign

		exec dbo.pInsertTableProductPrices
			@ID, 
			@price_new, 
			@PriceUpdateDate;

		SET @quantity_prices = @quantity_prices - 1;
	END
	
	-- Обработка данных
	FETCH NEXT FROM cursor_temp_PointSaleProducts 
		INTO @ID;
END;

CLOSE cursor_temp_PointSaleProducts;
DEALLOCATE cursor_temp_PointSaleProducts;


-- Fill ProductRemains
DECLARE @ID_1 bigint
DECLARE @RemainsUpdateDate datetime2
DECLARE @Remains decimal(18, 3)
DECLARE @Remains_max int
DECLARE @quantity_remains int
DECLARE @quantity_remains_max int

SET @Remains_max = 200
SET @quantity_remains_max = 70

DECLARE cursor_temp_PointSaleProducts CURSOR FOR 
	select 
		PointSaleProducts.ID 
	from dbo.PointSaleProducts as PointSaleProducts
		inner join dbo.ProductPrices as ProductPrices
			on PointSaleProducts.PointSaleID = ProductPrices.ProductPointSaleID

OPEN cursor_temp_PointSaleProducts;

FETCH NEXT FROM cursor_temp_PointSaleProducts 
	INTO @ID_1;

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @quantity_remains = dbo.fGetRandomINT(RAND(), 0, @quantity_remains_max)

	WHILE (@quantity_remains >= 1)
	BEGIN
		
		SET @Remains = ROUND(dbo.fGetRandomDECIMAL_18_2(RAND(), 0, @Remains_max), 0)
		SELECT @RemainsUpdateDate = dbo.fGetRandomDate(RAND())

		exec dbo.pInsertTableProductRemains
			@ID_1, 
			@Remains, 
			@RemainsUpdateDate;

		SET @quantity_remains = @quantity_remains - 1;
	END

	-- Обработка данных
	FETCH NEXT FROM cursor_temp_PointSaleProducts 
		INTO @ID_1;
END;

CLOSE cursor_temp_PointSaleProducts;
DEALLOCATE cursor_temp_PointSaleProducts;



select * from dbo.ProductRemains
select * from dbo.ProductPrices
select * from dbo.PointSaleProducts
select * from dbo.PointsSale
select * from dbo.OrderStatuses
select * from dbo.ProductStandards
select * from dbo.Sellers
select * from dbo.Buyers