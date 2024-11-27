USE bazaar
GO

DECLARE @json nvarchar(MAX)
DECLARE @responseJson nvarchar(MAX);
DECLARE @result nvarchar(MAX)

-- ����� �������� �����
SET @json = N'{"ID":1,"Name":"�"}';
EXEC dbo.pExecFunction @json, 'fGetPointSale', @responseJson OUTPUT;

SELECT * FROM OPENJSON(@responseJson)

-- ����� ������� �������� �����
SET @json = N'{"PointSaleID":"1","Name":"�"}';
EXEC dbo.pExecFunction @json, 'getPointSaleProducts', @responseJson OUTPUT;

SELECT * FROM OPENJSON(@responseJson)

-- ���������� �� ������ �������� �����
SET @json = N'{"ID":"1"}';
EXEC dbo.pExecFunction @json, 'getPointSaleProductsPriceRemains', @responseJson OUTPUT;

SELECT * FROM OPENJSON(@responseJson)