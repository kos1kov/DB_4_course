USE AdventureWorks2012;
GO

DECLARE @xml XML;

SET @xml = (
SELECT
    edh.StartDate AS 'Start',
    edh.EndDate AS 'End',
    dep.GroupName AS 'Department/Group',
    dep.Name AS 'Department/Name'
FROM
    HumanResources.EmployeeDepartmentHistory AS edh 
    INNER JOIN HumanResources.Department AS dep
        ON edh.DepartmentID = dep.DepartmentID
FOR XML PATH ('Transaction'), ROOT ('History')
);

SELECT @xml;


CREATE TABLE #temp
(
    [sql] XML
);

INSERT INTO #temp 
SELECT xml.node.query('.')
FROM @xml.nodes('/History/Transaction/Department') AS xml(node);
GO

SELECT * FROM #temp;