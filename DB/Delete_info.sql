----Изменить Страну за которую выступает пилот
begin tran

SELECT Name, Country
From Pilot, Country
WHERE Pilot.Country_ID = Country.ID
AND Pilot.Name = 'Marcus Ericsson'

UPDATE Pilot
SET Country_ID =
	(SELECT ID FROM Country WHERE Country = 'Russia')
WHERE Name = 'Marcus Ericsson'

SELECT Name, Country
From Pilot, Country
WHERE Pilot.Country_ID = Country.ID
AND Pilot.Name = 'Marcus Ericsson'


rollback


----Продлить контракт с 'Marcus Ericsson'
begin tran

SELECT *
FROM Contract
WHERE Pilot_ID =
	(SELECT ID
	FROM Pilot
	WHERE Name = 'Marcus Ericsson')

UPDATE Contract
SET End_date = '10/03/2015'
WHERE Pilot_ID=
	(SELECT ID
	FROM Pilot
	WHERE Name = 'Marcus Ericsson')

SELECT *
FROM Contract
WHERE Pilot_ID =
	(SELECT ID
	FROM Pilot
	WHERE Name = 'Marcus Ericsson')

rollback




----Изменить характеристику двигателя
begin tran

SELECT * FROM Engine_model

UPDATE Engine_model
SET TURBO = 'NO' WHERE manufacturer = 'FERRARI'

SELECT * FROM Engine_model


rollback






