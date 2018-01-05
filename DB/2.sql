--Определить для каждой команды средний процент прохождения этапа ее пилотами 

SELECT Company.Name, ROUND(CONVERT(float, SUM(Laps))*100/CONVERT(float,SUM(Lap_amount)),0) AS Percent_Done
FROM PILOT, Contract, Company, Race, Grand_Prix
WHERE (Race.grand_prix_id = grand_prix.id) 
	AND (Pilot.ID = Race.Pilot_ID) 
	AND (Contract.Company_ID = Company.ID) AND (Contract.Pilot_ID = Pilot.ID)
	AND ((DATEDIFF(d, Grand_prix.End_DATE, contract.END_DATE) > 0) or  (contract.END_DATE IS NULL))
GROUP BY Company.Name

