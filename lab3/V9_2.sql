USE AdventureWorks2012
GO
-- a)
ALTER TABLE dbo.StateProvince
	ADD 
		TaxRate SMALLMONEY,
		CurrencyCode NCHAR(3),
		AverageRate MONEY,
		IntTaxRate AS CEILING(TaxRate)

DROP TABLE  #StateProvince

-- b)
CREATE TABLE #StateProvince ( 
	StateProvinceID INT NOT NULL PRIMARY KEY,
	StateProvinceCode NCHAR(3) NOT NULL,
	CountryRegionCode NVARCHAR(3) NOT NULL,
	IsOnlyStateProvinceFlag SMALLINT,
	Name NVARCHAR(50) NOT NULL,
	TerritoryID INT NOT NULL, 
	ModifiedDate DATETIME NOT NULL,
	TaxRate SMALLMONEY,
	CurrencyCode NCHAR(3),
	AverageRate MONEY
);

-- c)
WITH avrgCurrency AS (
	SELECT 
		cr.ToCurrencyCode AS CurrencyCode, 
		MAX(cr.AverageRate) AS AverageRate
	FROM Sales.CurrencyRate AS cr
	GROUP BY ToCurrencyCode
)	
INSERT INTO dbo.#StateProvince (
	StateProvinceID, 
	StateProvinceCode, 
	CountryRegionCode,
	IsOnlyStateProvinceFlag,
	Name,
	TerritoryID,
	ModifiedDate,
	TaxRate,
	CurrencyCode,
	AverageRate )
SELECT 
	sp.StateProvinceID, 
	sp.StateProvinceCode,
	sp.CountryRegionCode,
	sp.IsOnlyStateProvinceFlag,
	sp.Name,
	sp.TerritoryID,
	sp.ModifiedDate,
	CASE tr.TaxType
		WHEN 1 THEN tr.TaxRate
		ELSE 0
	END AS TaxRate,
	crc.CurrencyCode,
	ac.AverageRate
FROM dbo.StateProvince AS sp
INNER JOIN Sales.SalesTaxRate AS tr 
	ON tr.StateProvinceID = sp.StateProvinceID
INNER JOIN Sales.CountryRegionCurrency AS crc 
	ON crc.CountryRegionCode = sp.CountryRegionCode
INNER JOIN avrgCurrency AS ac 
	ON ac.CurrencyCode = crc.CurrencyCode
WHERE tr.TaxType = 1 OR tr.TaxType IS NULL;

-- d)
DELETE 
FROM dbo.StateProvince
WHERE CountryRegionCode = 'CA'

-- e)
MERGE dbo.StateProvince AS sp_source USING #StateProvince AS sp_target
ON sp_source.StateProvinceID = sp_target.StateProvinceID
	WHEN MATCHED
	THEN 
		UPDATE SET 
			sp_source.TaxRate = sp_target.TaxRate,
			sp_source.CurrencyCode = sp_target.CurrencyCode,
			sp_source.AverageRate = sp_target.AverageRate
	WHEN NOT MATCHED BY TARGET 
	THEN
		INSERT 
		VALUES (
			sp_target.StateProvinceID,
			sp_target.StateProvinceCode,
			sp_target.CountryRegionCode,
			sp_target.IsOnlyStateProvinceFlag,
			sp_target.Name,
			sp_target.TerritoryID,
			sp_target.ModifiedDate,
			sp_target.TaxRate,
			sp_target.CurrencyCode,
			sp_target.AverageRate
		)
	WHEN NOT MATCHED BY SOURCE THEN DELETE;