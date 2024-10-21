use bazaar
GO

CREATE PROCEDURE dbo.pFirstFillTableBuyers    
AS   
    SET NOCOUNT ON;  
		drop table if exists #temp_buyers

		CREATE TABLE #temp_buyers (
			[Name] nvarchar(250)   NULL ,
			[Address] nvarchar(250)  NULL ,
			[Telephone] nvarchar(70)  NULL ,
			)


		BULK INSERT #temp_buyers 
		FROM 'D:\courses\otus\mssql\Проект\Покупатели.csv' 
		WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ';', ROWTERMINATOR = '\n', CODEPAGE = 'ACP', DATAFILETYPE = 'widechar');

		DECLARE @NameN nvarchar(250)
		DECLARE @AddressN nvarchar(250)
		DECLARE @TelephoneN nvarchar(70)

		DECLARE cursor_temp_buyers CURSOR FOR SELECT * FROM #temp_buyers;
		OPEN cursor_temp_buyers;

		FETCH NEXT FROM cursor_temp_buyers 
			INTO @NameN, @AddressN, @TelephoneN;

		WHILE @@FETCH_STATUS = 0
		BEGIN
			exec dbo.pUpdateTableBuyers @NameN, @AddressN, @TelephoneN;
			-- Обработка данных
			FETCH NEXT FROM cursor_temp_buyers 
				INTO @NameN, @AddressN, @TelephoneN;
		END;

		CLOSE cursor_temp_buyers;

		DEALLOCATE cursor_temp_buyers;