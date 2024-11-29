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
SET @json = N'{"PointSaleID":1,"Name":"Б"}';
EXEC dbo.pExecFunction @json, 'getPointSaleProducts', @responseJson OUTPUT;

SELECT * FROM OPENJSON(@responseJson)

-- Информация по товару торговой точки
SET @json = N'{"ID":1}';
EXEC dbo.pExecFunction @json, 'getPointSaleProductsPriceRemains', @responseJson OUTPUT;

SELECT * FROM OPENJSON(@responseJson)


-- Пример документа
SELECT TOP 1000
	Orders.ID,
	FORMAT(Orders.Date, 'dd.MM.yyyy hh:mm', 'ru-RU') AS Date,
	Buyers.Name AS Buyer,
	PointsSale.Name AS PointSale,
	OrderStatuses.Name AS Status,
	Orders.DeliveryCourier,
	SUM(LineOrders.QuantityOrdered * LineOrders.Price) AS SummOrdered,
	SUM(LineOrders.QuantityActual * LineOrders.Price) AS SummActual
FROM dbo.Orders AS Orders
	LEFT JOIN dbo.Buyers AS Buyers
	ON Orders.BuyerID = Buyers.ID
	LEFT JOIN dbo.PointsSale AS PointsSale
	ON Orders.PointSaleID = PointsSale.ID
	LEFT JOIN dbo.OrderStatuses AS OrderStatuses
	ON Orders.OrderStatusID = OrderStatuses.ID
	LEFT JOIN dbo.LineOrders AS LineOrders
	ON Orders.ID = LineOrders.OrderID
WHERE Orders.ID = 1
GROUP BY Orders.ID, Date, Buyers.Name, PointsSale.Name, OrderStatuses.Name, Orders.DeliveryCourier

SELECT
	LineOrders.OrderID,
	ProductStandards.Name AS Product, 
	LineOrders.QuantityOrdered,
	LineOrders.QuantityActual,
	LineOrders.Price,
	LineOrders.QuantityOrdered * LineOrders.Price AS SummOrdered,
	LineOrders.QuantityActual * LineOrders.Price AS SummActual
FROM dbo.LineOrders AS LineOrders
	LEFT JOIN dbo.PointSaleProducts AS PointSaleProducts
	ON LineOrders.ProductPointSaleID = PointSaleProducts.ID
	LEFT JOIN dbo.ProductStandards AS ProductStandards
	ON PointSaleProducts.ProductStandardID = ProductStandards.ID
WHERE LineOrders.OrderID = 1

SELECT
	ProductStandards.Name AS Product, 
	ProductPrices.Price,
	FORMAT(ProductPrices.PriceUpdateDate, 'dd.MM.yyyy hh:mm', 'ru-RU') AS Date
FROM dbo.ProductPrices AS ProductPrices
	LEFT JOIN dbo.PointSaleProducts AS PointSaleProducts
	ON ProductPrices.ProductPointSaleID = PointSaleProducts.ID
	LEFT JOIN dbo.ProductStandards AS ProductStandards
	ON PointSaleProducts.ProductStandardID = ProductStandards.ID
WHERE ProductPrices.ProductPointSaleID = 1
ORDER BY Date