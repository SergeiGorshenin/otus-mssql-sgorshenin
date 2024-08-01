/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, GROUP BY, HAVING".

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
1. Посчитать среднюю цену товара, общую сумму продажи по месяцам.
Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Средняя цена за месяц по всем товарам
* Общая сумма продаж за месяц

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/
select 
	DATEPART(YEAR, Invoices.InvoiceDate) as year_inv
	, DATEPART(MONTH, Invoices.InvoiceDate) as month_inv
	, AVG(InvoiceLines.UnitPrice) as unit_price_avg
	, SUM(InvoiceLines.Quantity * InvoiceLines.UnitPrice) as total_summ
from Sales.Invoices as Invoices
inner join Sales.InvoiceLines as InvoiceLines
on Invoices.InvoiceID = InvoiceLines.InvoiceID
group by DATEPART(YEAR, Invoices.InvoiceDate), DATEPART(MONTH, Invoices.InvoiceDate) 
order by year_inv, month_inv

/*
2. Отобразить все месяцы, где общая сумма продаж превысила 4 600 000

Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Общая сумма продаж

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

declare @total_summ int = 4600000

select 
	DATEPART(YEAR, Invoices.InvoiceDate) as year_inv
	, DATEPART(MONTH, Invoices.InvoiceDate) as month_inv
	, SUM(InvoiceLines.Quantity * InvoiceLines.UnitPrice) as total_summ
from Sales.Invoices as Invoices
inner join Sales.InvoiceLines as InvoiceLines
on Invoices.InvoiceID = InvoiceLines.InvoiceID
group by DATEPART(YEAR, Invoices.InvoiceDate), DATEPART(MONTH, Invoices.InvoiceDate) 
having SUM(InvoiceLines.Quantity * InvoiceLines.UnitPrice) > @total_summ
order by year_inv, month_inv

/*
3. Вывести сумму продаж, дату первой продажи
и количество проданного по месяцам, по товарам,
продажи которых менее 50 ед в месяц.
Группировка должна быть по году,  месяцу, товару.

Вывести:
* Год продажи
* Месяц продажи
* Наименование товара
* Сумма продаж
* Дата первой продажи
* Количество проданного

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

declare @quantity_month int = 50

select 
	DATEPART(YEAR, Invoices.InvoiceDate) as year_inv
	, DATEPART(MONTH, Invoices.InvoiceDate) as month_inv
	, InvoiceLines.Description as goods
	, SUM(InvoiceLines.Quantity * InvoiceLines.UnitPrice) as total_summ
	, MIN(Invoices.InvoiceDate) as first_date_inv
	, SUM(InvoiceLines.Quantity) as quantity
from Sales.Invoices as Invoices
inner join Sales.InvoiceLines as InvoiceLines
on Invoices.InvoiceID = InvoiceLines.InvoiceID
group by DATEPART(YEAR, Invoices.InvoiceDate), DATEPART(MONTH, Invoices.InvoiceDate), InvoiceLines.Description 
having SUM(InvoiceLines.Quantity) > @quantity_month
order by year_inv, month_inv

-- ---------------------------------------------------------------------------
-- Опционально
-- ---------------------------------------------------------------------------
/*
Написать запросы 2-3 так, чтобы если в каком-то месяце не было продаж,
то этот месяц также отображался бы в результатах, но там были нули.
*/

--запрос 2
declare @total_summ int = 4600000;
declare @date_min date;
declare @date_max date;

select top 1 @date_min = min(eomonth(InvoiceDate)) from Sales.Invoices;
select top 1 @date_max = max(eomonth(InvoiceDate)) from Sales.Invoices;

with cte_dates as(
	select top 1 @date_min as invoiceDate
	union all
	select eomonth(invoiceDate, 1)
	FROM cte_dates
	WHERE invoiceDate <= @date_max
)

select 
	DATEPART(YEAR, cte_dates.InvoiceDate) as year_inv
	, DATEPART(MONTH, cte_dates.InvoiceDate) as month_inv
	, isnull(SUM(InvoiceLines.Quantity * InvoiceLines.UnitPrice), 0) as total_summ
from cte_dates as cte_dates
left join Sales.Invoices as Invoices
on cte_dates.InvoiceDate = eomonth(Invoices.InvoiceDate)
left join Sales.InvoiceLines as InvoiceLines
on Invoices.InvoiceID = InvoiceLines.InvoiceID
group by DATEPART(YEAR, cte_dates.InvoiceDate), DATEPART(MONTH, cte_dates.InvoiceDate) 
having isnull(SUM(InvoiceLines.Quantity * InvoiceLines.UnitPrice), 0) > @total_summ 
	or isnull(SUM(InvoiceLines.Quantity * InvoiceLines.UnitPrice), 0) = 0
order by year_inv, month_inv

--запрос 3
declare @quantity_month int = 50;
declare @date_min date;
declare @date_max date;

select top 1 @date_min = min(eomonth(InvoiceDate)) from Sales.Invoices;
select top 1 @date_max = max(eomonth(InvoiceDate)) from Sales.Invoices;

with cte_dates as(
	select top 1 @date_min as invoiceDate
	union all
	select eomonth(invoiceDate, 1)
	FROM cte_dates
	WHERE invoiceDate <= @date_max
)

select 
	DATEPART(YEAR, cte_dates.InvoiceDate) as year_inv
	, DATEPART(MONTH, cte_dates.InvoiceDate) as month_inv
	, InvoiceLines.Description as goods
	, SUM(InvoiceLines.Quantity * InvoiceLines.UnitPrice) as total_summ
	, MIN(Invoices.InvoiceDate) as first_date_inv
	, SUM(InvoiceLines.Quantity) as quantity
from cte_dates as cte_dates
left join Sales.Invoices as Invoices
on cte_dates.InvoiceDate = eomonth(Invoices.InvoiceDate)
left join Sales.InvoiceLines as InvoiceLines
on Invoices.InvoiceID = InvoiceLines.InvoiceID
group by DATEPART(YEAR, cte_dates.InvoiceDate), DATEPART(MONTH, cte_dates.InvoiceDate) , InvoiceLines.Description 
having SUM(InvoiceLines.Quantity) > @quantity_month
	or SUM(InvoiceLines.Quantity) is null
order by year_inv, month_inv