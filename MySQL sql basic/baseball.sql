-- baseball.sql
-- Part 1
-- 1.
	
-- a.
SELECT count(DISTINCT playerID) AS player_missing_birthday
FROM Master
WHERE birthMonth='0'
  	OR birthDay='0'
  	OR birthYear='0';

-- MySql Output
-- +-------------------------+
-- | player_missing_birthday |
-- +-------------------------+
-- |                     449 |
-- +-------------------------+
-- 1 row in set (0.07 sec)

-- b.
SELECT
	(SELECT count(*) AS alive
	 FROM
	 (SELECT DISTINCT HallOfFame.playerID,
	                  deathCountry
	  FROM HallOfFame
	  INNER JOIN Master ON HallOfFame.playerID = Master.playerID) AS temp1
	WHERE deathCountry = '') -
	(SELECT count(*) AS dead
	 FROM
	 (SELECT DISTINCT HallOfFame.playerID,
	                  deathCountry
	  FROM HallOfFame
	  INNER JOIN Master ON HallOfFame.playerID = Master.playerID) AS temp2
	WHERE deathCountry != '') AS alive_minus_dead;

-- MySql Output
-- +------------------+
-- | alive_minus_dead |
-- +------------------+
-- |              -47 |
-- +------------------+
-- 1 row in set (0.06 sec)

-- c.
SELECT nameFirst,
       nameLast,
       nameGiven,
       salary_sum AS largest_total_salary
FROM Master
INNER JOIN
    (SELECT playerID,
            SUM(salary) AS salary_sum
     FROM Salaries
     GROUP BY playerID) AS max_salary_list ON max_salary_list.playerID = Master.playerID
ORDER BY salary_sum DESC
LIMIT 1;

-- MySql Output
-- +-----------+-----------+--------------------+----------------------+
-- | nameFirst | nameLast  | nameGiven          | largest_total_salary |
-- +-----------+-----------+--------------------+----------------------+
-- | Alex      | Rodriguez | Alexander Enmanuel |            398416252 |
-- +-----------+-----------+--------------------+----------------------+
-- 1 row in set (0.15 sec)

-- d.
SELECT AVG(individual_hr_sum) AS average_hr
FROM
  (SELECT playerID,
          Sum(HR) AS individual_hr_sum
   FROM Batting
   GROUP BY playerID) AS sum_list;

-- MySql Output
-- +------------+
-- | average_hr |
-- +------------+
-- |    15.2938 |
-- +------------+
-- 1 row in set (0.12 sec)



-- e.
SELECT AVG(individual_hr_sum_without_zero) AS average_hr_without_zero
FROM
  (SELECT playerID,
          Sum(HR) AS individual_hr_sum_without_zero
   FROM Batting
   GROUP BY playerID
   HAVING avg(HR) > 0) AS sum_list;

-- MySql Output
-- +-------------------------+
-- | average_hr_without_zero |
-- +-------------------------+
-- |                 37.3944 |
-- +-------------------------+
-- 1 row in set (0.12 sec)

-- f. 
SELECT count(*) AS good_player
FROM
  (SELECT playerID,
          Sum(HR) AS individual_hr_sum
   FROM Batting
   GROUP BY playerID
   HAVING individual_hr_sum >
     (SELECT AVG(individual_hr_sum)
      FROM
        (SELECT playerID,
                Sum(HR) AS individual_hr_sum
         FROM Batting
         GROUP BY playerID) AS hr_sum_list)) AS good_batter_list
INNER JOIN
  (SELECT playerID,
          Sum(SO) AS individual_so_sum
   FROM Pitching
   GROUP BY playerID
   HAVING individual_so_sum >
     (SELECT AVG(individual_so_sum)
      FROM
        (SELECT playerID,
                Sum(SO) AS individual_so_sum
         FROM Pitching
         GROUP BY playerID) AS so_sum_list)) AS good_pitcher_list ON good_batter_list.playerID = good_pitcher_list.playerID;

-- MySql Output
-- +-------------+
-- | good_player |
-- +-------------+
-- |          39 |
-- +-------------+
-- 1 row in set (0.34 sec)

-- 2.
-- SET GLOBAL local_infile = true;
LOAD DATA LOCAL INFILE '/Users/jinmingzhang/Downloads/Fielding.csv' 
INTO TABLE Fielding
FIELDS TERMINATED BY ',' -- csv separater
LINES TERMINATED BY '\n' -- new line character
IGNORE 1 ROWS -- column name
(playerID,yearID,stint,	teamID,lgID,	POS,	G,	GS,	InnOuts,	@PO,	@A,	@E,	@DP,	PB,	WP,	SB,	CS,	ZR)
  SET PO = IF(@PO = '', NULL, @PO), 
  A = IF(@A = '', NULL, @A), 
  E = IF(@E = '', NULL, @E), 
  DP = IF(@DP = '', NULL, @DP); 

-- 3.
-- Primary Keys:
-- Primary key requirements: the selected tuple for the primary key must be unique. A good primary key should have a minimum number of attributes in its tuple set.
-- The way we used to find Primary key is by including the attributes into the Primary key set one by one. If the set is not unique, the database will return an error.
-- When we increase the Primary key set to the point where the database can successfully create the Primary key, we then try to remon the previous attributes in the set one by one
-- while ensure that the Primary key set is still unique. This will help us to create a primary key that has a minimum number of attributes in its tuple set.

ALTER TABLE TeamsHalf ADD CONSTRAINT PK_TeamsHalf PRIMARY KEY (yearID, teamID, lgID, Half);
ALTER TABLE TeamsFranchises ADD CONSTRAINT PK_TeamsFranchises PRIMARY KEY (franchID);
ALTER TABLE Teams ADD CONSTRAINT PK_Teams PRIMARY KEY (yearID, teamID);
ALTER TABLE SeriesPost ADD CONSTRAINT PK_SeriesPost PRIMARY KEY (yearID, round);
ALTER TABLE Schools ADD CONSTRAINT PK_Schools PRIMARY KEY (schoolID);
ALTER TABLE Salaries ADD CONSTRAINT PK_Salaries PRIMARY KEY (yearID,teamID,lgID,playerID);
ALTER TABLE PitchingPost ADD CONSTRAINT PK_PitchingPost PRIMARY KEY (playerID,yearID,round);
ALTER TABLE Pitching ADD CONSTRAINT PK_Pitching PRIMARY KEY (playerID,yearID,stint);
ALTER TABLE Parks ADD CONSTRAINT PK_Parks PRIMARY KEY (`park.key`);
ALTER TABLE Master ADD CONSTRAINT PK_Master PRIMARY KEY (playerID);
ALTER TABLE ManagersHalf ADD CONSTRAINT PK_ManagersHalf PRIMARY KEY (playerID, yearID, teamID, half);
ALTER TABLE AllstarFull
ADD CONSTRAINT PK_AllstarFull PRIMARY KEY (playerID,gameID);
ALTER TABLE Appearances
ADD CONSTRAINT PK_Appearances PRIMARY KEY (playerID,yearID,teamID);
ALTER TABLE AwardsManagers
ADD CONSTRAINT PK_Appearances PRIMARY KEY (playerID,awardID,yearID);
ALTER TABLE AwardsPlayers
ADD CONSTRAINT PK_AwardsPlayers PRIMARY KEY (playerID,yearID,lgID,awardID);
ALTER TABLE AwardsShareManagers
ADD CONSTRAINT PK_AwardsShareManagers PRIMARY KEY (playerID,yearID);
ALTER TABLE AwardsSharePlayers
ADD CONSTRAINT PK_AwardsSharePlayers PRIMARY KEY (playerID,yearID,awardID);
ALTER TABLE Batting
ADD CONSTRAINT PK_Batting PRIMARY KEY (playerID,yearID,stint);
ALTER TABLE BattingPost
ADD CONSTRAINT PK_BattingPost PRIMARY KEY (playerID,yearID,round);
ALTER TABLE CollegePlaying
ADD CONSTRAINT PK_CollegePlaying PRIMARY KEY (playerID,yearID,schoolID);
ALTER IGNORE TABLE Fielding
ADD CONSTRAINT PK_Fielding PRIMARY KEY (playerID,yearID,stint,POS); -- this table is affected by q2 in part 1. There are duplicates that must be removed for the primary key.
-- it will introduce 1 warning which is:
-- +---------+------+-----------------------------------------------------------------+
-- | Level   | Code | Message                                                         |
-- +---------+------+-----------------------------------------------------------------+
-- | Warning | 1681 | 'IGNORE' is deprecated and will be removed in a future release. |
-- +---------+------+-----------------------------------------------------------------+
-- 1 row in set (0.02 sec)
-- however, this doesn't affect the correctness of the code
ALTER TABLE FieldingOF
ADD CONSTRAINT PK_FieldingOF PRIMARY KEY (playerID,yearID,stint);
ALTER TABLE FieldingOFsplit
ADD CONSTRAINT PK_FieldingOFsplit PRIMARY KEY (playerID,yearID,stint,POS);
ALTER TABLE FieldingPost
ADD CONSTRAINT PK_FieldingPost PRIMARY KEY (playerID,yearID,POS,round);
ALTER TABLE HallOfFame
ADD CONSTRAINT PK_HallOfFame PRIMARY KEY (playerID,yearID,votedBy);
ALTER TABLE HomeGames
ADD CONSTRAINT PK_HomeGames PRIMARY KEY (`park.key`,`span.first`);
ALTER TABLE Managers
ADD CONSTRAINT PK_Managers PRIMARY KEY (playerID,yearID,inseason);
 
 
-- Foreign Key

-- In order to ensure data consistancy, data cleaning is required if the current database has the rows that cannot be found in the targeted table for the Foreign Key
-- code structure for data cleaning
-- DELETE FROM table_name WHERE condition;

-- code structure for adding Foreign Key
-- ALTER TABLE Orders
-- ADD CONSTRAINT FK_PersonOrder
-- FOREIGN KEY (PersonID) REFERENCES Persons(PersonID);

-- data cleaning example:
-- DELETE FROM CollegePlaying WHERE playerID NOT IN (select playerID FROM Master);
-- DELETE FROM CollegePlaying WHERE schoolID NOT IN (select schoolID FROM Schools);
-- DELETE FROM CollegePlaying WHERE yearID NOT IN (select yearID FROM Master);
-- DELETE FROM CollegePlaying WHERE teamID NOT IN (select teamID FROM Master);

-- This line is from piazza. This will help us to bypass the data cleaning for data consistancy
SET foreign_key_checks = 0;

-- Foreign Key is used to link 2 tables together (current table -> targeted table's primary key). As the Foreign Key created successfully, if the data value changes
-- in the current tablle, the value in the Foreign table will be updated accordingly. 

-- the way we used to create the Foreign Key is to find the primary keys in the Foreign table first. Then we link the corresponding attributes in the current table to 
-- the Foreign table's primary keys to form Foreign Key.

ALTER TABLE AllstarFull ADD CONSTRAINT fk_AllstarFull_Teams FOREIGN KEY (yearID,teamID) REFERENCES  Teams(yearID,teamID);
ALTER TABLE AllstarFull ADD CONSTRAINT fk_AllstarFull_Master FOREIGN KEY (playerID) REFERENCES  Master(playerID);
ALTER TABLE HallOfFame ADD CONSTRAINT fk_HallOfFame_Master FOREIGN KEY (playerID) REFERENCES  Master(playerID);
ALTER TABLE Managers ADD CONSTRAINT fk_Managers_Teams FOREIGN KEY (yearID,teamID) REFERENCES  Teams(yearID,teamID);
ALTER TABLE Managers ADD CONSTRAINT fk_Managers_Master FOREIGN KEY (playerID) REFERENCES  Master(playerID);
ALTER TABLE Teams ADD CONSTRAINT fk_Teams_TeamsFranchises FOREIGN KEY (franchID) REFERENCES  TeamsFranchises(franchID);
ALTER TABLE BattingPost ADD CONSTRAINT fk_BattingPost_Teams FOREIGN KEY (yearID,teamID) REFERENCES  Teams(yearID,teamID);
ALTER TABLE BattingPost ADD CONSTRAINT fk_BattingPost_Master FOREIGN KEY (playerID) REFERENCES  Master(playerID);
ALTER TABLE PitchingPost ADD CONSTRAINT fk_PitchingPost_Teams FOREIGN KEY (yearID,teamID) REFERENCES  Teams(yearID,teamID);
ALTER TABLE PitchingPost ADD CONSTRAINT fk_PitchingPost_Master FOREIGN KEY (playerID) REFERENCES  Master(playerID);
ALTER TABLE TeamsFranchises ADD CONSTRAINT fk_TeamsFranchises_Teams FOREIGN KEY (franchID) REFERENCES  Teams(franchID);
ALTER TABLE Fielding ADD CONSTRAINT fk_Fielding_Batting FOREIGN KEY (playerID,yearID,stint) REFERENCES  Batting(playerID,yearID,stint);
ALTER TABLE Fielding ADD CONSTRAINT fk_Fielding_Pitching FOREIGN KEY (playerID,yearID,stint) REFERENCES  Pitching(playerID,yearID,stint);
ALTER TABLE Fielding ADD CONSTRAINT fk_Fielding_FieldingOF FOREIGN KEY (playerID,yearID,stint) REFERENCES  FieldingOF(playerID,yearID,stint);
ALTER TABLE Fielding ADD CONSTRAINT fk_Fielding_FieldingOFsplit FOREIGN KEY (playerID,yearID,stint) REFERENCES  FieldingOFsplit(playerID,yearID,stint);
ALTER TABLE FieldingOF ADD CONSTRAINT fk_FieldingOF_Master FOREIGN KEY (playerID) REFERENCES  Master(playerID);
ALTER TABLE FieldingOF ADD CONSTRAINT fk_FieldingOF_Batting FOREIGN KEY (playerID,yearID,stint) REFERENCES  Batting(playerID,yearID,stint);
ALTER TABLE FieldingPost ADD CONSTRAINT fk_FieldingPost_Master FOREIGN KEY (playerID) REFERENCES  Master(playerID);
ALTER TABLE FieldingPost ADD CONSTRAINT fk_FieldingPost_Teams FOREIGN KEY (yearID, teamID) REFERENCES  Teams(yearID, teamID);
ALTER TABLE FieldingPost ADD CONSTRAINT fk_FieldingPost_BattingPost FOREIGN KEY (playerID,yearID) REFERENCES  BattingPost(playerID,yearID);
 
-- FOREIGN KEY `fk_CollegePlaying_Master`; -- FOREIGN KEY `fk_CollegePlaying_Schools`;
ALTER TABLE CollegePlaying
 ADD CONSTRAINT fk_CollegePlaying_Master
 FOREIGN KEY (playerID) REFERENCES Master(playerID);
 
ALTER TABLE CollegePlaying
 ADD CONSTRAINT fk_CollegePlaying_Schools
 FOREIGN KEY (schoolID) REFERENCES Schools(schoolID);
 
-- Appearances.sql (-- FOREIGN KEY `fk_Appearances_Teams`; -- FOREIGN KEY `fk_Appearances_Master`;)
ALTER TABLE Appearances
 ADD CONSTRAINT fk_Appearances_Teams
 FOREIGN KEY (yearID, teamID) REFERENCES Teams(yearID, teamID);
 
 
ALTER TABLE Appearances
 ADD CONSTRAINT fk_Appearances_Master
 FOREIGN KEY (playerID) REFERENCES Master(playerID);
 
-- AwardsSharePlayers.sql (-- FOREIGN KEY `fk_AwardsSharePlayers_Master`;)
ALTER TABLE AwardsSharePlayers
 ADD CONSTRAINT fk_AwardsSharePlayers_Master
 FOREIGN KEY (playerID) REFERENCES Master(playerID);
 
-- AwardsShareManagers.sql (-- FOREIGN KEY `fk_AwardsShareManagers_Master`;)
ALTER TABLE AwardsShareManagers
 ADD CONSTRAINT fk_AwardsShareManagers_Master
 FOREIGN KEY (playerID) REFERENCES Master(playerID);
 
-- AwardsPlayers.sql (-- FOREIGN KEY `fk_AwardsPlayers_Master`;)
ALTER TABLE AwardsPlayers
 ADD CONSTRAINT fk_AwardsPlayers_Master
 FOREIGN KEY (playerID) REFERENCES Master(playerID);
 
-- AwardsManagers.sql (-- FOREIGN KEY `fk_AwardsManagers_Master`;)
ALTER TABLE AwardsManagers
 ADD CONSTRAINT fk_AwardsManagers_Master
 FOREIGN KEY (playerID) REFERENCES Master(playerID);
 
-- SeriesPost.sql (-- FOREIGN KEY `fk_SeriesPost_Teams`;)
ALTER TABLE SeriesPost
 ADD CONSTRAINT fk_SeriesPost_WTeams
 FOREIGN KEY (yearID, teamIDwinner) REFERENCES Teams(yearID, teamID);
 ALTER TABLE SeriesPost
 ADD CONSTRAINT fk_SeriesPost_LTeams
 FOREIGN KEY (yearID, teamIDloser) REFERENCES Teams(yearID, teamID);
 
-- Salaries.sql (-- FOREIGN KEY `fk_Salaries_Teams`;FOREIGN KEY `fk_Salaries_Master`;)
ALTER TABLE Salaries
 ADD CONSTRAINT fk_Salaries_Teams
 FOREIGN KEY (yearID, teamID) REFERENCES Teams(yearID, teamID);
 
ALTER TABLE Salaries
 ADD CONSTRAINT fk_Salaries_Master
 FOREIGN KEY (playerID) REFERENCES Master(playerID);
 
-- TeamsHalf.sql (-- FOREIGN KEY `fk_TeamsHalf_Teams`;)
ALTER TABLE TeamsHalf
 ADD CONSTRAINT fk_TeamsHalf_Teams
 FOREIGN KEY (yearID, teamID) REFERENCES Teams(yearID, teamID);
 
-- ManagersHalf.sql (-- FOREIGN KEY `fk_ManagersHalf_Teams`; -- FOREIGN KEY `fk_ManagersHalf_Master`;)
ALTER TABLE ManagersHalf
 ADD CONSTRAINT fk_ManagersHalf_Teams
 FOREIGN KEY (yearID, teamID) REFERENCES Teams(yearID, teamID);
 
ALTER TABLE ManagersHalf
 ADD CONSTRAINT fk_ManagersHalf_Master
 FOREIGN KEY (playerID) REFERENCES Master(playerID);
 
-- FieldingOFsplit.sql (batting, pitching, fieldingOF, )
ALTER TABLE FieldingOFsplit
 ADD CONSTRAINT fk_FieldingOFsplit_Batting
 FOREIGN KEY (playerID, yearID, stint) REFERENCES Batting(playerID, yearID, stint);
 
ALTER TABLE FieldingOFsplit
 ADD CONSTRAINT fk_FieldingOFsplit_Pitching
 FOREIGN KEY (playerID, yearID, stint) REFERENCES Pitching(playerID, yearID, stint);
 
ALTER TABLE FieldingOFsplit
 ADD CONSTRAINT fk_FieldingOFsplit_FieldingOF
 FOREIGN KEY (playerID, yearID, stint) REFERENCES FieldingOF(playerID, yearID, stint);

ALTER TABLE FieldingOFsplit
 ADD CONSTRAINT fk_FieldingOFsplit_Teams
 FOREIGN KEY (yearID, teamID) REFERENCES Teams(yearID, teamID);
 
ALTER TABLE FieldingOFsplit
 ADD CONSTRAINT fk_FieldingOFsplit_Master
 FOREIGN KEY (playerID) REFERENCES Master(playerID);
 
-- set the foreign_key_checks back
SET foreign_key_checks = 1;