use bazaar
GO

CREATE PROCEDURE dbo.pUpdateTablePointsSale    	
    @SellerID bigint
    @Name nvarchar(250)
    @Address nvarchar(250)
    @Telephone nvarchar(70)
	
AS   
    SET NOCOUNT ON;  
		MERGE dbo.PointsSale AS Target
		USING 
			  (
				SELECT
					isnull(PointsSale.ID, row_number() OVER (order by tt.SellerID, tt.Name, tt.Address, tt.Telephone) + (SELECT isnull(max(ID), 0) from dbo.PointsSale)) as ID,
					tt.SellerID,
					tt.Name,
					tt.Address,
					tt.Telephone 
				FROM (SELECT @SellerID as SellerID, @Name as Name, @Address as Address, @Telephone as Telephone) as tt
				left join dbo.PointsSale as PointsSale
				on tt.SellerID = PointsSale.SellerID 
					and tt.Name = PointsSale.Name
					and tt.Address = PointsSale.Address 
					and tt.Telephone = PointsSale.TelephoneTelephone 
			  ) as Source
			  (
				ID, SellerID, Name, Address, Telephone
			  )
			ON (Target.SellerID = Source.SellerID
				and Target.Name = Source.Name)
		WHEN MATCHED 
			THEN UPDATE 
				SET SellerID = Source.SellerID, Name = Source.Name, Address = Source.Address, Telephone = Source.Telephone
		WHEN NOT MATCHED 
			THEN INSERT 
				(ID, SellerID, Name, Address, Telephone)
				VALUES 
				(ID, Source.SellerID, Source.Name, Source.Address, Source.Telephone);
		--OUTPUT deleted.*, inserted.*;