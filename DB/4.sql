--Для каждого пилота определить среднюю скорость на этапе за год.

SELECT Name, AVG_speed_M_per_SEC  FROM

(Select SpName, AVG(Speed) AS AVG_speed_M_per_SEC from
	(SELECT Pilot.Name As SpName, Time, Laps, Lap_length_m, Round(convert(float, Convert(int,Laps)*Lap_length_m)/Convert(float,(Datediff(ss, '19000101', time))),2) As Speed
		FROM Pilot, Race, Grand_Prix
		WHERE   (Pilot.ID = Race.Pilot_ID) and 
				(Race.Grand_prix_id = Grand_prix.id) AND 
				(Time is not null)) AS H
		GROUP BY SpName)AS help FULL OUTER Join Pilot On pilot.name = Help.SpName

ORDER BY NAME


