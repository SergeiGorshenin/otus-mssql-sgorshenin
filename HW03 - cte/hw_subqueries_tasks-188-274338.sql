/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "03 - Подзапросы, CTE, временные таблицы".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- Для всех заданий, где возможно, сделайте два варианта запросов:
--  1) через вложенный запрос
--  2) через WITH (для производных таблиц)
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Выберите сотрудников (Application.People), которые являются продажниками (IsSalesPerson), 
и не сделали ни одной продажи 04 июля 2015 года. 
Вывести ИД сотрудника и его полное имя. 
Продажи смотреть в таблице Sales.Invoices.
*/

select distinct
	People.PersonID
	, People.FullName
from Application.People as People
where not exists (
		select distinct
		SalespersonPersonID 
		from Sales.Invoices as Invoices 
		where Invoices.InvoiceDate = '20150704'
			and SalespersonPersonID = People.PersonID)
	and People.IsSalesPerson = 1

/*
2. Выберите товары с минимальной ценой (подзапросом). Сделайте два варианта подзапроса. 
Вывести: ИД товара, наименование товара, цена.
*/

select 
    StockItems.StockItemID
	, StockItems.StockItemName
	, StockItems.UnitPrice
from Warehouse.StockItems as StockItems
where StockItems.UnitPrice in (select min(StockItems.UnitPrice) from Warehouse.StockItems)

select 
    StockItems.StockItemID, 
    StockItems.StockItemName,
    StockItems.UnitPrice
from Warehouse.StockItems as StockItems
where StockItems.UnitPrice <= ALL(select StockItems.UnitPrice from Warehouse.StockItems as StockItems)

/*
3. Выберите информацию по клиентам, которые перевели компании пять максимальных платежей 
из Sales.CustomerTransactions. 
Представьте несколько способов (в том числе с CTE). 
*/

select distinct 
	Customers.CustomerID
	, Customers.CustomerName
from Sales.Customers as Customers
inner join
		(select top 5 
			CustomerTransactions.CustomerID
			, CustomerTransactions.TransactionAmount
		from Sales.CustomerTransactions as CustomerTransactions
		order by CustomerTransactions.TransactionAmount desc
		) as CustomerTransactions on CustomerTransactions.CustomerID = Customers.CustomerID

select Customers.CustomerID
	, Customers.CustomerName
from Sales.Customers as Customers
where Customers.CustomerID in (
	select top 5 
		CustomerTransactions.CustomerID
    from Sales.CustomerTransactions as CustomerTransactions
    order by CustomerTransactions.TransactionAmount desc)

;

with cte_top_5_max as 
	(
		select top 5 
			CustomerTransactions.CustomerID
		from Sales.CustomerTransactions as CustomerTransactions
		order by CustomerTransactions.TransactionAmount desc
	)

select distinct 
	Customers.CustomerID
	, Customers.CustomerName
from Sales.Customers as Customers
inner join cte_top_5_max as cte_top_5_max 
on cte_top_5_max.CustomerID = Customers.CustomerID

/*
4. Выберите города (ид и название), в которые были доставлены товары, 
входящие в тройку самых дорогих товаров, а также имя сотрудника, 
который осуществлял упаковку заказов (PackedByPersonID).
*/

select distinct 
	Customers.DeliveryCityID
    , Cities.CityName
    , People.PersonID
    , People.FullName
from Sales.Invoices as Invoices
inner join Sales.Customers as Customers on Customers.CustomerID = Invoices.CustomerID
inner join Sales.InvoiceLines as InvoiceLines on InvoiceLines.InvoiceID = Invoices.InvoiceID
inner join Application.Cities as Cities on Cities.CityID = Customers.DeliveryCityID
inner join Application.People as People on People.PersonID = Invoices.PackedByPersonID
where InvoiceLines.StockItemID in (select top 3 StockItemID from Warehouse.StockItems order by UnitPrice desc)

;

with cte_top_3_max as
(
    select top 3 with ties  
		StockItemID from Warehouse.StockItems order by UnitPrice desc
)

select distinct 
	Customers.DeliveryCityID
    , Cities.CityName
    , People.PersonID
    , People.FullName
from Sales.Invoices as Invoices
inner join Sales.Customers as Customers on Customers.CustomerID = Invoices.CustomerID
inner join Sales.InvoiceLines as InvoiceLines on InvoiceLines.InvoiceID = Invoices.InvoiceID
inner join Application.Cities as Cities on Cities.CityID = Customers.DeliveryCityID
inner join Application.People as People on People.PersonID = Invoices.PackedByPersonID
inner join cte_top_3_max on cte_top_3_max.StockItemID = InvoiceLines.StockItemID

-- ---------------------------------------------------------------------------
-- Опциональное задание
-- ---------------------------------------------------------------------------
-- Можно двигаться как в сторону улучшения читабельности запроса, 
-- так и в сторону упрощения плана\ускорения. 
-- Сравнить производительность запросов можно через SET STATISTICS IO, TIME ON. 
-- Если знакомы с планами запросов, то используйте их (тогда к решению также приложите планы). 
-- Напишите ваши рассуждения по поводу оптимизации. 

-- 5. Объясните, что делает и оптимизируйте запрос

SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	(SELECT People.FullName
		FROM Application.People
		WHERE People.PersonID = Invoices.SalespersonPersonID
	) AS SalesPersonName,
	SalesTotals.TotalSumm AS TotalSummByInvoice, 
	(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
		FROM Sales.OrderLines
		WHERE OrderLines.OrderId = (SELECT Orders.OrderId 
			FROM Sales.Orders
			WHERE Orders.PickingCompletedWhen IS NOT NULL	
				AND Orders.OrderId = Invoices.OrderId)	
	) AS TotalSummForPickedItems
FROM Sales.Invoices 
	JOIN
	(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
		ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC

-- --
/* 
Запрос выбирает Инвойсы, сумма которых больше 27000
Результат запроса показывает ID инвойса, Дату инвойса, Имя продавца, Сумму инвойса, Общая сумма заказанных товаров
*/

drop table if exists #invoices
drop table if exists #orders

SELECT 
	InvoiceLines.InvoiceId, 
	Invoices.OrderId,
	Invoices.InvoiceDate,
	People.FullName AS SalesPersonName,
	SUM(InvoiceLines.Quantity*InvoiceLines.UnitPrice) AS TotalSummByInvoice
INTO #invoices
FROM Sales.InvoiceLines as InvoiceLines
INNER JOIN Sales.Invoices as Invoices
ON Invoices.InvoiceID = InvoiceLines.InvoiceID
LEFT JOIN Application.People as People
ON People.PersonID = Invoices.SalespersonPersonID
GROUP BY InvoiceLines.InvoiceId, Invoices.OrderId, Invoices.InvoiceDate, Invoices.SalespersonPersonID, People.FullName
HAVING SUM(Quantity*UnitPrice) > 27000

SELECT 
	OrderLines.OrderId, 
	SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice) as TotalSummForPickedItems
INTO #orders
FROM Sales.OrderLines as OrderLines
inner join Sales.Orders as Orders
on OrderLines.OrderId = Orders.OrderId
and Orders.PickingCompletedWhen IS NOT NULL
WHERE Orders.OrderId in (select OrderId from #invoices)
GROUP BY OrderLines.OrderId

select 
	invoices.InvoiceId,
	invoices.InvoiceDate,
	invoices.SalesPersonName,
	invoices.TotalSummByInvoice,
	isnull(orders.TotalSummForPickedItems, 0) as TotalSummForPickedItems
from #invoices as invoices
left join #orders as orders
on invoices.OrderId = orders.OrderId
ORDER BY TotalSummByInvoice DESC

-- CTE

with invoices as
(
	SELECT 
		InvoiceLines.InvoiceId, 
		Invoices.OrderId,
		Invoices.InvoiceDate,
		People.FullName AS SalesPersonName,
		SUM(InvoiceLines.Quantity*InvoiceLines.UnitPrice) AS TotalSummByInvoice
	FROM Sales.InvoiceLines as InvoiceLines
	INNER JOIN Sales.Invoices as Invoices
	ON Invoices.InvoiceID = InvoiceLines.InvoiceID
	LEFT JOIN Application.People as People
	ON People.PersonID = Invoices.SalespersonPersonID
	GROUP BY InvoiceLines.InvoiceId, Invoices.OrderId, Invoices.InvoiceDate, Invoices.SalespersonPersonID, People.FullName
	HAVING SUM(Quantity*UnitPrice) > 27000
)
, orders as
(
	SELECT 
		OrderLines.OrderId, 
		SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice) as TotalSummForPickedItems
	FROM Sales.OrderLines as OrderLines
	inner join Sales.Orders as Orders
	on OrderLines.OrderId = Orders.OrderId
	and Orders.PickingCompletedWhen IS NOT NULL
	WHERE Orders.OrderId in (select OrderId from invoices)
	GROUP BY OrderLines.OrderId
)

select 
	invoices.InvoiceId,
	invoices.InvoiceDate,
	invoices.SalesPersonName,
	invoices.TotalSummByInvoice,
	isnull(orders.TotalSummForPickedItems, 0) as TotalSummForPickedItems
from invoices as invoices
left join orders as orders
on invoices.OrderId = orders.OrderId
ORDER BY TotalSummByInvoice DESC