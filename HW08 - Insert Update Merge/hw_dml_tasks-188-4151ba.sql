/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "10 - Операторы изменения данных".

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
1. Довставлять в базу пять записей используя insert в таблицу Customers или Suppliers 
*/

INSERT INTO Purchasing.Suppliers
	(SupplierID, SupplierName, SupplierCategoryID, PrimaryContactPersonID
	, AlternateContactPersonID, DeliveryMethodID, DeliveryCityID, PostalCityID
	, SupplierReference, BankAccountName, BankAccountBranch, BankAccountCode
	, BankAccountNumber, BankInternationalCode, PaymentDays, InternalComments
	, PhoneNumber, FaxNumber, WebsiteURL, DeliveryAddressLine1, DeliveryAddressLine2
	, DeliveryPostalCode, DeliveryLocation, PostalAddressLine1, PostalAddressLine2
	, PostalPostalCode, LastEditedBy)
OUTPUT inserted.*
SELECT TOP(5)
	row_number() OVER (order by SupplierID) + (count(SupplierID) OVER ()) as SupplierID, 'new_HW08_' + SupplierName as SupplierName, SupplierCategoryID, PrimaryContactPersonID
	, AlternateContactPersonID, DeliveryMethodID, DeliveryCityID, PostalCityID
	, SupplierReference, BankAccountName, BankAccountBranch, BankAccountCode
	, BankAccountNumber, BankInternationalCode, PaymentDays, InternalComments
	, PhoneNumber, FaxNumber, WebsiteURL, DeliveryAddressLine1, DeliveryAddressLine2
	, DeliveryPostalCode, DeliveryLocation, PostalAddressLine1, PostalAddressLine2
	, PostalPostalCode, LastEditedBy
FROM Purchasing.Suppliers

/*
2. Удалите одну запись из Customers, которая была вами добавлена
*/

DELETE FROM Purchasing.Suppliers WHERE SupplierID = 18;

/*
3. Изменить одну запись, из добавленных через UPDATE
*/

UPDATE Purchasing.Suppliers
SET 
	SupplierName = 'upd_' + SupplierName
OUTPUT 
    inserted.SupplierName as new_SupplierName
   , deleted.SupplierName as old_SupplierName
WHERE SupplierID = 17

/*
4. Написать MERGE, который вставит вставит запись в клиенты, если ее там нет, и изменит если она уже есть
*/

MERGE Purchasing.Suppliers AS Target
USING 
	  (
		select 15, 'merge_t2_HW08_Contoso, Ltd.', 2, 23
		, 24, 9, 13870, 13870
		, 'B2084020', 'Contoso Ltd', 'Woodgrove Bank Greenbank', '358698'
		, '4587965215', '25868', '7', 'NULL'
		, '(360) 555-0100', '(360) 555-0101', 'http://www.contoso.com', 'Unit 2', '2934 Night Road'
		, '98253', 0xE6100000010CDA4B6430900C4840C04EFBF7AAA45EC0, 'PO Box 1012', 'Jolimont'
		, '98253', 1
	  ) as Source
	  (
		SupplierID, SupplierName, SupplierCategoryID, PrimaryContactPersonID
		, AlternateContactPersonID, DeliveryMethodID, DeliveryCityID, PostalCityID
		, SupplierReference, BankAccountName, BankAccountBranch, BankAccountCode
		, BankAccountNumber, BankInternationalCode, PaymentDays, InternalComments
		, PhoneNumber, FaxNumber, WebsiteURL, DeliveryAddressLine1, DeliveryAddressLine2
		, DeliveryPostalCode, DeliveryLocation, PostalAddressLine1, PostalAddressLine2
		, PostalPostalCode, LastEditedBy
	  )
    ON (Target.SupplierID = Source.SupplierID)
WHEN MATCHED 
    THEN UPDATE 
        SET SupplierID = Source.SupplierID, SupplierName = Source.SupplierName, SupplierCategoryID = Source.SupplierCategoryID, PrimaryContactPersonID = Source.PrimaryContactPersonID
		, AlternateContactPersonID = Source.AlternateContactPersonID, DeliveryMethodID = Source.DeliveryMethodID, DeliveryCityID = Source.DeliveryCityID, PostalCityID = Source.PostalCityID
		, SupplierReference = Source.SupplierReference, BankAccountName = Source.BankAccountName, BankAccountBranch = Source.BankAccountBranch, BankAccountCode = Source.BankAccountCode
		, BankAccountNumber = Source.BankAccountNumber, BankInternationalCode = Source.BankInternationalCode, PaymentDays = Source.PaymentDays, InternalComments = Source.InternalComments
		, PhoneNumber = Source.PhoneNumber, FaxNumber = Source.FaxNumber, WebsiteURL = Source.WebsiteURL, DeliveryAddressLine1 = Source.DeliveryAddressLine1, DeliveryAddressLine2 = Source.DeliveryAddressLine2
		, DeliveryPostalCode = Source.DeliveryPostalCode, DeliveryLocation = Source.DeliveryLocation, PostalAddressLine1 = Source.PostalAddressLine1, PostalAddressLine2 = Source.PostalAddressLine2
		, PostalPostalCode = Source.PostalPostalCode, LastEditedBy = Source.LastEditedBy
WHEN NOT MATCHED 
    THEN INSERT 
		(
			SupplierID, SupplierName, SupplierCategoryID, PrimaryContactPersonID
			, AlternateContactPersonID, DeliveryMethodID, DeliveryCityID, PostalCityID
			, SupplierReference, BankAccountName, BankAccountBranch, BankAccountCode
			, BankAccountNumber, BankInternationalCode, PaymentDays, InternalComments
			, PhoneNumber, FaxNumber, WebsiteURL, DeliveryAddressLine1, DeliveryAddressLine2
			, DeliveryPostalCode, DeliveryLocation, PostalAddressLine1, PostalAddressLine2
			, PostalPostalCode, LastEditedBy
	    )
        VALUES 
		(
			Source.SupplierID, Source.SupplierName, Source.SupplierCategoryID, Source.PrimaryContactPersonID
			, Source.AlternateContactPersonID,  Source.DeliveryMethodID, Source.DeliveryCityID, Source.PostalCityID
			, Source.SupplierReference, Source.BankAccountName, Source.BankAccountBranch, Source.BankAccountCode
			, Source.BankAccountNumber, Source.BankInternationalCode, Source.PaymentDays, Source.InternalComments
			, Source.PhoneNumber, Source.FaxNumber, Source.WebsiteURL, Source.DeliveryAddressLine1, Source.DeliveryAddressLine2
			, Source.DeliveryPostalCode, Source.DeliveryLocation, Source.PostalAddressLine1, Source.PostalAddressLine2
			, Source.PostalPostalCode, Source.LastEditedBy
		)
OUTPUT deleted.*, inserted.*;

/*
5. Напишите запрос, который выгрузит данные через bcp out и загрузить через bulk insert
*/

-- To allow advanced options to be changed.  
EXEC sp_configure 'show advanced options', 1;  
GO  
-- To update the currently configured value for advanced options.  
RECONFIGURE;  
GO  
-- To enable the feature.  
EXEC sp_configure 'xp_cmdshell', 1;  
GO  
-- To update the currently configured value for this feature.  
RECONFIGURE;  
GO  

exec master..xp_cmdshell 'bcp WideWorldImporters.Purchasing.Suppliers out  "D:\courses\otus-mssql-sgorshenin\HW08 - Insert Update Merge\Suppliers.csv" -T -S my_lenovo\SQL2022 -c';

drop table if exists Purchasing.Suppliers_bulked
select * into Purchasing.Suppliers_bulked
from Purchasing.Suppliers
where 1=2

select * from Purchasing.Suppliers_bulked

EXEC master..xp_cmdshell 'bcp WideWorldImporters.Purchasing.Suppliers_bulked in "D:\courses\otus-mssql-sgorshenin\HW08 - Insert Update Merge\Suppliers.csv" -T -S my_lenovo\SQL2022 -c';

select * from Purchasing.Suppliers_bulked