use bazaar
GO

CREATE PROCEDURE dbo.pFirstFillTableBuyers    
AS   
    SET NOCOUNT ON;  
		drop table if exists #temp_pointsSale

		CREATE TABLE #temp_pointsSale (
			[Name] nvarchar(250)   NULL ,
			[INN] nvarchar(70)  NULL ,
			[NamePointsSale] nvarchar(250)   NULL ,
			[Address] nvarchar(250)   NULL ,
		)

		BULK INSERT #temp_pointsSale 
		FROM 'D:\courses\otus\mssql\Проект\Покупатели.csv' 
		WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ';', ROWTERMINATOR = '\n', CODEPAGE = 'ACP', DATAFILETYPE = 'widechar');

		DECLARE @SellerID bigint
		DECLARE @Name nvarchar(250)
		DECLARE @Address nvarchar(250)
		DECLARE @Telephone nvarchar(70)

		DECLARE cursor_temp_pointsSale CURSOR FOR SELECT * FROM #temp_pointsSale;
		OPEN cursor_temp_pointsSale;

		FETCH NEXT FROM cursor_temp_pointsSale 
			INTO @SellerID, @Name, @Address, @Telephone;

		WHILE @@FETCH_STATUS = 0
		BEGIN
			exec dbo.pUpdateTablePointsSale @SellerID, @Name, @Address, @Telephone;
			-- Обработка данных
			FETCH NEXT FROM cursor_temp_pointsSale 
				INTO @SellerID, @Name, @Address, @Telephone;
		END;

		CLOSE cursor_temp_pointsSale;

		DEALLOCATE cursor_temp_pointsSale;