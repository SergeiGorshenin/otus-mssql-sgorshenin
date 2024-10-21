use bazaar
GO

CREATE PROCEDURE dbo.pUpdateTableSellers    
    @Name nvarchar(250),
	@INN nvarchar(70),
	@Address nvarchar(250)
AS   
    SET NOCOUNT ON;  
		MERGE dbo.Sellers AS Target
		USING 
			  (
				SELECT
					isnull(Sellers.ID, row_number() OVER (order by tt.Name, tt.INN, tt.Address) + (SELECT isnull(max(ID), 0) from dbo.Sellers)) as ID,
					tt.Name,
					tt.INN as INN,
					tt.Address 
				FROM (SELECT @Name as Name, @INN as INN, @Address as Address) as tt
				left join dbo.Sellers as Sellers
				on tt.Name = Sellers.Name 
					and tt.INN = Sellers.INN
					and tt.Address = Sellers.Address 
			  ) as Source
			  (
				ID, Name, Address, INN
			  )
			ON (Target.INN = Source.INN)
		WHEN MATCHED 
			THEN UPDATE 
				SET Name = Source.Name, INN = Source.INN, Address = Source.Address
		WHEN NOT MATCHED 
			THEN INSERT 
				(ID, Name, INN, Address)
				VALUES 
				(ID, Source.Name, Source.INN, Source.Address);
		--OUTPUT deleted.*, inserted.*;