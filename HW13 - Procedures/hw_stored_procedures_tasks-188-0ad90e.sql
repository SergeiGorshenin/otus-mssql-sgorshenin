/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "12 - Хранимые процедуры, функции, триггеры, курсоры".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

USE WideWorldImporters

/*
Во всех заданиях написать хранимую процедуру / функцию и продемонстрировать ее использование.
*/

/*
1) Написать функцию возвращающую Клиента с наибольшей суммой покупки.
*/

IF OBJECT_ID (N'dbo.fGetClientWithMaxSumm', N'FN') IS NOT NULL
	DROP FUNCTION dbo.fGetClientWithMaxSumm;
GO
CREATE FUNCTION dbo.fGetClientWithMaxSumm()
RETURNS TABLE
AS 
RETURN
(
	with preselect as 
	(
		select distinct top 1
			Invoices.InvoiceID,
			Invoices.CustomerID,
			sum(InvoiceLines.Quantity * InvoiceLines.UnitPrice) as summ
		from Sales.Invoices as Invoices
		left join Sales.InvoiceLines as InvoiceLines
		on Invoices.InvoiceID = InvoiceLines.InvoiceID
		left join Sales.Customers as Customers
		on Invoices.CustomerID = Customers.CustomerID
		group by Invoices.InvoiceID, Invoices.CustomerID
		order by summ desc
	)

	select 
		preselect.CustomerId, 
		Customers.CustomerName 
	from preselect as preselect
	left join Sales.Customers as Customers
	on preselect.CustomerID = Customers.CustomerID
);
GO

select * from dbo.fGetClientWithMaxSumm();


/*
2) Написать хранимую процедуру с входящим параметром СustomerID, выводящую сумму покупки по этому клиенту.
Использовать таблицы :
Sales.Customers
Sales.Invoices
Sales.InvoiceLines
*/

IF OBJECT_ID ( 'dbo.pGetClientSumm', 'P' ) IS NOT NULL   
    DROP PROCEDURE dbo.pGetClientSumm; 
GO
CREATE PROCEDURE dbo.pGetClientSumm    
    @CustomerID int 
AS   
    SET NOCOUNT ON;  
select 
	sum(UnitPrice*Quantity) as Summ 
from Sales.Customers as Customers 
	inner join Sales.Invoices as Invoices 
	on Customers.CustomerID = Invoices.CustomerID
	inner join Sales.InvoiceLines as InvoiceLines 
	on InvoiceLines.InvoiceID = Invoices.InvoiceID
where Invoices.CustomerID = @CustomerID
GO 

exec dbo.pGetClientSumm @CustomerId = 834

/*
3) Создать одинаковую функцию и хранимую процедуру, посмотреть в чем разница в производительности и почему.
*/

IF OBJECT_ID (N'dbo.fGetClientSumm_test', N'FN') IS NOT NULL
	DROP FUNCTION dbo.fGetClientSumm_test;
GO
CREATE FUNCTION dbo.fGetClientSumm_test(@CustomerId int)
RETURNS TABLE  
AS
RETURN 
(
	select top 1 
		sum(UnitPrice*Quantity) as Summ 
	from Sales.Customers as Customers 
		inner join Sales.Invoices as Invoices 
		on Customers.CustomerID = Invoices.CustomerID
		inner join Sales.InvoiceLines as InvoiceLines 
		on InvoiceLines.InvoiceID = Invoices.InvoiceID
	where Invoices.CustomerID = @CustomerID
);
GO

IF OBJECT_ID ( 'dbo.pGetClientSumm_test', 'P' ) IS NOT NULL   
    DROP PROCEDURE dbo.pGetClientSumm_test; 
GO
CREATE PROCEDURE dbo.pGetClientSumm_test    
    @CustomerID int 
AS   
    SET NOCOUNT ON;  
select 
	sum(UnitPrice*Quantity) as Summ 
from Sales.Customers as Customers 
	inner join Sales.Invoices as Invoices 
	on Customers.CustomerID = Invoices.CustomerID
	inner join Sales.InvoiceLines as InvoiceLines 
	on InvoiceLines.InvoiceID = Invoices.InvoiceID
where Invoices.CustomerID = @CustomerID
GO 

SET STATISTICS io ON
SET STATISTICS time ON
DBCC DROPCLEANBUFFERS WITH NO_INFOMSGS;
SET NOCOUNT ON

select * from dbo.fGetClientSumm_test(834);
exec dbo.pGetClientSumm @CustomerId = 834;

/*
Функции работают быстрее потому что занимаются только вычислением и возвратом полученного значения 

 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 10 ms.
 --------------------------------------------------------
 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 8 ms.

 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 45 ms.
*/
/*
4) Создайте табличную функцию покажите как ее можно вызвать для каждой строки result set'а без использования цикла. 
*/

IF OBJECT_ID (N'dbo.fGetGoodsCustomer', N'IF') IS NOT NULL
    DROP FUNCTION dbo.fGetGoodsCustomer;
GO
CREATE FUNCTION dbo.fGetGoodsCustomer(@CustomerId int)
RETURNS TABLE
AS
RETURN
(
	select  
		count(*) CountInvoices
	from Sales.Invoices
	where CustomerID = @CustomerId
);
go

select
	Customers.CustomerID, 
	Customers.CustomerName,
	GoodsCustomer.CountInvoices
from Sales.Customers as Customers 
CROSS APPLY dbo.fGetGoodsCustomer(Customers.CustomerID) GoodsCustomer
ORDER BY Customers.CustomerID;

/*
5) Опционально. Во всех процедурах укажите какой уровень изоляции транзакций вы бы использовали и почему. 
*/

--READ_COMMITTED_SNAPSHOT ON