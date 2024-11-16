USE bazaar
GO

DECLARE @json nvarchar(MAX)
DECLARE @responseJson nvarchar(MAX)

SET @json = N'{"PointSaleID":"3","Name":"Б"}';

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
			WHERE PointSaleProducts.PointSaleID = CONVERT(BIGINT, JSON_VALUE(@json, '$.PointSaleID'))
			AND ProductStandards.Name like JSON_VALUE(@json, '$.Name') + '%'
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