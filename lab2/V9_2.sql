USE AdventureWorks2012
GO

DROP TABLE dbo.StateProvince
/* 
�������� ������� dbo.StateProvince � ����� �� ���������� ��� Person.StateProvince,
����� ���� uniqueidentifier, �� ������� �������, ����������� � ��������;
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
��������� ���������� ALTER TABLE, �������� ��� ������� dbo.StateProvince ��������� ��������� ���� �� ����� StateProvinceID � StateProvinceCode;
*/

ALTER TABLE dbo.StateProvince ADD CONSTRAINT PK_StateProvince
PRIMARY KEY (StateProvinceID,StateProvinceCode);
GO 

/* 
 ��������� ���������� ALTER TABLE, �������� ��� ������� dbo.StateProvince ����������� ��� ���� TerritoryID,
 ����� �������� ���� ����� ��������� ������ ������ �����;
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
 ��������� ���������� ALTER TABLE, �������� ��� ������� dbo.StateProvince ����������� DEFAULT ��� ���� TerritoryID, ������� �������� �� ��������� 2;
*/
ALTER TABLE dbo.StateProvince ADD CONSTRAINT TerritoryID_DEFAULT
DEFAULT 2 FOR TerritoryID;

/* 
 ��������� ����� ������� ������� �� Person.StateProvince. �������� ��� ������� ������ �� ������, ������� ����� ��� �Shipping�
 � ������� Person.AddressType. � ������� ������� ������� ��� ������ ������ �� ����� StateProvinceID � StateProvinceCode ��������
 ������ ������ � ������������ AddressID. ���� TerritoryID ��������� ���������� �� ���������;
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
 �������� ��� ���� IsOnlyStateProvinceFlag �� smallint, ��������� ���������� null ��������.
*/

ALTER TABLE dbo.StateProvince
	ALTER COLUMN IsOnlyStateProvinceFlag SMALLINT
