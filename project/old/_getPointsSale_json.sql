USE bazaar
GO

DECLARE @json nvarchar(MAX)
DECLARE @responseJson nvarchar(MAX)

DECLARE @Zero bigint
DECLARE @ValueID bigint
DECLARE @ValueName nvarchar(MAX)

SET @json = N'{"ID":"П","Name":"П"}';

BEGIN TRY
	SET @Zero	   = CAST(0 as bigint)
	SET @ValueID   = JSON_VALUE(@json, '$.ID')
	SET @ValueName = JSON_VALUE(@json, '$.Name')
END TRY

BEGIN CATCH
    SELECT ERROR_NUMBER() AS ErrorNumber,
        ERROR_SEVERITY() AS ErrorSeverity,
        ERROR_STATE() AS ErrorState,
        ERROR_PROCEDURE() AS ErrorProcedure,
        ERROR_LINE() AS ErrorLine,
        ERROR_MESSAGE() AS ErrorMessage,
		@json  AS Json;
END CATCH;

IF ISJSON(@json) = 1
	BEGIN
		SELECT @responseJson = 
		(
			SELECT 
				PointsSale.ID as PointSaleID,
				PointsSale.Name as PointSaleName,
				PointsSale.Telephone as PointSaleTelephone,
				PointsSale.Address as PointSaleAddress,
				Sellers.ID as SellerID,
				Sellers.Name as SellerName
			from dbo.PointsSale as PointsSale
			inner join dbo.Sellers as Sellers
			on PointsSale.SellerID = Sellers.ID
			WHERE 
				(@ValueID IS NOT NULL AND @ValueID <> @Zero
					AND PointsSale.ID = @ValueID)
				OR 
				((@ValueID IS NULL OR @ValueID = @Zero)
					AND @ValueName IS NOT NULL
					AND PointsSale.Name like @ValueName + '%')
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