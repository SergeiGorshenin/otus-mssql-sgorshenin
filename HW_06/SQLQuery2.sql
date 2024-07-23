use WideWorldImporters

/*
1. ������� ������ ����� ������ ����������� ������ �� ������� � 2015 ����
(� ������ ������ ������ �� ����� ����������, ��������� ����� � ������� ������� �������).
����������� ���� ������ ���� ��� ������� �������.*/

SELECT distinct
	EOMONTH(Invoices.InvoiceDate) as InvoiceDateMONTH,
	(select
		SUM(InvoiceLines_2.Quantity*InvoiceLines_2.UnitPrice) 
		FROM Sales.InvoiceLines as InvoiceLines_2
		INNER JOIN Sales.Invoices as Invoices_2
		on InvoiceLines_2.InvoiceID = Invoices_2.InvoiceID
		WHERE Invoices_2.InvoiceDate >= '20150101'
			and EOMONTH(Invoices.InvoiceDate) >= EOMONTH(Invoices_2.InvoiceDate)) AS TotalSummByInvoice
FROM Sales.Invoices as Invoices
where Invoices.InvoiceDate >= '20150101'
order by 1

/*
2. �������� ������ ����� ����������� ������ � ���������� ������� � ������� ������� �������.
�������� ������������������ �������� 1 � 2 � ������� set statistics time, io on
*/

SELECT distinct
	EOMONTH(Invoices.InvoiceDate) as InvoiceDateMONTH, 
	(sum(InvoiceLines.Quantity*InvoiceLines.UnitPrice) over(order by EOMONTH(Invoices.InvoiceDate))) as TotalSummByInvoiceCT
FROM Sales.Invoices as Invoices
INNER JOIN Sales.InvoiceLines as InvoiceLines
ON Invoices.InvoiceID = InvoiceLines.InvoiceID
where Invoices.InvoiceDate >= '20150101'
order by 1

set statistics time, io on

/*
3. ������� ������ 2� ����� ���������� ��������� (�� ���������� ���������)
� ������ ������ �� 2016 ��� (�� 2 ����� ���������� �������� � ������ ������).
*/

with for_top_invoices as(
	select distinct
		EOMONTH(Invoices.InvoiceDate) as InvoiceDate,
		InvoiceLines.Description, 
		InvoiceLines.Quantity,
		row_number() over (partition by EOMONTH(Invoices.InvoiceDate) order by InvoiceLines.Quantity desc) rn
	FROM Sales.Invoices as Invoices
	INNER JOIN Sales.InvoiceLines as InvoiceLines
	on Invoices.InvoiceID = InvoiceLines.InvoiceID
	WHERE Invoices.InvoiceDate between '20160101' and '20161231'
)

select 
	* 
from for_top_invoices 
where rn in (1, 2) 
order by 1, 4, 3 desc, 2

/*
4. ������� ����� ��������
���������� �� ������� ������� (� ����� ����� ������ ������� �� ������, ��������, ����� � ����):
-+ ������������ ������ �� �������� ������, ��� ����� ��� ��������� ����� �������� ��������� ���������� ������
-+ ���������� ����� ���������� ������� � �������� ����� � ���� �� �������
-+ ���������� ����� ���������� ������� � ����������� �� ������ ����� �������� ������
-+ ���������� ��������� id ������ ������ �� ����, ��� ������� ����������� ������� �� �����
-+ ���������� �� ������ � ��� �� �������� ����������� (�� �����)
-+ �������� ������ 2 ������ �����, � ������ ���� ���������� ������ ��� ����� ������� "No items"
-+ ����������� 30 ����� ������� �� ���� ��� ������ �� 1 ��
*/

select 
	StockItemID, 
	StockItemName, 
	Brand, 
	UnitPrice,
	row_number() over (PARTITION BY left(StockItemName, 1) order by StockItemName) as StockItemName_row_number,
	COUNT(StockItemID) OVER () AS CountItems,
	COUNT(StockItemID) OVER (PARTITION BY left(StockItemName, 1)) AS CountItems_2,
	lag (StockItemID) over  (order by StockItemName) as StockItemName_lag,
	lead(StockItemID) over (order by StockItemName) as StockItemName_lead,
	lag (StockItemName, 2, 'No items') over  (order by StockItemName) as StockItemName_2_rows_lag,
	ntile(30) over (order by TypicalWeightPerUnit) as groupByTypicalWeightPerUnit
from Warehouse.StockItems

/*
��� ���� ������ �� ����� ������ ������ ��� ������������� �������.
5. �� ������� ���������� �������� ���������� �������, �������� ��������� ���-�� ������.
� ����������� ������ ���� �� � ������� ����������, �� � �������� �������, ���� �������, ����� ������.
*/
;
with invoices_max_cte as (
	select
		Invoices.InvoiceID,
		Invoices.InvoiceDate,
		Invoices.CustomerID,
		Invoices.SalespersonPersonID
	from Sales.Invoices as Invoices
	inner join (select
					max(Invoices.InvoiceID) as InvoiceID,
					max(Invoices.InvoiceDate) as InvoiceDate,
					Invoices.SalespersonPersonID
				from Sales.Invoices as Invoices
				group by Invoices.SalespersonPersonID) as Invoices_max
			on Invoices.InvoiceID = Invoices_max.InvoiceID
)

select distinct
	People.PersonID as PersonID,
	People.FullName as SalespersonPerson,
	Invoices.CustomerID as CustomerID,
	Customers.CustomerName as CustomerName,
	Invoices.InvoiceDate,
	(sum(InvoiceLines.Quantity*InvoiceLines.UnitPrice) over (PARTITION BY Invoices.InvoiceID)) as summ
from  Application.People as People
left join invoices_max_cte as Invoices
	on Invoices.SalespersonPersonID = People.PersonID
inner join Sales.InvoiceLines as InvoiceLines
	on Invoices.InvoiceID = InvoiceLines.InvoiceID
left join Sales.Customers as Customers
	on Invoices.CustomerID = Customers.CustomerID

/*
6. �������� �� ������� ������� ��� ����� ������� ������, ������� �� �������.
� ����������� ������ ���� �� ������, ��� ��������, �� ������, ����, ���� �������.

����������� ������ ��� ������� ������� ��� ������� ������� ������� ������� �������� � �������� ��������� � �������� �� ������������������.
*/
;
with for_top_stock as(
	select distinct
		max(Invoices.InvoiceDate) over (partition by Invoices.CustomerID, InvoiceLines.StockItemID order by Invoices.InvoiceDate desc) InvoiceDate,
		Invoices.CustomerID,
		InvoiceLines.StockItemID,
		StockItems.StockItemName,
		StockItems.UnitPrice,
		dense_rank() over (partition by Invoices.CustomerID order by StockItems.UnitPrice desc) rn
	from Sales.Invoices as Invoices
	inner join Sales.InvoiceLines as InvoiceLines
		on Invoices.InvoiceID = InvoiceLines.InvoiceID
	inner join Warehouse.StockItems as StockItems
		on InvoiceLines.StockItemID = StockItems.StockItemID
)
select
	for_top_stock.CustomerID,
	Customers.CustomerName as CustomerName,
	for_top_stock.StockItemID,
	for_top_stock.StockItemName,
	for_top_stock.UnitPrice,
	for_top_stock.InvoiceDate
from for_top_stock as for_top_stock
left join Sales.Customers as Customers
	on for_top_stock.CustomerID = Customers.CustomerID
where rn <= 2
order by 1, 3 desc, rn