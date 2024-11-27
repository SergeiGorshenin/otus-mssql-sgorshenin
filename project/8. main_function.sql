USE bazaar
GO

IF OBJECT_ID (N'dbo.fGetPointSale', N'FN') IS NOT NULL DROP FUNCTION dbo.fGetPointSale;
IF OBJECT_ID (N'dbo.getPointSaleProducts', N'FN') IS NOT NULL DROP FUNCTION dbo.getPointSaleProducts;
IF OBJECT_ID (N'dbo.getPointSaleProductsPriceRemains', N'FN') IS NOT NULL DROP FUNCTION dbo.getPointSaleProductsPriceRemains;
IF OBJECT_ID (N'pExecFunction', N'P') IS NOT NULL DROP PROCEDURE dbo.pExecFunction;
GO

CREATE FUNCTION fGetPointSale(@json nvarchar(MAX))
RETURNS nvarchar(MAX)
AS
BEGIN
	DECLARE @responseJson nvarchar(MAX);

	DECLARE @Zero bigint
	DECLARE @ValueID bigint
	DECLARE @ValueName nvarchar(MAX)

	SET @Zero	   = CAST(0 as bigint)
	SET @ValueID   = JSON_VALUE(@json, '$.ID')
	SET @ValueName = JSON_VALUE(@json, '$.Name')

	IF ISJSON(@json) = 1
		BEGIN
			SELECT @responseJson = 
			(
				SELECT 
					PointsSale.ID as PointSaleID,
					PointsSale.Name as PointSaleName,
					PointsSale.Telephone as PointSaleTelephone,
					PointsSale.Address as PointSaleAddress,
					Sellers.ID as SellerID,
					Sellers.Name as SellerName
				from dbo.PointsSale as PointsSale
				inner join dbo.Sellers as Sellers
				on PointsSale.SellerID = Sellers.ID
				WHERE 
					(@ValueID IS NOT NULL AND @ValueID <> @Zero
						AND PointsSale.ID = @ValueID)
					OR 
					((@ValueID IS NULL OR @ValueID = @Zero)
						AND @ValueName IS NOT NULL
						AND PointsSale.Name like @ValueName + '%')
				FOR JSON AUTO 
			)
		END;
	ELSE
		BEGIN
			SELECT @responseJson = 
			(
				SELECT
					*
				FROM (SELECT N'Ошибка JSON' AS Message) AS T
				FOR JSON AUTO 
			)
		END;

	RETURN @responseJson;
	END;
GO

CREATE FUNCTION getPointSaleProducts(@json nvarchar(MAX))
RETURNS nvarchar(MAX)
AS
BEGIN
	DECLARE @responseJson nvarchar(MAX);

	DECLARE @ValueID bigint
	DECLARE @ValueName nvarchar(MAX)

	SET @ValueID   = CONVERT(BIGINT, JSON_VALUE(@json, '$.PointSaleID'))
	SET @ValueName = JSON_VALUE(@json, '$.Name')

	IF ISJSON(@json) = 1
	BEGIN
		SELECT @responseJson = 
		(
			SELECT 
				PointSaleProducts.PointSaleID ,
				PointSaleProducts.ID,
				ProductStandards.Name,
				ProductStandards.Description,
				PointSaleProducts.ProductInSellerSystemName AS SellerSystemName,
				PointSaleProducts.DescriptionSmall AS SellerSystemDescriptionSmall,
				PointSaleProducts.DescriptionFull AS SellerSystemDescriptionFull
			FROM dbo.PointSaleProducts AS PointSaleProducts
			INNER JOIN dbo.ProductStandards AS ProductStandards
			ON PointSaleProducts.ProductStandardID = ProductStandards.ID
			WHERE PointSaleProducts.PointSaleID = @ValueID
			AND ProductStandards.Name like @ValueName + '%'
			FOR JSON AUTO 
		)
		END;
	ELSE
		BEGIN
			SELECT @responseJson = 
			(
				SELECT
					*
				FROM (SELECT N'Ошибка JSON' AS Message) AS T
				FOR JSON AUTO 
			)
		END;

	RETURN @responseJson;
	END;
GO

CREATE FUNCTION getPointSaleProductsPriceRemains(@json nvarchar(MAX), @currentDate datetime2)
RETURNS nvarchar(MAX)
AS
BEGIN
	DECLARE @responseJson nvarchar(MAX);
	
	DECLARE @ValueID bigint

	SET @ValueID = CONVERT(BIGINT, JSON_VALUE(@json, '$.ID'))

	IF ISJSON(@json) = 1
		BEGIN
			with cte_price as
			(
				SELECT
					MAX(ProductPrices.ProductPointSaleID) AS ProductPointSaleID,
					MAX(ProductPrices.PriceUpdateDate) AS PriceUpdateDate
				FROM dbo.ProductPrices AS ProductPrices
				WHERE ProductPrices.ProductPointSaleID = @ValueID
				AND ProductPrices.PriceUpdateDate <= @currentDate
			),
			cte_remains as
			(
				SELECT
					MAX(ProductRemains.ProductPointSaleID) AS ProductPointSaleID,
					MAX(ProductRemains.RemainsUpdateDate) AS RemainsUpdateDate
				FROM dbo.ProductRemains AS ProductRemains
				WHERE ProductRemains.ProductPointSaleID = @ValueID
				AND ProductRemains.RemainsUpdateDate <= @currentDate
			)

			SELECT @responseJson = 
			(
				SELECT
					MAX(TT.ID) AS ID,
					MAX(TT.Price) AS Price, 
					MAX(TT.PriceUpdateDate) AS PriceUpdateDate,
					MAX(TT.Remains) AS Remains,
					MAX(TT.RemainsUpdateDate) AS RemainsUpdateDate
				FROM (
					SELECT
						ProductPrices.ID,
						ProductPrices.Price,
						ProductPrices.PriceUpdateDate,
						null AS Remains,
						null AS RemainsUpdateDate
					FROM dbo.ProductPrices AS ProductPrices
					INNER JOIN cte_price AS cte_price
						ON ProductPrices.ProductPointSaleID = cte_price.ProductPointSaleID
						AND ProductPrices.PriceUpdateDate = cte_price.PriceUpdateDate

				UNION ALL

				SELECT
					null,
					null,
					null,
					ProductRemains.Remains,
					ProductRemains.RemainsUpdateDate
				FROM dbo.ProductRemains AS ProductRemains
				INNER JOIN cte_remains AS cte_remains
					ON ProductRemains.ProductPointSaleID = cte_remains.ProductPointSaleID
					AND ProductRemains.RemainsUpdateDate = cte_remains.RemainsUpdateDate
				) AS TT
				FOR JSON AUTO 
			)
		END;
	ELSE
		BEGIN
			SELECT @responseJson = 
			(
				SELECT
					*
				FROM (SELECT N'Ошибка JSON' AS Message) AS T
				FOR JSON AUTO 
			)
		END;
	RETURN @responseJson;
	END;
GO

CREATE PROCEDURE dbo.pExecFunction
	@json nvarchar(MAX),
	@NameFunction nvarchar(MAX),
	@responseJson nvarchar(MAX) out
AS
BEGIN	
	--DECLARE @responseJson nvarchar(MAX);
	
	BEGIN TRY
		IF @NameFunction = 'fGetPointSale'
			BEGIN 
				SET @responseJson = dbo.fGetPointSale(@json);
			END;
		ELSE IF @NameFunction = 'getPointSaleProducts'
			BEGIN 
				SET @responseJson = dbo.getPointSaleProducts(@json);
			END;
		ELSE IF @NameFunction = 'getPointSaleProductsPriceRemains'
			BEGIN 
				SET @responseJson = dbo.getPointSaleProductsPriceRemains(@json, GETDATE());
			END;
		ELSE
			BEGIN
				SET @responseJson = N'Неизвестная функция: ' + @NameFunction;
			END;
	END TRY

	BEGIN CATCH
		SELECT @responseJson = 
			(
				SELECT * FROM
				(
					SELECT 
						ERROR_NUMBER() AS ErrorNumber,
						ERROR_SEVERITY() AS ErrorSeverity,
						ERROR_STATE() AS ErrorState,
						ERROR_PROCEDURE() AS ErrorProcedure,
						ERROR_LINE() AS ErrorLine,
						ERROR_MESSAGE() AS ErrorMessage,
						@json AS TextJson
				) AS errors
				FOR JSON AUTO 
			)
	END CATCH

END;
GO