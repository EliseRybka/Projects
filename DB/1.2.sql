SELECT City, D.Department_ID, COUNT(Order_ID) AS Number_Servings 
FROM  Sales_Order AS S, Customer AS C, Employee AS E, Department AS D


WHERE S.Customer_ID = C.Customer_ID
AND Salesperson_ID = Employee_ID
AND E.Department_ID = D.Department_ID
AND D.Name = 'SALES'

GROUP BY City, D.Department_ID
ORDER BY City


