USE bazaar
GO

DECLARE @json nvarchar(MAX)
DECLARE @responseJson nvarchar(MAX)

SET @json = N'{"Name":"Пятёро"}';

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
			WHERE PointsSale.Name like JSON_VALUE(@json, '$.Name') + '%'
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