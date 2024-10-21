use bazaar
GO

CREATE PROCEDURE dbo.pUpdateTableBuyers    
    @Name nvarchar(250),
	@Address nvarchar(250),
	@Telephone nvarchar(250)
AS   
    SET NOCOUNT ON;  
		MERGE dbo.Buyers AS Target
		USING 
			  (
				SELECT
					isnull(buyers.ID, row_number() OVER (order by @Name, @Address, @Telephone) + (SELECT isnull(max(ID), 0) from dbo.Buyers)) as ID,
					tt.Name,
					tt.Address,
					tt.Telephone 
				FROM (SELECT @Name as Name, @Address as Address, @Telephone as Telephone) as tt
				left join dbo.Buyers as buyers
				on tt.Name = buyers.Name 
					and tt.Address = buyers.Address 
					and tt.Telephone = buyers.Telephone
			  ) as Source
			  (
				ID, Name, Address, Telephone
			  )
			ON (Target.Telephone = Source.Telephone)
		WHEN MATCHED 
			THEN UPDATE 
				SET Name = Source.Name, Address = Source.Address, Telephone = Source.Telephone
		WHEN NOT MATCHED 
			THEN INSERT 
				(ID, Name, Address, Telephone)
				VALUES 
				(ID, Source.Name, Source.Address, Source.Telephone);
		--OUTPUT deleted.*, inserted.*;