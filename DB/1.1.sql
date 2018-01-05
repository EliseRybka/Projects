SELECT First_Name, Last_Name, E.Salary, E.Job_ID

FROM Employee AS E, 
(SELECT Job_ID, MAX(Salary) AS Salary FROM Employee GROUP BY Job_ID) AS M

WHERE E.Salary = M.Salary AND E.Job_ID = M.Job_ID

ORDER BY Salary


