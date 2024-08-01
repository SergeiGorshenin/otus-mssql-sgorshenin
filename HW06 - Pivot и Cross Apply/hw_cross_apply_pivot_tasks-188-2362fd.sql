/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "05 - Операторы CROSS APPLY, PIVOT, UNPIVOT".

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
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Клиентов взять с ID 2-6, это все подразделение Tailspin Toys.
Имя клиента нужно поменять так чтобы осталось только уточнение.
Например, исходное значение "Tailspin Toys (Gasport, NY)" - вы выводите только "Gasport, NY".
Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+-------------+--------------+------------
InvoiceMonth | Peeples Valley, AZ | Medicine Lodge, KS | Gasport, NY | Sylvanite, MT | Jessie, ND
-------------+--------------------+--------------------+-------------+--------------+------------
01.01.2013   |      3             |        1           |      4      |      2        |     2
01.02.2013   |      7             |        3           |      4      |      2        |     1
-------------+--------------------+--------------------+-------------+--------------+------------
*/

with pivot_cte as(
	select 
		InvoiceMonth,
		[Gasport, NY], [Jessie, ND], [Medicine Lodge, KS], [Peeples Valley, AZ], [Sylvanite, MT]
	from 
	--(select InvoiceMonth, CustomerName, CountInvoiceID from #invoices)
	(select 
		REPLACE(REPLACE(Customers.CustomerName, 'Tailspin Toys (', ''), ')', '') as CustomerName,
		DATETRUNC(month, Invoices.InvoiceDate) as InvoiceMonth,
		count(Invoices.InvoiceID) as CountInvoiceID
	from Sales.Invoices as Invoices
	left join Sales.Customers as Customers
		on Invoices.CustomerID = Customers.CustomerID
	where Invoices.CustomerID between 2 and 6
	group by REPLACE(REPLACE(Customers.CustomerName, 'Tailspin Toys (', ''), ')', ''), DATETRUNC(month, Invoices.InvoiceDate)
	)
	as SourceTable
	pivot
	(
	max(CountInvoiceID)
	for CustomerName
	in ([Gasport, NY], [Jessie, ND], [Medicine Lodge, KS], [Peeples Valley, AZ], [Sylvanite, MT])
	)
	as PivotTable
)

select
	format(pivot_cte.InvoiceMonth, 'dd.MM.yyyy') as InvoiceMonth,
	pivot_cte.[Gasport, NY],
	pivot_cte.[Jessie, ND],
	pivot_cte.[Medicine Lodge, KS],
	pivot_cte.[Peeples Valley, AZ],
	pivot_cte.[Sylvanite, MT]
from pivot_cte
order by pivot_cte.InvoiceMonth

/*
2. Для всех клиентов с именем, в котором есть "Tailspin Toys"
вывести все адреса, которые есть в таблице, в одной колонке.

Пример результата:
----------------------------+--------------------
CustomerName                | AddressLine
----------------------------+--------------------
Tailspin Toys (Head Office) | Shop 38
Tailspin Toys (Head Office) | 1877 Mittal Road
Tailspin Toys (Head Office) | PO Box 8975
Tailspin Toys (Head Office) | Ribeiroville
----------------------------+--------------------
*/

select CustomerName, AddressLine
from (select
	Customers.CustomerName,
	Customers.DeliveryAddressLine1,
	Customers.DeliveryAddressLine2,
	Customers.PostalAddressLine1,
	Customers.PostalAddressLine2
from Sales.Customers as Customers
where Customers.CustomerName like 'Tailspin Toys%') as t
unpivot
(
AddressLine for CustomerName1 in (t.DeliveryAddressLine1,t.DeliveryAddressLine2,t.PostalAddressLine1,PostalAddressLine2)
) as T_unpivot

/*
3. В таблице стран (Application.Countries) есть поля с цифровым кодом страны и с буквенным.
Сделайте выборку ИД страны, названия и ее кода так, 
чтобы в поле с кодом был либо цифровой либо буквенный код.

Пример результата:
--------------------------------
CountryId | CountryName | Code
----------+-------------+-------
1         | Afghanistan | AFG
1         | Afghanistan | 4
3         | Albania     | ALB
3         | Albania     | 8
----------+-------------+-------
*/

select CountryID, CountryName, Code
from (select
	Countries.CountryID,
	Countries.CountryName,
	CAST(Countries.IsoAlpha3Code as CHAR(10)) as IsoAlpha3Code,
	CAST(Countries.IsoNumericCode as CHAR(10)) as IsoNumericCode
	from Application.Countries as Countries) as t
unpivot
(
Code for CountryID1 in (t.IsoAlpha3Code,t.IsoNumericCode)
) as T_unpivot



/*
4. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

select distinct
	Customers_1.CustomerID,
	Customers_1.CustomerName as CustomerName,
	StockItems_1.StockItemID,
	StockItems_1.StockItemName,
	StockItems_1.UnitPrice,
	StockItems_1.InvoiceDate
from Sales.Customers as Customers_1
CROSS APPLY 
	(
		select distinct top 2 with ties 
		max(Invoices.InvoiceDate) over (partition by Invoices.CustomerID, StockItems.StockItemID order by Invoices.InvoiceDate desc) InvoiceDate,
		StockItems.StockItemID,
		StockItems.StockItemName,
		StockItems.UnitPrice
		from Sales.Invoices as Invoices
		inner join Sales.InvoiceLines as InvoiceLines
			on Invoices.InvoiceID = InvoiceLines.InvoiceID
		inner join Warehouse.StockItems as StockItems
			on InvoiceLines.StockItemID = StockItems.StockItemID
		where Invoices.CustomerID = Customers_1.CustomerID
		ORDER BY StockItems.UnitPrice DESC
	) AS StockItems_1
order by 1, 3 desc, 5 desc
