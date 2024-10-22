use bazaar
GO

CREATE PROCEDURE dbo.pUpdateTableProductStandards    
    @Name nvarchar(250),
	@Description nvarchar(1000)
AS   
    SET NOCOUNT ON;  
		MERGE dbo.ProductStandards AS Target
		USING 
			  (
				SELECT
					isnull(ProductStandards.ID, row_number() OVER (order by tt.Name, tt.Description) + (SELECT isnull(max(ID), 0) from dbo.ProductStandards)) as ID,
					tt.Name,
					tt.Description as Description
				FROM (SELECT @Name as Name, @Description as Description) as tt
				left join dbo.ProductStandards as ProductStandards
				on tt.Name = ProductStandards.Name 
					and tt.Description = ProductStandards.Description
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