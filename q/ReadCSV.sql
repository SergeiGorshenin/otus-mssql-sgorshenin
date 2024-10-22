USE bazaar

EXEC dbo.pFirstFillTableBuyers; 
EXEC dbo.pFirstFillTableSellers; 
EXEC dbo.pFirstFillTableProductStandards;
EXEC dbo.pFirstFillTableOrderStatuses;
EXEC dbo.pFirstFillTablePointsSale;




USE bazaar

EXEC dbo.pFirstFillTableBuyers; 
EXEC dbo.pFirstFillTableSellers; 

SELECT isnull(max(ID), 0) from dbo.Sellers
select * from dbo.Sellers

EXEC dbo.pFirstFillTablePointsSale; 
EXEC dbo.pFirstFillTableOrderStatuses; 
EXEC dbo.pFirstFillTableProductStandards;

drop table if exists #temp_pointsSale
drop table if exists #temp_orderStatuses
drop table if exists #temp_productStandards



CREATE TABLE #temp_pointsSale (
    [Name] nvarchar(250)   NULL ,
    [INN] nvarchar(70)  NULL ,
    [NameT] nvarchar(250)   NULL ,
    [Address] nvarchar(250)   NULL ,
)

CREATE TABLE #temp_orderStatuses(
    [Name] nvarchar(70)  NOT NULL ,
    [Description] nvarchar(250)  NULL ,
)

CREATE TABLE #temp_productStandards(
    [Name] nvarchar(250)  NOT NULL ,
    [Description] nvarchar(1000)  NULL ,
)


BULK INSERT #temp_pointsSale 
FROM 'D:\courses\otus\mssql\Ïðîåêò\Ïðîäàâöû_Ìàãàçèíû.csv' 
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ';', ROWTERMINATOR = '\n', CODEPAGE = 'ACP', DATAFILETYPE = 'widechar');

BULK INSERT #temp_orderStatuses
FROM 'D:\courses\otus\mssql\Ïðîåêò\Ñòàòóñû_çàêàçà.csv' 
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ';', ROWTERMINATOR = '\n', CODEPAGE = 'ACP', DATAFILETYPE = 'widechar');

BULK INSERT #temp_productStandards
FROM 'D:\courses\otus\mssql\Ïðîåêò\Òîâàðû_ýòàëîíû.csv' 
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ';', ROWTERMINATOR = '\n', CODEPAGE = 'ACP', DATAFILETYPE = 'widechar');

SELECT * FROM #temp_sellers
SELECT * FROM #temp_pointsSale
SELECT * FROM #temp_orderStatuses
SELECT * FROM #temp_productStandards



