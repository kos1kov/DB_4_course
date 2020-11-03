USE AdventureWorks2012
GO
DROP TABLE  Sales.SpecialOfferHst;
-- a)
CREATE TABLE Sales.SpecialOfferHst (
	ID INT IDENTITY(1, 1) PRIMARY KEY,
	Action CHAR(6) NOT NULL CHECK (Action IN ('insert', 'update', 'delete')),
	ModifiedDate DATETIME NOT NULL,
	SourceID INT NOT NULL,
	UserName NVARCHAR(128) NOT NULL
);
GO

-- b)
CREATE TRIGGER Sales.insert_action
ON Sales.SpecialOffer
AFTER INSERT AS
	INSERT INTO Sales.SpecialOfferHst(Action, ModifiedDate, SourceID, UserName)
	SELECT 'INSERT', GETDATE(), ins.SpecialOfferID, USER_NAME()
	FROM inserted AS ins;
GO

CREATE TRIGGER Sales.update_action
ON Sales.SpecialOffer
AFTER UPDATE AS
	INSERT INTO Sales.SpecialOfferHst(Action, ModifiedDate, SourceID, UserName)
	SELECT 'UPDATE', GETDATE(), ins.SpecialOfferID, USER_NAME()
	FROM inserted AS ins;
GO

CREATE TRIGGER Sales.delete_action
ON Sales.SpecialOffer
AFTER DELETE AS
	INSERT INTO Sales.SpecialOfferHst(Action, ModifiedDate, SourceID, UserName)
	SELECT 'DELETE', GETDATE(), del.SpecialOfferID, USER_NAME()
	FROM deleted AS del;
GO
-- c)
CREATE VIEW Sales.SpecialOffer_View
WITH ENCRYPTION
AS
SELECT *
FROM Sales.SpecialOffer
go

INSERT INTO Sales.SpecialOffer_View (
	Description,
	DiscountPct,
	Type,
	Category,
	StartDate,
	EndDate,
	MinQty,
	MaxQty,
	ModifiedDate) 
VALUES (
	'insert_action',
	10,
	'INSERT',
	'Action',
	GETDATE(),
	GETDATE(),
	2,
	5,
	GETDATE()
);
go

UPDATE Sales.SpecialOffer_View 
SET
	Description = 'update_action',
	Type = 'UPDATE',
	ModifiedDate = GETDATE()
WHERE Description = 'insert_action'

DELETE 
FROM Sales.SpecialOffer_View
WHERE Description = 'update_action'