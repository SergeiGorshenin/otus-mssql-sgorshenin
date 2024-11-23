USE bazaar
GO

DECLARE @json nvarchar(MAX)
DECLARE @responseJson nvarchar(MAX);

-- Выбор торговой точки
SET @json = N'{"Name":"Пятёро"}';
SET @responseJson = dbo.fGetPointSale(@json);

SELECT * FROM OPENJSON(@responseJson)

-- Выбор товаров торговой точки
SET @json = N'{"PointSaleID":"3","Name":"Б"}';
SET @responseJson = dbo.getPointSaleProducts(@json);

SELECT * FROM OPENJSON(@responseJson)

-- Информация по товару торговой точки
SET @json = N'{"ID":"356"}';
SET @responseJson = dbo.getPointSaleProductsPriceRemains(@json, GETDATE());

SELECT * FROM OPENJSON(@responseJson)