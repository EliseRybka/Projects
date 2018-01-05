SELECT Last_Name, First_Name, Job.Job_ID, DATEDIFF(hh,Hire_Date,current_timestamp)/8760  AS Work_Experince_Years, Salary

FROM   ((Employee INNER JOIN Job ON Employee.Job_ID = Job.Job_ID)  
INNER JOIN Department ON Department.Department_ID = Employee.Department_ID)
INNER JOIN Location ON (Location.Location_ID = Department.Location_ID AND Regional_Group = 'NEW YORK'),

(SELECT DATEDIFF(hh,Hire_Date,current_timestamp)/8760  AS WT, MAX(Salary) AS MS
FROM Employee
GROUP BY DATEDIFF(hh,Hire_Date,current_timestamp)/8760 ) AS HT

WHERE Employee.Salary = HT.MS
AND HT.WT = DATEDIFF(hh,Hire_Date,current_timestamp)/8760