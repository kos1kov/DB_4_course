CREATE DATABASE NewDatabase;
Go

USE NewDatabase;
GO

CREATE SCHEMA sales;
GO

CREATE SCHEMA persons;
GO

CREATE TABLE sales.Orders (OrderNum INT NULL);

BACKUP DATABASE NewDatabase
TO DISK = 'C:\MyDdisk\MyDatabase.bak';

USE master
GO 

DROP DATABASE NewDatabase;

RESTORE DATABASE NewDatabase
FROM DISK = 'C:\MyDdisk\MyDatabase.bak';

USE NewDatabase
GO