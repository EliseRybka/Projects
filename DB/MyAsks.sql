----ƒл€ пилота вывести его максимальный результат и этап, на котором максимум достигнут, в истории
SELECT  Pilot.Name, maxscore, gp.Name, CONVERT(VARCHAR(10),end_date,104) as race_date
	FROM pilot, grand_prix AS gp, race, 
		(SELECT Pilot_ID, max(points_recieved) AS maxscore
			FROM race
			GROUP BY Pilot_ID) as t
	WHERE pilot.ID = t.pilot_ID 
		AND race.pilot_ID = t.pilot_ID 
		AND race.grand_prix_ID = gp.ID
		AND points_recieved = maxscore
ORDER BY maxscore



