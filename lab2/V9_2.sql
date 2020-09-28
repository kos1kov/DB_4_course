USE AdventureWorks2012
GO

DROP TABLE dbo.StateProvince
/* 
создайте таблицу dbo.StateProvince с такой же структурой как Person.StateProvince,
кроме пол€ uniqueidentifier, не включа€ индексы, ограничени€ и триггеры;
*/
CREATE TABLE dbo.StateProvince (
								  StateProvinceID         INT         NOT NULL,
								  StateProvinceCode       NCHAR(3)    NOT NULL,
								  CountryRegionCode       NVARCHAR(3) NOT NULL,
								  IsOnlyStateProvinceFlag FLAG        NOT NULL,
								  Name                    NAME        NOT NULL,
								  TerritoryID             INT         NOT NULL,
								  ModifiedDate            DATETIME    NOT NULL);
GO

/* 
использу€ инструкцию ALTER TABLE, создайте дл€ таблицы dbo.StateProvince составной первичный ключ из полей StateProvinceID и StateProvinceCode;
*/

ALTER TABLE dbo.StateProvince ADD CONSTRAINT PK_StateProvince
PRIMARY KEY (StateProvinceID,StateProvinceCode);
GO 

/* 
 использу€ инструкцию ALTER TABLE, создайте дл€ таблицы dbo.StateProvince ограничение дл€ пол€ TerritoryID,
 чтобы значение пол€ могло содержать только четные цифры;
*/

CREATE FUNCTION dbo.EvenDigits (@digit int)
 RETURNS int
 AS 
 BEGIN
   DECLARE @result int
    WHILE @digit <> 0
	 BEGIN
		 SET @result = @digit % 10;
		 IF @result % 2 <> 0
			RETURN 0;
		 SET @digit = (@digit - @result) / 10;
	 END;
	 RETURN 1
 END;
 GO

ALTER TABLE dbo.StateProvince ADD CONSTRAINT CHK_TerritoryID
CHECK (dbo.EvenDigits([TerritoryID]) = 1)
GO
/* 
 использу€ инструкцию ALTER TABLE, создайте дл€ таблицы dbo.StateProvince ограничение DEFAULT дл€ пол€ TerritoryID, задайте значение по умолчанию 2;
*/
ALTER TABLE dbo.StateProvince ADD CONSTRAINT TerritoryID_DEFAULT
DEFAULT 2 FOR TerritoryID;

/* 
 заполните новую таблицу данными из Person.StateProvince. ¬ыберите дл€ вставки только те адреса, которые имеют тип СShippingТ
 в таблице Person.AddressType. — помощью оконных функций дл€ группы данных из полей StateProvinceID и StateProvinceCode выберите
 только строки с максимальным AddressID. ѕоле TerritoryID заполните значени€ми по умолчанию;
*/

INSERT INTO dbo.StateProvince(
	  StateProvinceID,
	  StateProvinceCode,
	  CountryRegionCode,
	  IsOnlyStateProvinceFlag,
	  Name,
	  ModifiedDate
)
SELECT
		StateProvinceID, 
		StateProvinceCode, 
		CountryRegionCode, 
		IsOnlyStateProvinceFlag, 
		Name,
		ModifiedDate
FROM
(SELECT
		stateProvince.StateProvinceID, 
		stateProvince.StateProvinceCode, 
		stateProvince.CountryRegionCode, 
		stateProvince.IsOnlyStateProvinceFlag, 
		stateProvince.Name, 
		stateProvince.ModifiedDate,
		address.AddressID AS AddressID,
		MAX(address.AddressID) OVER (PARTITION BY stateProvince.StateProvinceID, stateProvince.StateProvinceCode) as MaxAddressID
FROM  Person.StateProvince AS stateProvince
INNER JOIN Person.Address AS address
	ON stateProvince.StateProvinceID = address.StateProvinceID
INNER JOIN Person.BusinessEntityAddress AS bussines
	ON address.AddressID = bussines.AddressID
INNER JOIN Person.AddressType AS addresType
	ON addresType.AddressTypeID = bussines.AddressTypeID
	WHERE addresType.Name = 'Shipping') as province
WHERE province.MaxAddressID = province.AddressID;
GO

select * from dbo.StateProvince;
go

/* 
 измените тип пол€ IsOnlyStateProvinceFlag на smallint, разрешите добавление null значений.
*/

ALTER TABLE dbo.StateProvince
	ALTER COLUMN IsOnlyStateProvinceFlag SMALLINT
