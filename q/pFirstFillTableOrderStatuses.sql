use bazaar
GO

CREATE PROCEDURE dbo.pFirstFillTableOrderStatuses    
AS   
    SET NOCOUNT ON;  
		drop table if exists #temp_orderStatuses

		CREATE TABLE #temp_orderStatuses(
			[Name] nvarchar(70)  NOT NULL ,
			[Description] nvarchar(250)  NULL ,
		)

		BULK INSERT #temp_orderStatuses
		FROM 'D:\courses\otus\mssql\Проект\Статусы_заказа.csv' 
		WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ';', ROWTERMINATOR = '\n', CODEPAGE = 'ACP', DATAFILETYPE = 'widechar');

		DECLARE @NameN nvarchar(70)
		DECLARE @DescriptionN nvarchar(250)

		DECLARE cursor_temp_orderStatuses CURSOR FOR SELECT * FROM #temp_orderStatuses;
		OPEN cursor_temp_orderStatuses;

		FETCH NEXT FROM cursor_temp_orderStatuses 
			INTO @NameN, @DescriptionN;

		WHILE @@FETCH_STATUS = 0
		BEGIN
			exec dbo.pUpdateTableOrderStatuses @NameN, @DescriptionN;
			-- Обработка данных
			FETCH NEXT FROM cursor_temp_orderStatuses 
				INTO @NameN, @DescriptionN;
		END;

		CLOSE cursor_temp_orderStatuses;

		DEALLOCATE cursor_temp_orderStatuses;