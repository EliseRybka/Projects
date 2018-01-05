--Выбрать этапы, на которых большинство очков набирали пилоты на резине 'SOFT'
SELECT Helping1.Name
From		
	(SELECT grand_prix.Name, SUM(Points_recieved) As P, Tires_type
		FROM Pilot, Race, Tires, grand_prix
		WHERE  (Pilot.ID = Race.Pilot_ID) And (Start_tires = tires_id) and (grand_prix.id = race.grand_prix_id)
		GROUP BY GRAND_PRIX.Name, Tires_TYPE)As Helping1,

	(SELECT Name, Max(Helping2.P) AS Max
	 FROM  (SELECT grand_prix.Name, SUM(Points_recieved) As P, Tires_type
			FROM Pilot, Race, Tires, grand_prix
			WHERE  (Pilot.ID = Race.Pilot_ID) And (Start_tires = tires_id) and (grand_prix.id = race.grand_prix_id)
			GROUP BY GRAND_PRIX.Name, Tires_TYPE) AS Helping2
	Group by Name) Helping3

Where (P = Max) AND (Tires_type = 'Soft') AND (Helping1.Name = Helping3.Name)