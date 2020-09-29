use AdventureWorks2012
go
/* 
	������� �� ����� �����������, ������� �������� ����� 1980 ���� (�� �� � 1980 ���) � ���� ������� �� ������ ����� 1-��� ������ 2003 ����.
*/
select Employee.BusinessEntityID, Employee.JobTitle, Employee.BirthDate, Employee.HireDate from HumanResources.Employee where BirthDate >= '1981-01-01' 
and HireDate > '2003-04-01';

/* 
	������� �� ����� ����� ����� ������� � ����� ���������� ����� � �����������. 
	�������� ������� � ������������ �SumVacationHours� � �SumSickLeaveHours� ��� �������� � ���������� ��������������.
*/
select SUM(Employee.VacationHours) as  'SumVacationHours', SUM(Employee.SickLeaveHours) as 'SumSickLeaveHours' from HumanResources.Employee;

/* 
  ������� �� ����� ������ ���� �����������, ������� ������ ���� ��������� ������� �� ������.
*/
select TOP 3 Employee.BusinessEntityID, Employee.JobTitle, Employee.Gender, Employee.BirthDate, Employee.HireDate from HumanResources.Employee 
order by HireDate ;
