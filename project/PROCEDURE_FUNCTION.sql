USE bazaar;
GO

-- main function
	--SELECT dbo.fGetRandomINT(RAND(), 1, 2)
	--SELECT dbo.fGetRandomDECIMAL_18_2(RAND(), 1, 2);
	--SELECT dbo.fGetRandomDate(RAND());
IF OBJECT_ID (N'dbo.fGetRandomINT', N'FN') IS NOT NULL DROP FUNCTION dbo.fGetRandomINT;
IF OBJECT_ID (N'dbo.fGetSign', N'FN') IS NOT NULL DROP FUNCTION dbo.fGetSign;
IF OBJECT_ID (N'dbo.fGetRandomDate', N'FN') IS NOT NULL DROP FUNCTION dbo.fGetRandomDate;
IF OBJECT_ID (N'dbo.fGetRandomDECIMAL_18_2', N'FN') IS NOT NULL DROP FUNCTION dbo.fGetRandomDECIMAL_18_2;
IF OBJECT_ID (N'dbo.fGetRandomDECIMAL_18_3', N'FN') IS NOT NULL DROP FUNCTION dbo.fGetRandomDECIMAL_18_3;
IF OBJECT_ID (N'dbo.fGetRemain', N'FN') IS NOT NULL DROP FUNCTION dbo.fGetRemain;
IF OBJECT_ID (N'dbo.fGetPrice', N'FN') IS NOT NULL DROP FUNCTION dbo.fGetPrice;
GO

CREATE FUNCTION fGetRandomINT(@rand float, @from_int int, @to_int int)
RETURNS INT
AS
BEGIN
    RETURN CONVERT(int, (@rand * ((@to_int + 1) - @from_int)) + @from_int);
END;
GO

CREATE FUNCTION fGetSign(@rand float)
RETURNS INT
AS
BEGIN
    RETURN CASE WHEN dbo.fGetRandomINT(@rand, 1, 2) % 2 = 0 THEN -1 ELSE 1 END;
END;
GO

CREATE FUNCTION fGetRandomDECIMAL_18_2(@rand float, @from_int int, @to_int int)
RETURNS INT
AS
BEGIN
    RETURN CONVERT(decimal(18, 2), (@rand * ((@to_int + 1) - @from_int)) + @from_int);
END;
GO

CREATE FUNCTION fGetRandomDECIMAL_18_3(@rand float, @from_int int, @to_int int)
RETURNS INT
AS
BEGIN
    RETURN CONVERT(decimal(18, 3), (@rand * ((@to_int + 1) - @from_int)) + @from_int);
END;
GO

CREATE FUNCTION fGetRandomDate(@rand float)
RETURNS DateTime2
AS
BEGIN
	declare @from_int int
	declare @to_int	  int
	
	set @from_int = 1
	set @to_int   = 1036800
    
	RETURN DATEADD(minute, -CONVERT(int, (@rand * ((@to_int + 1) - @from_int)) + @from_int), GETDATE());
END;
GO

CREATE FUNCTION fGetRemain(@ProductPointSaleID bigint, @Date datetime2)
RETURNS INT
AS
BEGIN
	DECLARE @QuantityOrdered_max decimal(18,3)
	;
	WITH cte_remains_max AS
	(
		SELECT
			@ProductPointSaleID as ProductPointSaleID,
			MAX(ProductRemains.RemainsUpdateDate) as RemainsUpdateDate
		FROM dbo.ProductRemains as ProductRemains
		WHERE ProductRemains.ProductPointSaleID = @ProductPointSaleID
			and ProductRemains.RemainsUpdateDate <= @Date
	)

	SELECT TOP 1
		@QuantityOrdered_max = ProductRemains.Remains
	FROM dbo.ProductRemains as ProductRemains
	inner join cte_remains_max as cte_remains_max
		on ProductRemains.ProductPointSaleID = cte_remains_max.ProductPointSaleID
		and ProductRemains.RemainsUpdateDate = cte_remains_max.RemainsUpdateDate
	
	RETURN @QuantityOrdered_max;
END;
GO

CREATE FUNCTION fGetPrice(@ProductPointSaleID bigint, @Date datetime2)
RETURNS TABLE
AS
RETURN
(
	WITH cte_price AS
	(
		SELECT
			@ProductPointSaleID as ProductPointSaleID,
			MAX(ProductPrices.PriceUpdateDate) as PriceUpdateDate
		FROM dbo.ProductPrices as ProductPrices
		WHERE ProductPrices.ProductPointSaleID = @ProductPointSaleID
			and ProductPrices.PriceUpdateDate <= @Date
	)

	SELECT TOP 1
		ProductPrices.ID,
		ProductPrices.Price
	FROM dbo.ProductPrices as ProductPrices
		inner join cte_price as cte_price
		on ProductPrices.ProductPointSaleID = cte_price.ProductPointSaleID
		and ProductPrices.PriceUpdateDate = cte_price.PriceUpdateDate
);
GO

-- 1. Подготовка
DELETE FROM dbo.LineOrders
DELETE FROM dbo.Orders
DELETE FROM dbo.ProductPrices
DELETE FROM dbo.OrderStatuses
DELETE FROM dbo.PointSaleProducts
DELETE FROM dbo.ProductStandards
DELETE FROM dbo.PointSaleProducts
DELETE FROM dbo.PointsSale
DELETE FROM dbo.Buyers
DELETE FROM dbo.Sellers

IF OBJECT_ID (N'pFirstFillTableBuyers', N'P')			IS NOT NULL DROP PROCEDURE dbo.pFirstFillTableBuyers;
IF OBJECT_ID (N'pFirstFillTableOrderStatuses', N'P')	IS NOT NULL DROP PROCEDURE dbo.pFirstFillTableOrderStatuses;
IF OBJECT_ID (N'pFirstFillTablePointsSale', N'P')		IS NOT NULL DROP PROCEDURE dbo.pFirstFillTablePointsSale;
IF OBJECT_ID (N'pFirstFillTableProductStandards', N'P') IS NOT NULL DROP PROCEDURE dbo.pFirstFillTableProductStandards;
IF OBJECT_ID (N'pFirstFillTableSellers', N'P')			IS NOT NULL DROP PROCEDURE dbo.pFirstFillTableSellers;
IF OBJECT_ID (N'pMergeTableBuyers', N'P')				IS NOT NULL DROP PROCEDURE dbo.pMergeTableBuyers;
IF OBJECT_ID (N'pMergeTableOrderStatuses', N'P')		IS NOT NULL DROP PROCEDURE dbo.pMergeTableOrderStatuses;
IF OBJECT_ID (N'pMergeTablePointsSale', N'P')			IS NOT NULL DROP PROCEDURE dbo.pMergeTablePointsSale;
IF OBJECT_ID (N'pMergeTableProductStandards', N'P')		IS NOT NULL DROP PROCEDURE dbo.pMergeTableProductStandards;
IF OBJECT_ID (N'pMergeTableSellers', N'P')				IS NOT NULL DROP PROCEDURE dbo.pMergeTableSellers;
IF OBJECT_ID (N'pMergeTablePointSaleProducts', N'P')	IS NOT NULL DROP PROCEDURE dbo.pMergeTablePointSaleProducts;
IF OBJECT_ID (N'pInsertTableProductPrices', N'P')		IS NOT NULL DROP PROCEDURE dbo.pInsertTableProductPrices;
IF OBJECT_ID (N'pInsertTableProductRemains', N'P')		IS NOT NULL DROP PROCEDURE dbo.pInsertTableProductRemains;
IF OBJECT_ID (N'pGetRandomPointSaleProducts', N'P')		IS NOT NULL DROP PROCEDURE dbo.pGetRandomPointSaleProducts;
GO

-- 2. Buyers
CREATE PROCEDURE dbo.pMergeTableBuyers    
    @Name nvarchar(250),
	@Address nvarchar(250),
	@Telephone nvarchar(250)
AS   
    SET NOCOUNT ON;  
		MERGE dbo.Buyers AS Target
		USING 
			  (
				SELECT
					tt.Name,
					tt.Address,
					tt.Telephone 
				FROM (SELECT @Name as Name, @Address as Address, @Telephone as Telephone) as tt
				left join dbo.Buyers as buyers
				on tt.Name = buyers.Name 
					and tt.Address = buyers.Address 
					and tt.Telephone = buyers.Telephone
			  ) as Source
			  (
				Name, Address, Telephone
			  )
			ON (Target.Telephone = Source.Telephone)
		WHEN MATCHED 
			THEN UPDATE 
				SET Name = Source.Name, Address = Source.Address, Telephone = Source.Telephone
		WHEN NOT MATCHED 
			THEN INSERT 
				(Name, Address, Telephone)
				VALUES 
				(Source.Name, Source.Address, Source.Telephone);
		--OUTPUT deleted.*, inserted.*;
GO

CREATE PROCEDURE dbo.pFirstFillTableBuyers    
AS   
    SET NOCOUNT ON;  
		drop table if exists #temp_buyers

		CREATE TABLE #temp_buyers (
			[Name] nvarchar(250)   NULL ,
			[Address] nvarchar(250)  NULL ,
			[Telephone] nvarchar(70)  NULL ,
			)

		BULK INSERT #temp_buyers 
		FROM 'D:\courses\otus-mssql-sgorshenin\project\Покупатели.csv' 
		WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ';', ROWTERMINATOR = '\n', CODEPAGE = 'ACP', DATAFILETYPE = 'widechar');

		DECLARE @Name nvarchar(250)
		DECLARE @Address nvarchar(250)
		DECLARE @Telephone nvarchar(70)

		DECLARE cursor_temp_buyers CURSOR FOR SELECT * FROM #temp_buyers;
		OPEN cursor_temp_buyers;

		FETCH NEXT FROM cursor_temp_buyers 
			INTO @Name, @Address, @Telephone;

		WHILE @@FETCH_STATUS = 0
		BEGIN
			exec dbo.pMergeTableBuyers @Name, @Address, @Telephone;
			-- Обработка данных
			FETCH NEXT FROM cursor_temp_buyers 
				INTO @Name, @Address, @Telephone;
		END;

		CLOSE cursor_temp_buyers;

		DEALLOCATE cursor_temp_buyers;
GO

-- 2. Sellers
CREATE PROCEDURE dbo.pMergeTableSellers    
    @Name nvarchar(250),
	@INN nvarchar(70),
	@Address nvarchar(250)
AS   
    SET NOCOUNT ON;  
		MERGE dbo.Sellers AS Target
		USING 
			  (
				SELECT
					tt.Name,
					tt.INN as INN,
					tt.Address 
				FROM (SELECT @Name as Name, @INN as INN, @Address as Address) as tt
				left join dbo.Sellers as Sellers
				on tt.Name = Sellers.Name 
					and tt.INN = Sellers.INN
					and tt.Address = Sellers.Address 
			  ) as Source
			  (
				Name, INN, Address
			  )
			ON (Target.INN = Source.INN)
		WHEN MATCHED 
			THEN UPDATE 
				SET Name = Source.Name, INN = Source.INN, Address = Source.Address
		WHEN NOT MATCHED 
			THEN INSERT 
				(Name, INN, Address)
				VALUES 
				(Source.Name, Source.INN, Source.Address);
		--OUTPUT deleted.*, inserted.*;
GO

CREATE PROCEDURE dbo.pFirstFillTableSellers    
AS   
    SET NOCOUNT ON;  
		drop table if exists #temp_sellers

		CREATE TABLE #temp_sellers (
			[Name] nvarchar(250)   NULL ,
			[INN] nvarchar(70)  NULL ,
			[Address] nvarchar(250)   NULL ,
		)

		BULK INSERT #temp_sellers 
		FROM 'D:\courses\otus-mssql-sgorshenin\project\Продавцы.csv' 
		WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ';', ROWTERMINATOR = '\n', CODEPAGE = 'ACP', DATAFILETYPE = 'widechar');

		DECLARE @Name nvarchar(250)
		DECLARE @INNN nvarchar(70)
		DECLARE @Address nvarchar(250)

		DECLARE cursor_temp_sellers CURSOR FOR SELECT * FROM #temp_sellers;
		OPEN cursor_temp_sellers;

		FETCH NEXT FROM cursor_temp_sellers 
			INTO @Name, @INNN, @Address;

		WHILE @@FETCH_STATUS = 0
		BEGIN
			exec dbo.pMergeTableSellers @Name, @INNN, @Address;
			-- Обработка данных
			FETCH NEXT FROM cursor_temp_sellers 
				INTO @Name, @INNN, @Address;
		END;

		CLOSE cursor_temp_sellers;

		DEALLOCATE cursor_temp_sellers;
GO

-- 3. ProductStandards
CREATE PROCEDURE dbo.pMergeTableProductStandards    
    @Name nvarchar(250),
	@Description nvarchar(1000)
AS   
    SET NOCOUNT ON;  
		MERGE dbo.ProductStandards AS Target
		USING 
			  (
				SELECT
					tt.Name,
					tt.Description as Description
				FROM (SELECT @Name as Name, @Description as Description) as tt
				left join dbo.ProductStandards as ProductStandards
				on tt.Name = ProductStandards.Name 
					and tt.Description = ProductStandards.Description
			  ) as Source
			  (
				Name, Description
			  )
			ON (Target.Name = Source.Name)
		WHEN MATCHED 
			THEN UPDATE 
				SET Name = Source.Name, Description = Source.Description
		WHEN NOT MATCHED 
			THEN INSERT 
				(Name, Description)
				VALUES 
				(Source.Name, Source.Description);
		--OUTPUT deleted.*, inserted.*;
GO

CREATE PROCEDURE dbo.pFirstFillTableProductStandards    
AS   
    SET NOCOUNT ON;  
		drop table if exists #temp_productStandards

		CREATE TABLE #temp_productStandards(
			[Name] nvarchar(250)  NOT NULL ,
			[Description] nvarchar(1000)  NULL ,
		)

		BULK INSERT #temp_productStandards
		FROM 'D:\courses\otus-mssql-sgorshenin\project\Товары_эталоны.csv' 
		WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ';', ROWTERMINATOR = '\n', CODEPAGE = 'ACP', DATAFILETYPE = 'widechar');

		DECLARE @Name nvarchar(250)
		DECLARE @DescriptionN nvarchar(1000)
		
		DECLARE cursor_temp_productStandards CURSOR FOR SELECT * FROM #temp_productStandards;
		OPEN cursor_temp_productStandards;

		FETCH NEXT FROM cursor_temp_productStandards 
			INTO @Name, @DescriptionN;

		WHILE @@FETCH_STATUS = 0
		BEGIN
			exec dbo.pMergeTableProductStandards @Name, @DescriptionN;
			-- Обработка данных
			FETCH NEXT FROM cursor_temp_productStandards 
				INTO @Name, @DescriptionN
		END;

		CLOSE cursor_temp_productStandards;

		DEALLOCATE cursor_temp_productStandards;
GO

-- 3. OrderStatuses
CREATE PROCEDURE dbo.pMergeTableOrderStatuses    
    @Name nvarchar(70),
	@Description nvarchar(250)
AS   
    SET NOCOUNT ON;  
		MERGE dbo.OrderStatuses AS Target
		USING 
			  (
				SELECT
					tt.Name,
					tt.Description as Description
				FROM (SELECT @Name as Name, @Description as Description) as tt
				left join dbo.OrderStatuses as OrderStatuses
				on tt.Name = OrderStatuses.Name 
					and tt.Description = OrderStatuses.Description
			  ) as Source
			  (
				Name, Description
			  )
			ON (Target.Name = Source.Name)
		WHEN MATCHED 
			THEN UPDATE 
				SET Name = Source.Name, Description = Source.Description
		WHEN NOT MATCHED 
			THEN INSERT 
				(Name, Description)
				VALUES 
				(Source.Name, Source.Description);
		--OUTPUT deleted.*, inserted.*;
GO

CREATE PROCEDURE dbo.pFirstFillTableOrderStatuses    
AS   
    SET NOCOUNT ON;  
		drop table if exists #temp_orderStatuses

		CREATE TABLE #temp_orderStatuses(
			[Name] nvarchar(70)  NOT NULL ,
			[Description] nvarchar(250)  NULL ,
		)

		BULK INSERT #temp_orderStatuses
		FROM 'D:\courses\otus-mssql-sgorshenin\project\Статусы_заказа.csv' 
		WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ';', ROWTERMINATOR = '\n', CODEPAGE = 'ACP', DATAFILETYPE = 'widechar');

		DECLARE @Name nvarchar(70)
		DECLARE @DescriptionN nvarchar(250)

		DECLARE cursor_temp_orderStatuses CURSOR FOR SELECT * FROM #temp_orderStatuses;
		OPEN cursor_temp_orderStatuses;

		FETCH NEXT FROM cursor_temp_orderStatuses 
			INTO @Name, @DescriptionN;

		WHILE @@FETCH_STATUS = 0
		BEGIN
			exec dbo.pMergeTableOrderStatuses @Name, @DescriptionN;
			-- Обработка данных
			FETCH NEXT FROM cursor_temp_orderStatuses 
				INTO @Name, @DescriptionN;
		END;

		CLOSE cursor_temp_orderStatuses;

		DEALLOCATE cursor_temp_orderStatuses;
GO

-- 4. PointsSale
CREATE PROCEDURE dbo.pMergeTablePointsSale
	@SellerID bigint,
	@Name nvarchar(250),
	@Address nvarchar(250),
	@Telephone nvarchar(70)	
AS   
    SET NOCOUNT ON;  
		MERGE dbo.PointsSale AS Target
		USING 
			  (
				SELECT
					tt.SellerID,
					tt.Name,
					tt.Address,
					tt.Telephone 
				FROM (SELECT @SellerID as SellerID, @Name as Name, @Address as Address, @Telephone as Telephone) as tt
				left join dbo.PointsSale as PointsSale
				on tt.SellerID = PointsSale.SellerID 
					and tt.Name = PointsSale.Name
					and tt.Address = PointsSale.Address 
					and tt.Telephone = PointsSale.Telephone 
			  ) as Source
			  (
				SellerID, Name, Address, Telephone
			  )
			ON (Target.SellerID = Source.SellerID
				and Target.Name = Source.Name)
		WHEN MATCHED 
			THEN UPDATE 
				SET SellerID = Source.SellerID, Name = Source.Name, Address = Source.Address, Telephone = Source.Telephone
		WHEN NOT MATCHED 
			THEN INSERT 
				(SellerID, Name, Address, Telephone)
				VALUES 
				(Source.SellerID, Source.Name, Source.Address, Source.Telephone);
		--OUTPUT deleted.*, inserted.*;
GO

CREATE PROCEDURE dbo.pFirstFillTablePointsSale    
AS   
    SET NOCOUNT ON;  
		drop table if exists #temp_pointsSale

		CREATE TABLE #temp_pointsSale (
			[Name] nvarchar(250)   NULL ,
			[INN] nvarchar(70)  NULL ,
			[NamePointsSale] nvarchar(250)   NULL ,
			[Address] nvarchar(250)   NULL ,
			[Telephone] nvarchar(70)  NULL ,
		)

		BULK INSERT #temp_pointsSale 
		FROM 'D:\courses\otus-mssql-sgorshenin\project\Продавцы_Магазины.csv' 
		WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ';', ROWTERMINATOR = '\n', CODEPAGE = 'ACP', DATAFILETYPE = 'widechar');

		DECLARE @SellerID bigint
		DECLARE @Name nvarchar(250)
		DECLARE @Address nvarchar(250)
		DECLARE @Telephone nvarchar(70)

		DECLARE cursor_temp_pointsSale CURSOR FOR 
			select 
				Sellers.ID as SellerID,
				temp_pointsSale.NamePointsSale,
				temp_pointsSale.Address,
				temp_pointsSale.Telephone
			from #temp_pointsSale as temp_pointsSale
			inner join  dbo.Sellers as Sellers
				on temp_pointsSale.Name = Sellers.Name
				and temp_pointsSale.INN = Sellers.INN
		OPEN cursor_temp_pointsSale;

		FETCH NEXT FROM cursor_temp_pointsSale 
			INTO @SellerID, @Name, @Address, @Telephone;

		WHILE @@FETCH_STATUS = 0
		BEGIN
			exec dbo.pMergeTablePointsSale @SellerID, @Name, @Address, @Telephone;
			-- Обработка данных
			FETCH NEXT FROM cursor_temp_pointsSale 
				INTO @SellerID, @Name, @Address, @Telephone;
		END;

		CLOSE cursor_temp_pointsSale;

		DEALLOCATE cursor_temp_pointsSale;
GO

-- 5. PointSaleProducts
CREATE PROCEDURE dbo.pMergeTablePointSaleProducts
	@PointSaleID bigint,
	@ProductStandardID nvarchar(250),
    @ProductInSellerSystemID nvarchar(70)  NULL ,
    @ProductInSellerSystemName nvarchar(250)  NULL ,
    @DescriptionSmall nvarchar(70)  NULL ,
    @DescriptionFull nvarchar(1000)  NULL 
AS   
    SET NOCOUNT ON;  
		MERGE dbo.PointSaleProducts AS Target
		USING 
			  (
				SELECT
					tt.PointSaleID,
					tt.ProductStandardID,
					tt.ProductInSellerSystemID,
					tt.ProductInSellerSystemName,
					tt.DescriptionSmall,
					tt.DescriptionFull 
				FROM (SELECT @PointSaleID as PointSaleID, 
							 @ProductStandardID as ProductStandardID, 
							 @ProductInSellerSystemID as ProductInSellerSystemID, 
							 @ProductInSellerSystemName as ProductInSellerSystemName, 
							 @DescriptionSmall as DescriptionSmall, 
							 @DescriptionFull as DescriptionFull
							 ) as tt
				left join dbo.PointSaleProducts as PointSaleProducts
				on tt.PointSaleID = PointSaleProducts.PointSaleID 
					and tt.ProductStandardID = PointSaleProducts.ProductStandardID
					and tt.ProductInSellerSystemID = PointSaleProducts.ProductInSellerSystemID
			  ) as Source
			  (
				PointSaleID, ProductStandardID, ProductInSellerSystemID, ProductInSellerSystemName, DescriptionSmall, DescriptionFull
			  )
			ON (Target.PointSaleID = Source.PointSaleID
				and Target.ProductStandardID = Source.ProductStandardID
				and Target.ProductInSellerSystemID = Source.ProductInSellerSystemID)
		WHEN MATCHED 
			THEN UPDATE 
				SET PointSaleID = Source.PointSaleID, ProductStandardID = Source.ProductStandardID, ProductInSellerSystemID = Source.ProductInSellerSystemID, ProductInSellerSystemName = Source.ProductInSellerSystemName, DescriptionSmall = Source.DescriptionSmall, DescriptionFull = Source.DescriptionFull 
		WHEN NOT MATCHED 
			THEN INSERT 
				(PointSaleID, ProductStandardID, ProductInSellerSystemID, ProductInSellerSystemName, DescriptionSmall, DescriptionFull)
				VALUES 
				(Source.PointSaleID, Source.ProductStandardID, Source.ProductInSellerSystemID, Source.ProductInSellerSystemName, Source.DescriptionSmall, Source.DescriptionFull);
		--OUTPUT deleted.*, inserted.*;
GO

-- 6. ProductPrices
CREATE PROCEDURE dbo.pInsertTableProductPrices
    @ProductPointSaleID bigint,
    @Price decimal(18,2),
    @PriceUpdateDate datetime2
AS   
    SET NOCOUNT ON;  
		INSERT INTO dbo.ProductPrices (ProductPointSaleID, Price, PriceUpdateDate)
		VALUES (@ProductPointSaleID, @Price, @PriceUpdateDate);
GO

-- 7. ProductRemains
CREATE PROCEDURE dbo.pInsertTableProductRemains
    @ProductPointSaleID bigint,
    @Remains decimal(18,3),
    @RemainsUpdateDate datetime2
AS   
    SET NOCOUNT ON;  
		INSERT INTO dbo.ProductRemains (ProductPointSaleID, Remains, RemainsUpdateDate)
		VALUES (@ProductPointSaleID, @Remains, @RemainsUpdateDate);
GO

-- 8. GetRandomPointSaleProducts
CREATE PROCEDURE dbo.pGetRandomPointSaleProducts
	@rand float,
	@PointSaleID bigint
AS
BEGIN	
	DECLARE @temp_PointSaleProducts TABLE (
		RowNumber INT,
		ID bigint
	);

	DECLARE @ProductPointSaleID bigint
	DECLARE @PointSaleProducts_min bigint
	DECLARE @PointSaleProducts_max bigint

	INSERT INTO @temp_PointSaleProducts
	SELECT 
		ROW_NUMBER() OVER (order by ID) as RowNumber, 
		PointSaleProducts.ID as ID 
	FROM dbo.PointSaleProducts as PointSaleProducts
	WHERE PointSaleProducts.PointSaleID = @PointSaleID

	SELECT 
		@PointSaleProducts_min = MIN(temp_PointSaleProducts.RowNumber),
		@PointSaleProducts_max = MAX(temp_PointSaleProducts.RowNumber)
	FROM @temp_PointSaleProducts as temp_PointSaleProducts

	SET @ProductPointSaleID = dbo.fGetRandomINT(@rand, @PointSaleProducts_min, @PointSaleProducts_max)

	SELECT 
		@ProductPointSaleID = temp_PointSaleProducts.ID 
	FROM @temp_PointSaleProducts as temp_PointSaleProducts
	WHERE temp_PointSaleProducts.RowNumber = @ProductPointSaleID

	RETURN @ProductPointSaleID;
END;
GO