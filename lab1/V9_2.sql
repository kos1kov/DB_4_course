use AdventureWorks2012
go
/* 
	Вывести на экран сотрудников, которые родились позже 1980 года (но не в 1980 год) и были приняты на работу позже 1-ого апреля 2003 года.
*/
select Employee.BusinessEntityID, Employee.JobTitle, Employee.BirthDate, Employee.HireDate from HumanResources.Employee where BirthDate >= '1981-01-01' 
and HireDate > '2003-04-01';

/* 
	Вывести на экран сумму часов отпуска и сумму больничных часов у сотрудников. 
	Назовите столбцы с результатами ‘SumVacationHours’ и ‘SumSickLeaveHours’ для отпусков и больничных соответственно.
*/
select SUM(Employee.VacationHours) as  'SumVacationHours', SUM(Employee.SickLeaveHours) as 'SumSickLeaveHours' from HumanResources.Employee;

/* 
  Вывести на экран первых трех сотрудников, которых раньше всех остальных приняли на работу.
*/
select TOP 3 Employee.BusinessEntityID, Employee.JobTitle, Employee.Gender, Employee.BirthDate, Employee.HireDate from HumanResources.Employee 
order by HireDate ;
