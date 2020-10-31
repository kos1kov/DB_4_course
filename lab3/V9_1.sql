use AdventureWorks2012
go
-- a)
ALTER TABLE dbo.StateProvince
	ADD  AddressType NVARCHAR(50)
go

-- b)
DECLARE @StateProvince TABLE (
	StateProvinceID INT NOT NULL,
	StateProvinceCode NCHAR(3) NOT NULL,
	CountryRegionCode NVARCHAR(3) NOT NULL,
	IsOnlyStateProvinceFlag SMALLINT,
	Name Name NOT NULL,
	TerritoryID INT NOT NULL, 
	ModifiedDate DATETIME NOT NULL,
	AddressType NVARCHAR(50)
);

INSERT INTO @StateProvince
SELECT 
	sp.StateProvinceID,
	sp.StateProvinceCode,
	sp.CountryRegionCode,
	sp.IsOnlyStateProvinceFlag,
	sp.Name,
	sp.TerritoryID,
	sp.ModifiedDate,
	addressType.Name
FROM dbo.StateProvince AS sp 
INNER JOIN Person.Address AS pAddress
	ON sp.StateProvinceID = pAddress.StateProvinceID
INNER JOIN Person.BusinessEntityAddress AS eAddress
	ON pAddress.AddressID = eAddress.AddressID
INNER JOIN Person.AddressType AS addressType
	ON addressType.AddressTypeID = eAddress.AddressTypeID


	-- c)
UPDATE dbo.StateProvince
SET dbo.StateProvince.AddressType = sp.AddressType,
	dbo.StateProvince.Name = CONCAT(countryReg.Name, ' ', sp.Name)
FROM @StateProvince AS sp
INNER JOIN Person.CountryRegion AS countryReg 
		ON countryReg.CountryRegionCode = sp.CountryRegionCode
WHERE 
	sp.StateProvinceID = dbo.StateProvince.StateProvinceID
go



-- d)
WITH Sp AS 
(
	SELECT 
		*, 
		RANK() OVER (PARTITION BY AddressType ORDER BY StateProvinceID DESC) AS score
	FROM dbo.StateProvince
)
DELETE
FROM Sp
WHERE score > 1
go

SELECT *
FROM AdventureWorks2012.INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE
WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'StateProvince';

go
-- e)
ALTER TABLE dbo.StateProvince
	DROP COLUMN AddressType

SELECT default_constraints.name
FROM sys.all_columns
	INNER JOIN sys.tables
        ON all_columns.object_id = tables.object_id
	INNER JOIN sys.schemas
        ON tables.schema_id = schemas.schema_id
	INNER JOIN sys.default_constraints
        ON all_columns.default_object_id = default_constraints.object_id
WHERE schemas.name = 'dbo'
    AND tables.name = 'StateProvince';

ALTER TABLE dbo.StateProvince
  DROP CONSTRAINT PK_StateProvince, CHK_TerritoryID, TerritoryID_Default

  -- f)
 DROP TABLE dbo.StateProvince