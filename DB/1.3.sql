SELECT 'SP TENNIS RACKET' AS Product, SUM((Actual_Price - Min_Price) * Quantity) AS Profit

FROM ((Item INNER JOIN Sales_order ON Item.Order_ID = Sales_order.Order_ID) 
INNER JOIN Product ON Item.Product_ID = Product.Product_ID) 
INNER JOIN Price ON ((Item.Product_ID = Price.Product_ID) AND ((Ship_Date BETWEEN Start_Date AND End_Date) OR (Ship_Date > Start_Date AND End_Date IS 
NULL)))

WHERE Description = 'SP TENNIS RACKET'
AND Actual_Price > Min_Price