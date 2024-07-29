/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "07 - Динамический SQL".

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

Это задание из занятия "Операторы CROSS APPLY, PIVOT, UNPIVOT."
Нужно для него написать динамический PIVOT, отображающий результаты по всем клиентам.
Имя клиента указывать полностью из поля CustomerName.

Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+----------------+----------------------
InvoiceMonth | Aakriti Byrraju    | Abel Spirlea       | Abel Tatarescu | ... (другие клиенты)
-------------+--------------------+--------------------+----------------+----------------------
01.01.2013   |      3             |        1           |      4         | ...
01.02.2013   |      7             |        3           |      4         | ...
-------------+--------------------+--------------------+----------------+----------------------
*/

declare @CustomerName varchar(100) = 'Tailspin Toys'
		, @CustomerNames as nvarchar(MAX) = '';

if @CustomerName = '' set @CustomerName = 'null';

select
	@CustomerNames = @CustomerNames + CustomerName + ','
from  (
		select distinct top 10
			QUOTENAME(REPLACE(REPLACE(Customers.CustomerName, @CustomerName + ' (', ''), ')', '')) as CustomerName
		from Sales.Invoices as Invoices
		inner join Sales.Customers as Customers
			on Invoices.CustomerID = Customers.CustomerID
		where Customers.CustomerName like @CustomerName + '%'
		) as Invoices

declare @dyn_sql AS NVARCHAR(MAX)

set @CustomerNames = left(@CustomerNames, len(@CustomerNames) - 1)

set @dyn_sql = 
	N'select 
		format(InvoiceMonth, ''dd.MM.yyyy'') as InvoiceMonth_1,' + @CustomerNames + '
	from 
	(select distinct
		REPLACE(REPLACE(Customers.CustomerName, ''' + @CustomerName + ''' + '' ('', ''''), '')'', '''') as CustomerName,
		DATETRUNC(month, Invoices.InvoiceDate) as InvoiceMonth,
		count(Invoices.InvoiceID) as CountInvoiceID
	from Sales.Invoices as Invoices
	inner join Sales.Customers as Customers
			on Invoices.CustomerID = Customers.CustomerID			
	where Customers.CustomerName like '''+ @CustomerName + ''' + ''%''
	group by REPLACE(REPLACE(Customers.CustomerName, ''' + @CustomerName + ''' + '' ('', ''''), '')'', ''''), DATETRUNC(month, Invoices.InvoiceDate) 
	)
	as SourceTable
	pivot
	(
	max(CountInvoiceID)
	for CustomerName
	in ('+ @CustomerNames + ')
	)
	as PivotTable
	order by InvoiceMonth'

select @dyn_sql

EXEC sp_executesql @dyn_sql