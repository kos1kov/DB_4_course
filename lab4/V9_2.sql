USE AdventureWorks2012
GO
-- a)
CREATE VIEW Sales.SpecialOfferInfo_View
WITH SCHEMABINDING
AS
SELECT
	 p.Name,
	 so.SpecialOfferID,
	 so.Description,
	 so.DiscountPct,
	 so.Type,
	 so.Category,
	 so.StartDate,
	 so.EndDate,
	 so.MinQty,
	 so.MaxQty,
	 so.rowguid,
	 so.ModifiedDate,
	 sop.ProductID
FROM Sales.SpecialOffer so
INNER JOIN Sales.SpecialOfferProduct sop
	ON (sop.SpecialOfferID = so.SpecialOfferID)
INNER JOIN Production.Product p
	ON (p.ProductID = sop.ProductID);
GO

CREATE UNIQUE CLUSTERED INDEX SpecialOfferInfo_Index_ProductID_SpecialOfferID
	ON SpecialOfferInfo_View(ProductID, SpecialOfferID);
GO

-- b)
CREATE TRIGGER Sales.Trg_SpecialOfferInfo_ViewView_Actions ON Sales.SpecialOfferInfo_View
INSTEAD OF INSERT, UPDATE, DELETE AS
BEGIN
	IF EXISTS (SELECT * FROM inserted)
	BEGIN
		IF EXISTS (
			SELECT * 
			FROM SpecialOfferInfo_View AS soi_v
			JOIN inserted AS insert_s
				ON insert_s.ProductID = soi_v.ProductID AND insert_s.SpecialOfferID = soi_v.SpecialOfferID)
		BEGIN
			UPDATE Sales.SpecialOffer SET
				Description = ins.Description,
				DiscountPct = ins.DiscountPct,
				Type = ins.Type,
				Category = ins.Category,
				StartDate = ins.StartDate,
				EndDate = ins.EndDate,
				MinQty = ins.MinQty,
				MaxQty = ins.MaxQty,
				ModifiedDate = GETDATE(),
				rowguid = ins.rowguid
			FROM inserted AS ins
			WHERE ins.SpecialOfferID = Sales.SpecialOffer.SpecialOfferID
		END
		ELSE
		BEGIN
			INSERT INTO Sales.SpecialOffer (
				Description,
				DiscountPct,
				Type,
				Category,
				StartDate,
				EndDate,
				MinQty,
				MaxQty,
				ModifiedDate,
				rowguid)
			SELECT 
				Description = ins.Description,
				DiscountPct = ins.DiscountPct,
				Type = ins.Type,
				Category = ins.Category,
				StartDate = ins.StartDate,
				EndDate = ins.EndDate,
				MinQty = ins.MinQty,
				MaxQty = ins.MaxQty,
				ModifiedDate = GETDATE(),
				rowguid = ins.rowguid
			FROM inserted AS ins;

			INSERT INTO Sales.SpecialOfferProduct (
				SpecialOfferID,
				ProductID,
				ModifiedDate,
				rowguid)
			SELECT 
				so.SpecialOfferID,
				ins.ProductID,
				GETDATE(),
				NEWID()
			FROM inserted AS ins
			JOIN Sales.SpecialOffer AS so 
				ON so.rowguid = ins.rowguid
		END
	END

	IF EXISTS (SELECT * FROM deleted) AND NOT EXISTS (SELECT * FROM inserted)
	BEGIN
		DELETE FROM Sales.SpecialOfferProduct 
		WHERE ProductID IN (SELECT ProductID FROM deleted)

		DELETE FROM Sales.SpecialOffer 
		WHERE SpecialOfferID IN (SELECT SpecialOfferID FROM deleted) 
		AND SpecialOfferID NOT IN (SELECT SpecialOfferID FROM Sales.SpecialOfferProduct)
	END
END;
GO

-- c)
INSERT INTO Sales.SpecialOfferInfo_View (
	Category,
	Description,
	DiscountPct,
	EndDate,
	MaxQty,
	MinQty,
	ModifiedDate,
	RowGuid,
	StartDate,
	Type,
	ProductID,
	Name
)
VALUES ('category', 'description', 1, GETDATE(), 1, 1, GETDATE(), NEWID(), GETDATE(), 'type', 1, 'Adjustable Race')

UPDATE Sales.SpecialOfferInfo_View SET
	Category = 'category',
	Description = 'new description',
	DiscountPct = 13.13,
	EndDate = GETDATE(),
	MaxQty = 10,
	MinQty = 5,
	ModifiedDate = GETDATE(),
	RowGuid = NEWID(),
	StartDate = GETDATE(),
	Type = 'type',
	Name = 'Adjustable Race'
WHERE Category = 'category'

DELETE FROM Sales.SpecialOfferInfo_View
WHERE Category = 'category'

-- output
SELECT * FROM Sales.SpecialOfferInfo_View WHERE Category = 'category'