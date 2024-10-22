use bazaar
GO

CREATE PROCEDURE dbo.pUpdateTableOrderStatuses    
    @Name nvarchar(70),
	@Description nvarchar(250)
AS   
    SET NOCOUNT ON;  
		MERGE dbo.OrderStatuses AS Target
		USING 
			  (
				SELECT
					isnull(OrderStatuses.ID, row_number() OVER (order by tt.Name, tt.Description) + (SELECT isnull(max(ID), 0) from dbo.OrderStatuses)) as ID,
					tt.Name,
					tt.Description as Description
				FROM (SELECT @Name as Name, @Description as Description) as tt
				left join dbo.OrderStatuses as OrderStatuses
				on tt.Name = OrderStatuses.Name 
					and tt.Description = OrderStatuses.Description
			  ) as Source
			  (
				ID, Name, Description
			  )
			ON (Target.Name = Source.Name)
		WHEN MATCHED 
			THEN UPDATE 
				SET Name = Source.Name, Description = Source.Description
		WHEN NOT MATCHED 
			THEN INSERT 
				(ID, Name, Description)
				VALUES 
				(ID, Source.Name, Source.Description);
		--OUTPUT deleted.*, inserted.*;