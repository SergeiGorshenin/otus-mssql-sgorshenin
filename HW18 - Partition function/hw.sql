use bazaar
go

--создам файловую группу
ALTER DATABASE [bazaar] ADD FILEGROUP [PricesByPeriod]
GO

--добавляем файл БД
ALTER DATABASE [bazaar] ADD FILE 
( NAME = N'NamePricesByPeriod', FILENAME = N'D:\Microsoft SQL Server\MSSQL16.SQL2022\MSSQL\DATA\PricesByPeriod.ndf' , 
SIZE = 1097152KB , FILEGROWTH = 65536KB ) TO FILEGROUP [PricesByPeriod]
GO

--DROP PARTITION SCHEME [schmPricesByPeriod];
--DROP PARTITION FUNCTION [fnPricesByPeriod];
--создаем функцию партиционирования по годам
CREATE PARTITION FUNCTION [fnPricesByPeriod](datetime2) AS RANGE RIGHT FOR VALUES
(	
	'20220101', '20220601', 
	'20230101', '20230601', 
	'20240101', '20240601'
);
GO

-- партиционируем, используя созданную функцию
CREATE PARTITION SCHEME [schmPricesByPeriod] AS PARTITION [fnPricesByPeriod] 
ALL TO ([PricesByPeriod])
GO

SELECT count(*) 
FROM dbo.ProductPrices;

--DROP TABLE dbo.ProductPricesPartitioned;
--создаем таблицу для секционированния 
SELECT * INTO dbo.ProductPricesPartitioned
FROM dbo.ProductPrices;

SELECT count(*) 
FROM dbo.ProductPricesPartitioned;

--создание некластерного индекса
ALTER TABLE [dbo].[ProductPrices] ADD CONSTRAINT PK_dbo_ProductPricesPartitioned 
UNIQUE NONCLUSTERED (ProductPointSaleID, PriceUpdateDate)
ON [schmPricesByPeriod]([PriceUpdateDate]);

--секционированные таблицы в базе данных
select distinct t.name
from sys.partitions p
inner join sys.tables t
	on p.object_id = t.object_id
where p.partition_number <> 1

--секционированные диапазоны
SELECT  $PARTITION.fnPricesByPeriod(PriceUpdateDate) AS Partition
		, COUNT(*) AS [count]
		, MIN(PriceUpdateDate) as [min]
		, MAX(PriceUpdateDate) as [max]
FROM dbo.ProductPrices
GROUP BY $PARTITION.fnPricesByPeriod(PriceUpdateDate) 
ORDER BY Partition ;  