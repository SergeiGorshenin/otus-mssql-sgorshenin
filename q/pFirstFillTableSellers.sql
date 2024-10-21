use bazaar
GO

CREATE PROCEDURE dbo.pFirstFillTableSellers    
AS   
    SET NOCOUNT ON;  
		drop table if exists #temp_sellers

		CREATE TABLE #temp_sellers (
			[Name] nvarchar(250)   NULL ,
			[INN] nvarchar(70)  NULL ,
			[Address] nvarchar(250)   NULL ,
		)

		BULK INSERT #temp_sellers 
		FROM 'D:\courses\otus\mssql\Проект\Продавцы.csv' 
		WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ';', ROWTERMINATOR = '\n', CODEPAGE = 'ACP', DATAFILETYPE = 'widechar');

		DECLARE @NameN nvarchar(250)
		DECLARE @INNN nvarchar(70)
		DECLARE @AddressN nvarchar(250)

		DECLARE cursor_temp_sellers CURSOR FOR SELECT * FROM #temp_sellers;
		OPEN cursor_temp_sellers;

		FETCH NEXT FROM cursor_temp_sellers 
			INTO @NameN, @INNN, @AddressN;

		WHILE @@FETCH_STATUS = 0
		BEGIN
			exec dbo.pUpdateTableSellers @NameN, @INNN, @AddressN;
			-- Обработка данных
			FETCH NEXT FROM cursor_temp_sellers 
				INTO @NameN, @INNN, @AddressN;
		END;

		CLOSE cursor_temp_sellers;

		DEALLOCATE cursor_temp_sellers;