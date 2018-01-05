DROP TABLE works;
DROP TABLE work_type;
DROP TABLE Pit_stop;
DROP TABLE race;
DROP TABLE Tires;
DROP TABLE qualification;
DROP TABLE free_ride;
DROP TABLE engine;
DROP TABLE engine_model;
DROP TABLE Grand_prix;
DROP TABLE Contract;
DROP TABLE Penalty_company;
DROP TABLE Penalty_Pilot;
DROP TABLE Penalty;
DROP TABLE Company;
DROP TABLE Pilot;
DROP TABLE Country;



CREATE TABLE Company (
	Id SMALLINT NOT NULL identity(1,1),
	Name VARCHAR(30) NOT NULL,
	Country_ID SMALLINT,
	Foundation_Year SMALLINT CHECK( Foundation_Year < 2015),
	PRIMARY KEY (Id)
);

CREATE TABLE Country (
	ID SMALLINT NOT NULL identity(1,1),
	Country VARCHAR(60) NOT NULL,
	PRIMARY KEY (ID)
);

CREATE TABLE Pilot (
	ID SMALLINT NOT NULL identity(1,1),
	Name NVARCHAR(255) NOT NULL,
	Country_ID SMALLINT,
	Date_of_Birth DATETIME,
	PRIMARY KEY (ID)
);

CREATE TABLE Contract (
	ID SMALLINT NOT NULL identity(1,1),
	Pilot_ID SMALLINT NOT NULL,
	Company_ID SMALLINT NOT NULL,
	Start_Date DATETIME NOT NULL,
	End_Date DATETIME,
	CHECK (DATEDIFF (ss, start_date, end_date) >= 0),
	PRIMARY KEY (ID)
);

CREATE TABLE Grand_Prix (
	ID SMALLINT NOT NULL identity(1,1),
	Name VARCHAR(60) NOT NULL,
	Country_ID SMALLINT NOT NULL,
	Lap_amount TINYINT,
	Lap_length_m SMALLINT,
	Attendence INT,
	Start_Date DATETIME,
	End_date DATETIME, 
	CHECK (DATEDIFF (ss, start_date, end_date) >= 0),
	PRIMARY KEY (ID)
);

CREATE TABLE Free_ride (
	Grand_Prix_ID SMALLINT NOT NULL,
	Pilot_ID SMALLINT NOT NULL,
	Number_of_Laps TINYINT, 
	Engine_ID SMALLINT,
	PRIMARY KEY(Grand_Prix_ID, Pilot_ID)
);

CREATE TABLE Qualification (
	Grand_Prix_ID SMALLINT NOT NULL ,
	Pilot_ID SMALLINT NOT NULL,
	Number TINYINT,
	Engine_ID SMALLINT,
	Best_time_1_sec  DATETIME,
	Best_time_2 DATETIME,
	Best_time_3  DATETIME,
	PRIMARY KEY (Grand_Prix_ID, Pilot_ID)
);

CREATE TABLE Race (
	Grand_Prix_ID SMALLINT NOT NULL,
	Pilot_ID SMALLINT NOT NULL,
Number TINYINT,
Engine_ID SMALLINT,
	Laps TINYINT,
	Time DATETIME,
	Best_Speed_Lap  NUMERIC(10,3),
Start_tires  SMALLINT,
	Start_Place TINYINT,
	Finish_Place TINYINT,
Points_recieved TINYINT,

PRIMARY KEY (Grand_Prix_ID, Pilot_ID)
);

CREATE TABLE Engine (
	ID SMALLINT NOT NULL identity(1,1),
	Company_ID SMALLINT NOT NULL,
	Model_ID SMALLINT NOT NULL,
	Break_down_date  DATETIME,
PRIMARY KEY (ID)
);

CREATE TABLE Engine_Model (
	ID SMALLINT NOT NULL,
	Name VARCHAR(100) NOT NULL,
	Manufacturer VARCHAR(50),
	Volume  NUMERIC(3,1),
	Cylinder VARCHAR(3) ,
	Turbo VARCHAR(3) CHECK(Turbo IN ('YES','NO')),
PRIMARY KEY (ID )
);

CREATE TABLE Tires (
	Tires_ID SMALLINT NOT NULL,
	Tires_type VARCHAR(30) NOT NULL,
PRIMARY KEY (Tires_ID)
);

CREATE TABLE Pit_stop (
	Pit_stop_id SMALLINT NOT NULL identity(1,1),
	Grand_Prix_ID SMALLINT NOT NULL,
	Pilot_ID SMALLINT NOT NULL,
	Time_sec  NUMERIC(5,3),
	Penalty VARCHAR(3) CHECK(Penalty IN ('YES','NO')),
	Tires_changed_to SMALLINT,
PRIMARY KEY (Pit_stop_id)
);

CREATE TABLE Works (
	Pit_stop_id SMALLINT NOT NULL,
	w_type_id SMALLINT NOT NULL,
PRIMARY KEY (Pit_stop_id, w_type_id)
);

CREATE TABLE Work_Type (
	ID SMALLINT NOT NULL,
	Name VARCHAR(30) NOT NULL,
PRIMARY KEY (ID)
);

CREATE TABLE Penalty_Company (
	ID SMALLINT NOT NULL identity(1,1),
	Company_ID  SMALLINT NOT NULL,
	Grand_prix_ID  SMALLINT,
	Penalty_ID  SMALLINT NOT NULL,
	Penalty_Specification VARCHAR(255),
	Reason VARCHAR(255),
	Date DATETIME NOT NULL,
PRIMARY KEY (ID)
);

CREATE TABLE Penalty_Pilot (
	ID  SMALLINT NOT NULL identity(1,1),
	Pilot_ID  SMALLINT NOT NULL,
	Grand_prix_ID  SMALLINT,
	Penalty_ID  SMALLINT NOT NULL,
	Penalty_Specification VARCHAR(255),
	Reason VARCHAR(255),
	Date DATETIME NOT NULL,
PRIMARY KEY (ID)
);

CREATE TABLE Penalty (
	Penalty_ID SMALLINT NOT NULL,
	Name VARCHAR(50) NOT NULL,
PRIMARY KEY (Penalty_ID)
);





ALTER TABLE Company ADD
	FOREIGN KEY (Country_ID) REFERENCES  Country (id)

ALTER TABLE Pilot ADD
	FOREIGN KEY (Country_ID) REFERENCES  Country (id)

ALTER TABLE Contract ADD
	FOREIGN KEY (Company_id) REFERENCES Company (id),
	FOREIGN KEY (Pilot_id) REFERENCES Pilot (id)

ALTER TABLE Grand_Prix ADD
	FOREIGN KEY (Country_ID) REFERENCES Country (id)

ALTER TABLE Free_ride ADD
	FOREIGN KEY (Pilot_id) REFERENCES  Pilot  (id),
	FOREIGN KEY (Grand_prix_id) REFERENCES Grand_prix (id),
	FOREIGN KEY (Engine_id) REFERENCES Engine (id)
	

ALTER TABLE Qualification ADD
	FOREIGN KEY (Pilot_id) REFERENCES  Pilot  (id),
	FOREIGN KEY (Grand_prix_id) REFERENCES Grand_prix (id),
	FOREIGN KEY (Engine_id) REFERENCES Engine (id)

ALTER TABLE Race ADD
	FOREIGN KEY (Pilot_id) REFERENCES  Pilot  (id),
	FOREIGN KEY (Grand_prix_id) REFERENCES Grand_prix (id),
	FOREIGN KEY (Engine_id) REFERENCES Engine (id),
	FOREIGN KEY (Start_tires) REFERENCES Tires (Tires_id)


ALTER TABLE Engine ADD
	FOREIGN KEY (Company_id) REFERENCES Company (id),
	FOREIGN KEY (Model_ID) REFERENCES Engine_Model (id)
	

ALTER TABLE Pit_stop ADD
	FOREIGN KEY (Pilot_id) REFERENCES  Pilot  (id),
	FOREIGN KEY (Grand_prix_id) REFERENCES Grand_prix (id),
	FOREIGN KEY (Tires_changed_to) REFERENCES Tires (Tires_id)

ALTER TABLE Works ADD
	FOREIGN KEY (Pit_stop_id) REFERENCES  Pit_stop (Pit_stop_id),
	FOREIGN KEY (w_type_id) REFERENCES work_type (id)

ALTER TABLE Penalty_Company ADD
	FOREIGN KEY (Company_id) REFERENCES Company (id),
	FOREIGN KEY (Penalty_id) REFERENCES Penalty (Penalty_id)

ALTER TABLE Penalty_Pilot ADD
	FOREIGN KEY (Pilot_id) REFERENCES Pilot(id),
	FOREIGN KEY (Penalty_id) REFERENCES Penalty (Penalty_id)



--DROP FUNCTION dbo.EngineCheck 
--
--GO 

--CREATE FUNCTION EngineCheck(@RaceDate SMALLINT, @Engine SMALLINT) 
--RETURNS SMALLINT 
--AS 
--BEGIN 
--RETURN (
--SELECT COUNT(*) FROM Grand_Prix, Engine 
--WHERE (Grand_Prix.ID = @RaceDate) and (Engine.ID = @Engine) and ((End_date <  Break_down_date) OR (BREAK_down_date is null))
--) 
--END; 
--
--GO 
--
--ALTER TABLE Race
--ADD CONSTRAINT Check_EngineCheck_Race 
--CHECK (dbo.EngineCheck(Grand_Prix_ID, Engine_ID) <> 0);
