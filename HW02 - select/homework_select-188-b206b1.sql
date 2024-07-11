/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, JOIN".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД WideWorldImporters можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Все товары, в названии которых есть "urgent" или название начинается с "Animal".
Вывести: ИД товара (StockItemID), наименование товара (StockItemName).
Таблицы: Warehouse.StockItems.
*/

SELECT 
	StockItemID
	, StockItemName
FROM   Warehouse.StockItems
WHERE (StockItemName LIKE '%urgent%') OR
             (StockItemName LIKE 'Animal%')

/*
2. Поставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders).
Сделать через JOIN, с подзапросом задание принято не будет.
Вывести: ИД поставщика (SupplierID), наименование поставщика (SupplierName).
Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders.
По каким колонкам делать JOIN подумайте самостоятельно.
*/

SELECT 
	Suppliers.SupplierID
	, Suppliers.SupplierName
FROM   Purchasing.Suppliers AS Suppliers 
		LEFT JOIN Purchasing.PurchaseOrders AS PurchaseOrders 
		ON Suppliers.SupplierID = PurchaseOrders.SupplierID
WHERE (PurchaseOrders.PurchaseOrderID IS NULL)


/*
3. Заказы (Orders) с ценой товара (UnitPrice) более 100$ 
либо количеством единиц (Quantity) товара более 20 штук
и присутствующей датой комплектации всего заказа (PickingCompletedWhen).
Вывести:
* OrderID
* дату заказа (OrderDate) в формате ДД.ММ.ГГГГ
* название месяца, в котором был сделан заказ
* номер квартала, в котором был сделан заказ
* треть года, к которой относится дата заказа (каждая треть по 4 месяца)
* имя заказчика (Customer)
Добавьте вариант этого запроса с постраничной выборкой,
пропустив первую 1000 и отобразив следующие 100 записей.

Сортировка должна быть по номеру квартала, трети года, дате заказа (везде по возрастанию).

Таблицы: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/

SELECT DISTINCT
	Orders.OrderID
	, FORMAT(Orders.OrderDate, 'dd.MM.yyyy', 'ru-RU') as OrderDate
	, FORMAT(Orders.OrderDate, 'MMMM', 'ru-RU') as NameMonth
	, DATEPART(QUARTER, Orders.OrderDate) as NumberQuarter
	, CEILING(cast(DATEPART(MONTH, Orders.OrderDate) as float)/4) as ThirdOfTheYear
	, Customers.CustomerName
FROM   Sales.Orders AS Orders 
		INNER JOIN Sales.OrderLines AS OrderLines 
			ON Orders.OrderID = OrderLines.OrderID
		LEFT JOIN Sales.Customers AS Customers 
			ON Orders.CustomerID = Customers.CustomerID 
WHERE (OrderLines.UnitPrice > 100 OR OrderLines.Quantity > 20) 
		AND (NOT (Orders.PickingCompletedWhen IS NULL))
ORDER BY 4, 5, 1

/*Добавьте вариант этого запроса с постраничной выборкой,
пропустив первую 1000 и отобразив следующие 100 записей.*/

declare @offset_rows int = 1000, @fetch_next_rows int = 100 

SELECT DISTINCT
	Orders.OrderID
	, FORMAT(Orders.OrderDate, 'dd.MM.yyyy', 'ru-RU') as OrderDate
	, FORMAT(Orders.OrderDate, 'MMMM', 'ru-RU') as NameMonth
	, DATEPART(QUARTER, Orders.OrderDate) as NumberQuarter
	, CEILING(cast(DATEPART(MONTH, Orders.OrderDate) as float)/4) as ThirdOfTheYear
	, Customers.CustomerName
FROM   Sales.Orders AS Orders 
		INNER JOIN Sales.OrderLines AS OrderLines 
			ON Orders.OrderID = OrderLines.OrderID
		LEFT JOIN Sales.Customers AS Customers 
			ON Orders.CustomerID = Customers.CustomerID 
WHERE (OrderLines.UnitPrice > 100 OR OrderLines.Quantity > 20) 
		AND (NOT (Orders.PickingCompletedWhen IS NULL))
ORDER BY 4, 5, 1
ASC OFFSET @offset_rows rows
fetch next @fetch_next_rows rows only 


/*
4. Заказы поставщикам (Purchasing.Suppliers),
которые должны быть исполнены (ExpectedDeliveryDate) в январе 2013 года
с доставкой "Air Freight" или "Refrigerated Air Freight" (DeliveryMethodName)
и которые исполнены (IsOrderFinalized).
Вывести:
* способ доставки (DeliveryMethodName)
* дата доставки (ExpectedDeliveryDate)
* имя поставщика
* имя контактного лица принимавшего заказ (ContactPerson)

Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/

SELECT DISTINCT
	PurchaseOrders.PurchaseOrderID
	, PurchaseOrders.ExpectedDeliveryDate
	, Suppliers.SupplierName
	, People.FullName AS ContactPerson
FROM   Purchasing.PurchaseOrders AS PurchaseOrders 
		INNER JOIN Purchasing.Suppliers AS Suppliers 
			ON PurchaseOrders.SupplierID = Suppliers.SupplierID 
		INNER JOIN Application.DeliveryMethods AS DeliveryMethods 
			ON PurchaseOrders.DeliveryMethodID = DeliveryMethods.DeliveryMethodID 
		INNER JOIN Application.People AS People
			ON PurchaseOrders.ContactPersonID = People.PersonID
WHERE PurchaseOrders.ExpectedDeliveryDate BETWEEN  '2013-01-01' AND '2013-01-31'
		AND PurchaseOrders.IsOrderFinalized = 1 		
		AND DeliveryMethods.DeliveryMethodName IN ('Air Freight', 'Refrigerated Air Freight')
	

/*
5. Десять последних продаж (по дате продажи) с именем клиента и именем сотрудника,
который оформил заказ (SalespersonPerson).
Сделать без подзапросов.
*/

SELECT TOP (10)
	Orders.OrderID
	, Customers.CustomerName
	, People.FullName AS SalespersonPerson
FROM Sales.Orders AS Orders 
	LEFT OUTER JOIN	Sales.Customers AS Customers 
		ON Orders.CustomerID = Customers.CustomerID
	LEFT OUTER JOIN Application.People AS People
		ON Orders.SalespersonPersonID = People.PersonID
ORDER BY Orders.OrderDate DESC

             
/*
6. Все ид и имена клиентов и их контактные телефоны,
которые покупали товар "Chocolate frogs 250g".
Имя товара смотреть в таблице Warehouse.StockItems.
*/

SELECT DISTINCT 
	Customers.CustomerID
	, Customers.CustomerName
	, Customers.PhoneNumber
FROM   Sales.Customers AS Customers 
		INNER JOIN Sales.Orders AS Orders 
			ON Orders.CustomerID = Customers.CustomerID 
		INNER JOIN Sales.OrderLines AS OrderLines 
			ON OrderLines.OrderID = Orders.OrderID
WHERE (OrderLines.Description = 'Chocolate frogs 250g')
