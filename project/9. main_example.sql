USE bazaar
GO

DECLARE @json nvarchar(MAX)
DECLARE @responseJson nvarchar(MAX);
DECLARE @result nvarchar(MAX)

-- Выбор торговой точки
SET @json = N'{"ID":1,"Name":"П"}';
EXEC dbo.pExecFunction @json, 'fGetPointSale', @responseJson OUTPUT;

SELECT * FROM OPENJSON(@responseJson)

-- Выбор товаров торговой точки
SET @json = N'{"PointSaleID":"1","Name":"Б"}';
EXEC dbo.pExecFunction @json, 'getPointSaleProducts', @responseJson OUTPUT;

SELECT * FROM OPENJSON(@responseJson)

-- Информация по товару торговой точки
SET @json = N'{"ID":"1"}';
EXEC dbo.pExecFunction @json, 'getPointSaleProductsPriceRemains', @responseJson OUTPUT;

SELECT * FROM OPENJSON(@responseJson)