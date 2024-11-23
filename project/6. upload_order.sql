USE bazaar
GO

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

DECLARE @ID bigint
DECLARE @order_json nvarchar(MAX)
DECLARE @header_json nvarchar(MAX)
DECLARE @line_json nvarchar(MAX)
DECLARE @cmd nvarchar(MAX)
DECLARE @sql varchar(8000) 

DECLARE cursor_id_order CURSOR FOR 
	SELECT TOP 10
		ID
	FROM dbo.Orders
OPEN cursor_id_order;

FETCH NEXT FROM cursor_id_order 
	INTO @ID;

WHILE @@FETCH_STATUS = 0
BEGIN

	SET @header_json = 
	(
		SELECT
			*
		FROM dbo.Orders
		WHERE ID = @ID
		FOR JSON PATH, WITHOUT_ARRAY_WRAPPER 
	)	
	SET @line_json = 
	(
		SELECT
			*
		FROM dbo.LineOrders
		WHERE OrderID = @ID
		FOR JSON PATH, ROOT('LinesOrder')
	)	

	SET @order_json = STRING_ESCAPE('''' + SUBSTRING( @header_json , 1, LEN(@header_json) - 1) + ',' +  SUBSTRING(@line_json, 2, LEN(@line_json) - 2) + '}''', 'json')

	SET @cmd='"select '+CAST(@order_json AS nvarchar(MAX))+' as f"' 
	SELECT @sql = 'bcp '+@cmd+' queryout D:\courses\otus-mssql-sgorshenin\project\json\orders\'+CAST(@ID AS VARCHAR(10))+'.json -c -t -T -S my_lenovo\SQL2022';
	EXEC xp_cmdshell @sql;

	FETCH NEXT FROM cursor_id_order 
		INTO @ID;
END;

CLOSE cursor_id_order;

DEALLOCATE cursor_id_order;
