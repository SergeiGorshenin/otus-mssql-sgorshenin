USE bazaar
GO

DECLARE @ID bigint

DECLARE cursor_temp_pointsSale CURSOR FOR 
	select 
		PointsSale.ID 
	from dbo.PointsSale as PointsSale;
OPEN cursor_temp_pointsSale;

FETCH NEXT FROM cursor_temp_pointsSale 
	INTO @ID;

WHILE @@FETCH_STATUS = 0
BEGIN
	
	print(@ID);
	SELECT dbo.fGetRandomINT(RAND(), 1, 30);
	SELECT dbo.fGetRandomDate(RAND());

	-- Обработка данных
	FETCH NEXT FROM cursor_temp_pointsSale 
		INTO @ID;
END;

CLOSE cursor_temp_pointsSale;

DEALLOCATE cursor_temp_pointsSale;