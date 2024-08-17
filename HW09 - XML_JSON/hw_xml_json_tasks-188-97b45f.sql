/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "08 - Выборки из XML и JSON полей".

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
Примечания к заданиям 1, 2:
* Если с выгрузкой в файл будут проблемы, то можно сделать просто SELECT c результатом в виде XML. 
* Если у вас в проекте предусмотрен экспорт/импорт в XML, то можете взять свой XML и свои таблицы.
* Если с этим XML вам будет скучно, то можете взять любые открытые данные и импортировать их в таблицы (например, с https://data.gov.ru).
* Пример экспорта/импорта в файл https://docs.microsoft.com/en-us/sql/relational-databases/import-export/examples-of-bulk-import-and-export-of-xml-documents-sql-server
*/


/*
1. В личном кабинете есть файл StockItems.xml.
Это данные из таблицы Warehouse.StockItems.
Преобразовать эти данные в плоскую таблицу с полями, аналогичными Warehouse.StockItems.
Поля: StockItemName, SupplierID, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice 

Загрузить эти данные в таблицу Warehouse.StockItems: 
существующие записи в таблице обновить, отсутствующие добавить (сопоставлять записи по полю StockItemName). 

Сделать два варианта: с помощью OPENXML и через XQuery.
*/

--OPENXML 
declare @xml_file xml
select 
	@xml_file = BulkColumn
from openrowset
(bulk 'D:\courses\otus-mssql-sgorshenin\HW09 - XML_JSON\StockItems-188-1fb5df.xml', single_clob) as data 

declare @hdoc int
exec sp_xml_preparedocument @hdoc output, @xml_file

select * into #StockItemsFromXML   
from OPENXML(@hdoc, N'/StockItems/Item')
with ( 
	StockItemName nvarchar(100) '@Name',
	[SupplierID] int  'SupplierID',
	[UnitPackageID] int 'Package/UnitPackageID',
	[OuterPackageID] int 'Package/OuterPackageID',
	[QuantityPerOuter] int 'Package/QuantityPerOuter',
	[TypicalWeightPerUnit] decimal(18,3) 'Package/TypicalWeightPerUnit',
	[LeadTimeDays] int 'LeadTimeDays',
	[IsChillerStock] bit 'IsChillerStock',
	[TaxRate] decimal(18,3) 'TaxRate',
	[UnitPrice] decimal(18,2) 'UnitPrice'
	)

exec sp_xml_removedocument @hdoc

--Добаавить/обновить записи
select * from #StockItemsFromXML
merge Warehouse.StockItems as target
using (select	StockItemName, SupplierId, UnitPackageID, OuterPackageID, QuantityPerOuter,
				TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice
		from #StockItemsFromXML)
as source (StockItemName, SupplierId, UnitPackageID, OuterPackageID, QuantityPerOuter,
			TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice)
on (target.StockItemName = source.StockItemName)
when matched 
then update
set StockItemName = source.StockItemName, SupplierId = source.SupplierId, UnitPackageID = source.UnitPackageID,
	OuterPackageID = source.OuterPackageID, QuantityPerOuter = source.QuantityPerOuter, 
	TypicalWeightPerUnit = source.TypicalWeightPerUnit, LeadTimeDays = source.LeadTimeDays, 
	IsChillerStock = source.IsChillerStock, TaxRate = source.TaxRate, UnitPrice = source.UnitPrice
when not matched
then insert (StockItemName, SupplierId, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit,
				LeadTimeDays, IsChillerStock, TaxRate, UnitPrice, LastEditedBy)
values (source.StockItemName, source.SupplierId, source.UnitPackageID, source.OuterPackageID, 
		source.QuantityPerOuter, source.TypicalWeightPerUnit,source.LeadTimeDays, source.IsChillerStock, 
		source.TaxRate, source.UnitPrice, 1)
;

drop table if exists #StockItemsFromXML

--XQuery
drop table if exists #StockItemsFromXML_XQuery

declare @xml_file_XQuery xml
set @xml_file_XQuery = ( 
  select * from openrowset
  (bulk 'D:\courses\otus-mssql-sgorshenin\HW09 - XML_JSON\StockItems-188-1fb5df.xml', single_clob) as data)
select 
	items.Item.value('(@Name)[1]', 'nvarchar(max)') as [StockItemName],
	items.Item.value('(SupplierID)[1]','int') as [SupplierID],
	items.Item.value('(Package/UnitPackageID)[1]','int') as [UnitPackageID],
	items.Item.value('(Package/OuterPackageID)[1]','int') as [OuterPackageID],
	items.Item.value('(Package/QuantityPerOuter)[1]','int') as [QuantityPerOuter],
	items.Item.value('(Package/TypicalWeightPerUnit)[1]','decimal(18,3)') as [TypicalWeightPerUnit],
	items.Item.value('(LeadTimeDays)[1]','int') as [LeadTimeDays],
	items.Item.value('(IsChillerStock)[1]','bit') as [IsChillerStock],
	items.Item.value('(TaxRate)[1]','decimal(18,3)') as [TaxRate],
	items.Item.value('(UnitPrice)[1]','decimal(18,3)') as [UnitPrice]
into #StockItemsFromXML_XQuery
from @xml_file_XQuery.nodes ('/StockItems/Item') as items(Item)
merge Warehouse.StockItems as target
using (select	StockItemName, SupplierId, UnitPackageID, OuterPackageID, QuantityPerOuter,
				TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice
		from #StockItemsFromXML_XQuery)
as source (StockItemName, SupplierId, UnitPackageID, OuterPackageID, QuantityPerOuter,
			TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice)
on (target.StockItemName = source.StockItemName)
when matched 
then update
set StockItemName = source.StockItemName, SupplierId = source.SupplierId, UnitPackageID = source.UnitPackageID,
	OuterPackageID = source.OuterPackageID, QuantityPerOuter = source.QuantityPerOuter, 
	TypicalWeightPerUnit = source.TypicalWeightPerUnit, LeadTimeDays = source.LeadTimeDays, 
	IsChillerStock = source.IsChillerStock, TaxRate = source.TaxRate, UnitPrice = source.UnitPrice
when not matched
then insert (StockItemName, SupplierId, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit,
				LeadTimeDays, IsChillerStock, TaxRate, UnitPrice, LastEditedBy)
values (source.StockItemName, source.SupplierId, source.UnitPackageID, source.OuterPackageID, 
		source.QuantityPerOuter, source.TypicalWeightPerUnit,source.LeadTimeDays, source.IsChillerStock, 
		source.TaxRate, source.UnitPrice, 1);

drop table if exists #StockItemsFromXML_XQuery

/*
2. Выгрузить данные из таблицы StockItems в такой же xml-файл, как StockItems.xml
*/

declare @my_file NVARCHAR(200)
declare @cmd   NVARCHAR(4000)
  
select @my_file = 'D:\courses\otus-mssql-sgorshenin\HW09 - XML_JSON\my_StockItems.xml'
  
select @cmd = 'bcp ' +
		'"select StockItemName as [Item/@Name] ' +
			', SupplierId as [SupplierId] ' +
			', UnitPackageID as [Package/UnitPackageID] ' +
			', OuterPackageID as [Package/OuterPackageID] ' +
			', QuantityPerOuter as [Package/QuantityPerOuter] ' +
			', TypicalWeightPerUnit as [Package/TypicalWeightPerUnit] ' +
			', LeadTimeDays as [LeadTimeDays] ' +
			', IsChillerStock as [IsChillerStock] ' +
			', TaxRate as [TaxRate] ' +
			', UnitPrice as [UnitPrice] ' +
		'from Warehouse.StockItems ' +
		'where StockItemName in (''sgorshenin'', ''sgorshenin_XQuery'') ' +
		'for XML PATH (''StockItems''), ROOT (''StockItems'')" ' + 
'queryout "' + @my_file + '"' +
    ' -w -r -T -S my_lenovo\SQL2022 -c -d WideWorldImporters' 
SELECT @Cmd 
  
EXECUTE master..xp_cmdshell @Cmd

/*
3. В таблице Warehouse.StockItems в колонке CustomFields есть данные в JSON.
Написать SELECT для вывода:
- StockItemID
- StockItemName
- CountryOfManufacture (из CustomFields)
- FirstTag (из поля CustomFields, первое значение из массива Tags)
*/

select
	StockItemID,
	StockItemName,
	JSON_VALUE (CustomFields, '$.CountryOfManufacture') as CountryOfManufacture,
	JSON_VALUE (CustomFields, '$.Tags[0]') as Tags
from Warehouse.StockItems

/*
4. Найти в StockItems строки, где есть тэг "Vintage".
Вывести: 
- StockItemID
- StockItemName
- (опционально) все теги (из CustomFields) через запятую в одном поле

Тэги искать в поле CustomFields, а не в Tags.
Запрос написать через функции работы с JSON.
Для поиска использовать равенство, использовать LIKE запрещено.

Должно быть в таком виде:
... where ... = 'Vintage'

Так принято не будет:
... where ... Tags like '%Vintage%'
... where ... CustomFields like '%Vintage%' 
*/

; 
with cte as (
select	StockItemID
		,StockItemName
		,CustomFields
		,tags.[key]
		,tags.value
from Warehouse.StockItems
Cross Apply OpenJson(CustomFields, '$.Tags')  as tags
where tags.value = 'Vintage')
select StockItemID
	   ,StockItemName
	   ,CustomFields
	   from cte

-- (опционально) все теги (из CustomFields) через запятую в одном поле
;
with cte as (
select	StockItemID
		,StockItemName
		,CustomFields
		,tags.[key]
		,tags.value as a
from Warehouse.StockItems
Cross Apply OpenJson(CustomFields, '$.Tags')  as tags
)
select StockItemID
		,StockItemName, String_Agg(cast(a as nvarchar(max)),',') as  tags
from cte
group by StockItemID, StockItemName