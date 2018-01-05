begin tran

SELECT Pilot_id, Finish_place, Points_recieved From Race where (Grand_Prix_id = 1)
Order by Finish_place

UPDATE RACE SET  points_recieved = (SELECT points_recieved from race where (finish_place = 10) and (Grand_Prix_id = 1))  where (finish_place = 11) and (Grand_Prix_id = 1)
UPDATE RACE SET  points_recieved = (SELECT points_recieved from race where (finish_place = 9) and (Grand_Prix_id = 1))  where (finish_place = 10) and (Grand_Prix_id = 1)
UPDATE RACE SET  points_recieved = (SELECT points_recieved from race where (finish_place = 8) and (Grand_Prix_id = 1))  where (finish_place = 9) and (Grand_Prix_id = 1)
UPDATE RACE SET  points_recieved = (SELECT points_recieved from race where (finish_place = 7) and (Grand_Prix_id = 1))  where (finish_place = 8) and (Grand_Prix_id = 1)
UPDATE RACE SET  points_recieved = (SELECT points_recieved from race where (finish_place = 6) and (Grand_Prix_id = 1))  where (finish_place = 7) and (Grand_Prix_id = 1)
UPDATE RACE SET  points_recieved = (SELECT points_recieved from race where (finish_place = 5) and (Grand_Prix_id = 1))  where (finish_place = 6) and (Grand_Prix_id = 1)
UPDATE RACE SET  points_recieved = (SELECT points_recieved from race where (finish_place = 4) and (Grand_Prix_id = 1))  where (finish_place = 5) and (Grand_Prix_id = 1)
UPDATE RACE SET  points_recieved = (SELECT points_recieved from race where (finish_place = 3) and (Grand_Prix_id = 1))  where (finish_place = 4) and (Grand_Prix_id = 1)


UPDATE RACE 
SET points_recieved = 0 where (finish_place = 3) and (Grand_Prix_id = 1)
UPDATE RACE 
SET finish_place = finish_place - 1 Where (finish_place > 3) and (Grand_Prix_id = 1)
UPDATE RACE 
Set finish_place = NULL where (finish_place) = 3 and (points_recieved = 0) and (Grand_Prix_id = 1)

SELECT Pilot_id, Finish_place, Points_recieved  From Race where Grand_Prix_id = 1
Order by Finish_place

rollback