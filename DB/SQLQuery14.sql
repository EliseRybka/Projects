-- обнулить очки пилотам команды Ferrari во время гран при Австралия
begin tran

SELECT Grand_prix.Name, Pilot_ID, points_recieved 
FROM race, grand_prix 
WHERE race.grand_prix_id = grand_prix.id 
	AND grand_prix.end_date = '16/03/2014' And pilot_id in (SELECT Pilot_id FROM Contract WHERE Company_ID = (SELECT ID FROM Company WHERE Name = 'Ferrari'))
ORDER BY grand_prix.id;






UPDATE RACE
SET Points_recieved = 0 
	WHERE (Points_recieved IS NOT NULL) AND 
		grand_prix_ID = (
			SELECT ID 
			FROM grand_prix
			WHERE (Name = 'Australian Grand Prix')
		) AND 
		Pilot_ID IN (
			SELECT Pilot_ID 
			FROM Contract AS c
			WHERE (DATEDIFF(dd, start_date, '16/03/2014') >= 0 AND 
				(end_date IS NULL OR (DATEDIFF(dd, '16/03/2014', end_date) >= 0)))
				AND Company_ID = (SELECT ID FROM Company WHERE Name = 'Ferrari')
		)


SET points_recieved = 0
where 










SELECT Grand_prix.Name, Pilot_ID, points_recieved 
FROM race, grand_prix 
WHERE race.grand_prix_id = grand_prix.id 
	AND grand_prix.end_date = '16/03/2014' And pilot_id in (SELECT Pilot_id FROM Contract WHERE Company_ID = (SELECT ID FROM Company WHERE Name = 'Ferrari'))
ORDER BY grand_prix.id;

rollback