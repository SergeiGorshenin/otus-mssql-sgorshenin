USE bazaar
GO

DECLARE @json nvarchar(MAX)
DECLARE @responseJson nvarchar(MAX)

SET @json = N'{"Name":"Ив"}';

IF ISJSON(@json) = 1
	BEGIN
		SELECT @responseJson = 
		(
			SELECT
				*
			FROM dbo.Buyers
			WHERE Name like JSON_VALUE(@json, '$.Name') + '%'
			FOR JSON AUTO 
		)
	END;
ELSE
	BEGIN
		SELECT @responseJson = 
		(
			SELECT
				*
			FROM (SELECT N'Ошибка JSON' AS Message) AS T
			FOR JSON AUTO 
		)
	END;

print(@responseJson)