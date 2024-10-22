use bazaar
GO

CREATE PROCEDURE dbo.pFirstFillTableProductStandards    
AS   
    SET NOCOUNT ON;  
		drop table if exists #temp_productStandards

		CREATE TABLE #temp_productStandards(
			[Name] nvarchar(250)  NOT NULL ,
			[Description] nvarchar(1000)  NULL ,
		)

		BULK INSERT #temp_productStandards
		FROM 'D:\courses\otus\mssql\Проект\Товары_эталоны.csv' 
		WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ';', ROWTERMINATOR = '\n', CODEPAGE = 'ACP', DATAFILETYPE = 'widechar');

		DECLARE @NameN nvarchar(250)
		DECLARE @DescriptionN nvarchar(1000)
		
		DECLARE cursor_temp_productStandards CURSOR FOR SELECT * FROM #temp_productStandards;
		OPEN cursor_temp_productStandards;

		FETCH NEXT FROM cursor_temp_productStandards 
			INTO @NameN, @DescriptionN;

		WHILE @@FETCH_STATUS = 0
		BEGIN
			exec dbo.pUpdateTableProductStandards @NameN, @DescriptionN;
			-- Обработка данных
			FETCH NEXT FROM cursor_temp_productStandards 
				INTO @NameN, @DescriptionN
		END;

		CLOSE cursor_temp_productStandards;

		DEALLOCATE cursor_temp_productStandards;