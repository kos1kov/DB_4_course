use AdventureWorks2012
go
/* 
	¬ывести на экран среднее значение почасовой ставки дл€ каждого сотрудника
*/
select emp.BusinessEntityID, emp.JobTitle, AVG(payHistory.Rate) as AvarageRate   from HumanResources.Employee as emp
inner join HumanResources.EmployeePayHistory as payHistory on payHistory.BusinessEntityID = emp.BusinessEntityID 
GROUP BY emp.[BusinessEntityID], emp.[JobTitle];
GO

/* 
	¬ывести на экран историю почасовых ставок сотрудников с информацией дл€ отчета как показано в примере.
	≈сли ставка меньше или равна 50 вывести Сless or equal 50Т; больше 50, но меньше или равна 100 Ц вывести Сmore than 50 but less or equal 100Т;
	если ставка больше 100 вывести Сmore than 100Т.
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
	¬ычислить максимальную почасовую ставку работающих в насто€щий момент сотрудников в каждом отделе.
	¬ывести на экран названи€ отделов, в которых максимальна€ почасова€ ставка больше 60.
	ќтсортировать результат по значению максимальной ставки.
*/
select  Name, MAX(Rate) as MaxRate from HumanResources.Department as dep
inner join HumanResources.EmployeeDepartmentHistory as depHistory on depHistory.DepartmentID = dep.DepartmentID AND ([EndDate] IS NULL)
inner join HumanResources.Employee as emp on emp.BusinessEntityID = depHistory.BusinessEntityID
inner join HumanResources.EmployeePayHistory as payHistory on emp.BusinessEntityID = payHistory.BusinessEntityID and rate > 60
GROUP BY dep.Name 
ORDER BY MaxRate;
GO
