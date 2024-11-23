USE bazaar
GO

DECLARE @currentDate datetime2
DECLARE @json nvarchar(MAX)
DECLARE @responseJson nvarchar(MAX)

SET @currentDate = GETDATE()
SET @json = N'{"ID":"356"}'

IF ISJSON(@json) = 1
	BEGIN
		with cte_price as
		(
			SELECT
				MAX(ProductPrices.ProductPointSaleID) AS ProductPointSaleID,
				MAX(ProductPrices.PriceUpdateDate) AS PriceUpdateDate
			FROM dbo.ProductPrices AS ProductPrices
			WHERE ProductPrices.ProductPointSaleID = CONVERT(BIGINT, JSON_VALUE(@json, '$.ID'))
			AND ProductPrices.PriceUpdateDate <= @currentDate
		),
		cte_remains as
		(
			SELECT
				MAX(ProductRemains.ProductPointSaleID) AS ProductPointSaleID,
				MAX(ProductRemains.RemainsUpdateDate) AS RemainsUpdateDate
			FROM dbo.ProductRemains AS ProductRemains
			WHERE ProductRemains.ProductPointSaleID = CONVERT(BIGINT, JSON_VALUE(@json, '$.ID'))
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

print(@responseJson)