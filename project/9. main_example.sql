USE bazaar
GO

DECLARE @json nvarchar(MAX)
DECLARE @responseJson nvarchar(MAX);

-- ����� �������� �����
SET @json = N'{"Name":"�����"}';
SET @responseJson = dbo.fGetPointSale(@json);

SELECT * FROM OPENJSON(@responseJson)

-- ����� ������� �������� �����
SET @json = N'{"PointSaleID":"3","Name":"�"}';
SET @responseJson = dbo.getPointSaleProducts(@json);

SELECT * FROM OPENJSON(@responseJson)

-- ���������� �� ������ �������� �����
SET @json = N'{"ID":"356"}';
SET @responseJson = dbo.getPointSaleProductsPriceRemains(@json, GETDATE());

SELECT * FROM OPENJSON(@responseJson)