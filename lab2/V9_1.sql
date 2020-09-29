use AdventureWorks2012
go
/* 
	������� �� ����� ������� �������� ��������� ������ ��� ������� ����������
*/
select emp.BusinessEntityID, emp.JobTitle, AVG(payHistory.Rate) as AvarageRate   from HumanResources.Employee as emp
inner join HumanResources.EmployeePayHistory as payHistory on payHistory.BusinessEntityID = emp.BusinessEntityID 
GROUP BY emp.[BusinessEntityID], emp.[JobTitle];
GO

/* 
	������� �� ����� ������� ��������� ������ ����������� � ����������� ��� ������ ��� �������� � �������.
	���� ������ ������ ��� ����� 50 ������� �less or equal 50�; ������ 50, �� ������ ��� ����� 100 � ������� �more than 50 but less or equal 100�;
	���� ������ ������ 100 ������� �more than 100�.
*/
select emp.BusinessEntityID, emp.JobTitle, payHistory.Rate, 
	CASE 
		WHEN payHistory.Rate <= 50 
			THEN 'less or equal 50'
		WHEN payHistory.Rate > 50 and payHistory.Rate <= 100
			THEN 'more than 50 but less or equal 100'
		WHEN payHistory.Rate > 100
			THEN 'more than 100'
		END
		AS RateReport from HumanResources.Employee as emp
inner join HumanResources.EmployeePayHistory as payHistory on payHistory.BusinessEntityID = emp.BusinessEntityID ;
GO

/* 
	��������� ������������ ��������� ������ ���������� � ��������� ������ ����������� � ������ ������.
	������� �� ����� �������� �������, � ������� ������������ ��������� ������ ������ 60.
	������������� ��������� �� �������� ������������ ������.
*/
select  Name, MAX(Rate) as MaxRate from HumanResources.Department as dep
inner join HumanResources.EmployeeDepartmentHistory as depHistory on depHistory.DepartmentID = dep.DepartmentID AND ([EndDate] IS NULL)
inner join HumanResources.Employee as emp on emp.BusinessEntityID = depHistory.BusinessEntityID
inner join HumanResources.EmployeePayHistory as payHistory on emp.BusinessEntityID = payHistory.BusinessEntityID and rate > 60
GROUP BY dep.Name 
ORDER BY MaxRate;
GO
