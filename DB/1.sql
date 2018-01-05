--Определить для каждого пилота количество этапов, количество набранных очков и расположить в порядке убывания.

SELECT Name, Amount_of_GP, Total_Points FROM
	(SELECT Pilot.Name AS N, COUNT(Grand_prix.Name) AS Amount_of_GP, SUM(Points_recieved) AS Total_Points
	FROM Pilot, Race, Grand_prix
	Where (Pilot.id = Race.pilot_id) and (Grand_prix.id = Race.grand_prix_id)
	GROUP BY Pilot.NAME) AS H FULL OUTER Join  Pilot On pilot.name = H.N

ORDER BY Amount_of_GP DESC, Total_Points DESC


