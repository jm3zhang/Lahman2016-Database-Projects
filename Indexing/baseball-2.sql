-- baseball.sql

-- IMPORTANT NOTE: As discussed in lab, the primary keys and foreign keys are not indexed in this database (and they are in yelp database), therefore we'll include some of these keys as indexes to make covered indexes.
-- We've tested that removing the primary key indexes will not result in a reduced "rows" output, although we are expecting the number of rows to be reduced regardless if we add the primary/foreign keys as indexes.
-- For example, for the first question, regardless if the index is created on Master(playerID,birthMonth,birthDay,birthYear) or Master(birthMonth,birthDay,birthYear), the number of rows is not reduced. and we are expecting it to reduce in the following "explain", however cannot reach the cause of this issue.

-- 1.
-- a.

EXPLAIN SELECT count(DISTINCT playerID) AS player_missing_birthday
FROM Master
WHERE birthMonth='0'
  	OR birthDay='0'
  	OR birthYear='0';
-- +----+-------------+--------+------------+------+---------------+------+---------+------+-------+----------+-------------+
-- | id | select_type | table  | partitions | type | possible_keys | key  | key_len | ref  | rows  | filtered | Extra       |
-- +----+-------------+--------+------------+------+---------------+------+---------+------+-------+----------+-------------+
-- |  1 | SIMPLE      | Master | NULL       | ALL  | NULL          | NULL | NULL    | NULL | 19057 |    27.10 | Using where |
-- +----+-------------+--------+------------+------+---------------+------+---------+------+-------+----------+-------------+
-- 1 row in set, 1 warning (0.00 sec)

-- CREATE INDEX index_Master_playerBirthDate ON Master(playerID,birthMonth,birthDay,birthYear);
-- Query OK, 0 rows affected (0.22 sec)
-- Records: 0  Duplicates: 0  Warnings: 0

CREATE INDEX INDEX_birthMonth ON Master(birthMonth) USING BTREE;
CREATE INDEX INDEX_birthDay ON Master(birthDay) USING BTREE;
CREATE INDEX INDEX_birthYear ON Master(birthYear) USING BTREE;

EXPLAIN SELECT count(DISTINCT playerID) AS player_missing_birthday
FROM Master
WHERE birthMonth='0'
  	OR birthDay='0'
  	OR birthYear='0';
-- +----+-------------+--------+------------+-------+------------------------------+------------------------------+---------+------+-------+----------+--------------------------+
-- | id | select_type | table  | partitions | type  | possible_keys                | key                          | key_len | ref  | rows  | filtered | Extra                    |
-- +----+-------------+--------+------------+-------+------------------------------+------------------------------+---------+------+-------+----------+--------------------------+
-- |  1 | SIMPLE      | Master | NULL       | index | index_Master_playerBirthDate | index_Master_playerBirthDate | 882     | NULL | 88 |    27.10 | Using where; Using index |
-- +----+-------------+--------+------------+-------+------------------------------+------------------------------+---------+------+-------+----------+--------------------------+
-- 1 row in set, 1 warning (0.00 sec)



-- b.
EXPLAIN SELECT
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
-- +----+-------------+------------+------------+------+------------------------------+------------------------------+---------+--------------------------------+------+----------+------------------------------+
-- | id | select_type | table      | partitions | type | possible_keys                | key                          | key_len | ref                            | rows | filtered | Extra                        |
-- +----+-------------+------------+------------+------+------------------------------+------------------------------+---------+--------------------------------+------+----------+------------------------------+
-- |  1 | PRIMARY     | NULL       | NULL       | NULL | NULL                         | NULL                         | NULL    | NULL                           | NULL |     NULL | No tables used               |
-- |  4 | SUBQUERY    | <derived5> | NULL       | ALL  | NULL                         | NULL                         | NULL    | NULL                           | 4136 |    90.00 | Using where                  |
-- |  5 | DERIVED     | HallOfFame | NULL       | ALL  | NULL                         | NULL                         | 1538    | NULL                           | 4136 |   100.00 | Using where; Using temporary |
-- |  5 | DERIVED     | Master     | NULL       | ref  | index_Master_playerBirthDate | index_Master_playerBirthDate | 768     | lahman2016.HallOfFame.playerID |    1 |   100.00 | NULL                         |
-- |  2 | SUBQUERY    | <derived3> | NULL       | ref  | <auto_key0>                  | <auto_key0>                  | 768     | const                          |   10 |   100.00 | NULL                         |
-- |  3 | DERIVED     | HallOfFame | NULL       | ALL  | NULL                         | NULL                         | 1538    | NULL                           | 4136 |   100.00 | Using where; Using temporary |
-- |  3 | DERIVED     | Master     | NULL       | ref  | index_Master_playerBirthDate | index_Master_playerBirthDate | 768     | lahman2016.HallOfFame.playerID |    1 |   100.00 | NULL                         |
-- +----+-------------+------------+------------+------+------------------------------+------------------------------+---------+--------------------------------+------+----------+------------------------------+
-- 7 rows in set, 1 warning (0.01 sec)

-- CREATE INDEX index_HallOfFame_player ON HallOfFame(playerID);
-- Query OK, 0 rows affected (0.18 sec)
-- Records: 0  Duplicates: 0  Warnings: 0
CREATE INDEX INDEX_deathCountry ON HallOfFame(deathCountry) USING BTREE;
CREATE INDEX INDEX_HOFplayerID ON HallOfFame(playerID) USING BTREE;

EXPLAIN SELECT
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
-- +----+-------------+------------+------------+-------+------------------------------+------------------------------+---------+--------------------------------+------+----------+-------------------------------------------+
-- | id | select_type | table      | partitions | type  | possible_keys                | key                          | key_len | ref                            | rows | filtered | Extra                                     |
-- +----+-------------+------------+------------+-------+------------------------------+------------------------------+---------+--------------------------------+------+----------+-------------------------------------------+
-- |  1 | PRIMARY     | NULL       | NULL       | NULL  | NULL                         | NULL                         | NULL    | NULL                           | NULL |     NULL | No tables used                            |
-- |  4 | SUBQUERY    | <derived5> | NULL       | ALL   | NULL                         | NULL                         | NULL    | NULL                           | 4136 |    90.00 | Using where                               |
-- |  5 | DERIVED     | HallOfFame | NULL       | index | index_HallOfFame_player      | index_HallOfFame_player      | 767     | NULL                           | 4136 |   100.00 | Using where; Using index; Using temporary |
-- |  5 | DERIVED     | Master     | NULL       | ref   | index_Master_playerBirthDate | index_Master_playerBirthDate | 767     | lahman2016.HallOfFame.playerID |    1 |   100.00 | NULL                                      |
-- |  2 | SUBQUERY    | <derived3> | NULL       | ref   | <auto_key0>                  | <auto_key0>                  | 768     | const                          |   10 |   100.00 | NULL                                      |
-- |  3 | DERIVED     | HallOfFame | NULL       | index | index_HallOfFame_player      | index_HallOfFame_player      | 767     | NULL                           | 4136 |   100.00 | Using where; Using index; Using temporary |
-- |  3 | DERIVED     | Master     | NULL       | ref   | index_Master_playerBirthDate | index_Master_playerBirthDate | 767     | lahman2016.HallOfFame.playerID |    1 |   100.00 | NULL                                      |
-- +----+-------------+------------+------------+-------+------------------------------+------------------------------+---------+--------------------------------+------+----------+-------------------------------------------+
-- 7 rows in set, 1 warning (0.00 sec)



-- c.
EXPLAIN SELECT nameFirst,
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
-- +----+-------------+------------+------------+------+------------------------------+------------------------------+---------+--------------------------+-------+----------+-----------------------------+
-- | id | select_type | table      | partitions | type | possible_keys                | key                          | key_len | ref                      | rows  | filtered | Extra                       |
-- +----+-------------+------------+------------+------+------------------------------+------------------------------+---------+--------------------------+-------+----------+-----------------------------+
-- |  1 | PRIMARY     | <derived2> | NULL       | ALL  | NULL                         | NULL                         | NULL    | NULL                     | 26112 |   100.00 | Using where; Using filesort |
-- |  1 | PRIMARY     | Master     | NULL       | ref  | index_Master_playerBirthDate | index_Master_playerBirthDate | 768     | max_salary_list.playerID |     1 |   100.00 | NULL                        |
-- |  2 | DERIVED     | Salaries   | NULL       | ALL  | NULL                         | NULL                         | NULL    | NULL                     | 26112 |   100.00 | Using temporary             |
-- +----+-------------+------------+------------+------+------------------------------+------------------------------+---------+--------------------------+-------+----------+-----------------------------+
-- 3 rows in set, 1 warning (0.00 sec)

-- CREATE INDEX index_Salaries_playerSalary ON Salaries(playerID,salary);
-- Query OK, 0 rows affected (0.13 sec)
-- Records: 0  Duplicates: 0  Warnings: 0
CREATE INDEX INDEX_salary ON Salaries(salary) USING BTREE;
CREATE INDEX INDEX_Salariespid ON Salaries(playerID) USING BTREE;

-- Since there is a “SUM(salary)” (Aggregation), the whole table will be scanned no matter what, so index will NOT help in this case.


EXPLAIN SELECT nameFirst,
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
-- +----+-------------+------------+------------+-------+------------------------------+------------------------------+---------+--------------------------+-------+----------+-----------------------------+
-- | id | select_type | table      | partitions | type  | possible_keys                | key                          | key_len | ref                      | rows  | filtered | Extra                       |
-- +----+-------------+------------+------------+-------+------------------------------+------------------------------+---------+--------------------------+-------+----------+-----------------------------+
-- |  1 | PRIMARY     | <derived2> | NULL       | ALL   | NULL                         | NULL                         | NULL    | NULL                     | 26112 |   100.00 | Using where; Using filesort |
-- |  1 | PRIMARY     | Master     | NULL       | ref   | index_Master_playerBirthDate | index_Master_playerBirthDate | 768     | max_salary_list.playerID |     1 |   100.00 | NULL                        |
-- |  2 | DERIVED     | Salaries   | NULL       | index | index_Salaries_playerSalary  | index_Salaries_playerSalary  | 773     | NULL                     | 26112 |   100.00 | Using index                 |
-- +----+-------------+------------+------------+-------+------------------------------+------------------------------+---------+--------------------------+-------+----------+-----------------------------+
-- 3 rows in set, 1 warning (0.00 sec)



-- d.
EXPLAIN SELECT AVG(individual_hr_sum) AS average_hr
FROM
  (SELECT playerID,
          Sum(HR) AS individual_hr_sum
   FROM Batting
   GROUP BY playerID) AS sum_list;
-- +----+-------------+------------+-------+---------------+---------+---------+------+--------+-------+
-- | id | select_type | table      | type  | possible_keys | key     | key_len | ref  | rows   | Extra |
-- +----+-------------+------------+-------+---------------+---------+---------+------+--------+-------+
-- |  1 | PRIMARY     | <derived2> | ALL   | NULL          | NULL    | NULL    | NULL | 102527 | NULL  |
-- |  2 | DERIVED     | Batting    | index | PRIMARY       | PRIMARY | 775     | NULL | 102527 | NULL  |
-- +----+-------------+------------+-------+---------------+---------+---------+------+--------+-------+
-- 2 rows in set (0.01 sec)

-- CREATE INDEX index_Batting_playerHR ON Batting(playerID,HR);
-- Query OK, 0 rows affected (0.36 sec)
-- Records: 0  Duplicates: 0  Warnings: 0

-- Again, derived table cannot be indexed and the second one is already indexed, so no indexing is needed for them. Form the query, since there is a “Sum(HR)” (Aggregation), the whole table will be scanned no matter what, so index will NOT help in this case.


EXPLAIN SELECT AVG(individual_hr_sum) AS average_hr
FROM
  (SELECT playerID,
          Sum(HR) AS individual_hr_sum
   FROM Batting
   GROUP BY playerID) AS sum_list;
-- +----+-------------+------------+------------+-------+------------------------+------------------------+---------+------+--------+----------+-------------+
-- | id | select_type | table      | partitions | type  | possible_keys          | key                    | key_len | ref  | rows   | filtered | Extra       |
-- +----+-------------+------------+------------+-------+------------------------+------------------------+---------+------+--------+----------+-------------+
-- |  1 | PRIMARY     | <derived2> | NULL       | ALL   | NULL                   | NULL                   | NULL    | NULL | 102300 |   100.00 | NULL        |
-- |  2 | DERIVED     | Batting    | NULL       | index | index_Batting_playerHR | index_Batting_playerHR | 773     | NULL | 102300 |   100.00 | Using index |
-- +----+-------------+------------+------------+-------+------------------------+------------------------+---------+------+--------+----------+-------------+
-- 2 rows in set, 1 warning (0.00 sec)



-- e.
EXPLAIN SELECT AVG(individual_hr_sum_without_zero) AS average_hr_without_zero
FROM
  (SELECT playerID,
          Sum(HR) AS individual_hr_sum_without_zero
   FROM Batting
   GROUP BY playerID
   HAVING avg(HR) > 0) AS sum_list;
-- +----+-------------+------------+------------+-------+------------------------+------------------------+---------+------+--------+----------+-------------+
-- | id | select_type | table      | partitions | type  | possible_keys          | key                    | key_len | ref  | rows   | filtered | Extra       |
-- +----+-------------+------------+------------+-------+------------------------+------------------------+---------+------+--------+----------+-------------+
-- |  1 | PRIMARY     | <derived2> | NULL       | ALL   | NULL                   | NULL                   | NULL    | NULL | 102300 |   100.00 | NULL        |
-- |  2 | DERIVED     | Batting    | NULL       | index | index_Batting_playerHR | index_Batting_playerHR | 773     | NULL | 102300 |   100.00 | Using index |
-- +----+-------------+------------+------------+-------+------------------------+------------------------+---------+------+--------+----------+-------------+
-- 2 rows in set, 1 warning (0.00 sec)

-- derived table cannot be indexed and the second one is already indexed, so no indexing is needed for them. Form the query, since there is a “Sum(HR)” (Aggregation), the whole table will be scanned no matter what, so index will NOT help in this case.

EXPLAIN SELECT AVG(individual_hr_sum_without_zero) AS average_hr_without_zero
FROM
  (SELECT playerID,
          Sum(HR) AS individual_hr_sum_without_zero
   FROM Batting
   GROUP BY playerID
   HAVING avg(HR) > 0) AS sum_list;
-- +----+-------------+------------+------------+-------+------------------------+------------------------+---------+------+--------+----------+-------------+
-- | id | select_type | table      | partitions | type  | possible_keys          | key                    | key_len | ref  | rows   | filtered | Extra       |
-- +----+-------------+------------+------------+-------+------------------------+------------------------+---------+------+--------+----------+-------------+
-- |  1 | PRIMARY     | <derived2> | NULL       | ALL   | NULL                   | NULL                   | NULL    | NULL | 102300 |   100.00 | NULL        |
-- |  2 | DERIVED     | Batting    | NULL       | index | index_Batting_playerHR | index_Batting_playerHR | 773     | NULL | 102300 |   100.00 | Using index |
-- +----+-------------+------------+------------+-------+------------------------+------------------------+---------+------+--------+----------+-------------+
-- 2 rows in set, 1 warning (0.00 sec)


-- f. 
EXPLAIN SELECT count(*) AS good_player
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
-- +----+-------------+------------+------------+-------+------------------------+------------------------+---------+----------------------------+--------+----------+-----------------+
-- | id | select_type | table      | partitions | type  | possible_keys          | key                    | key_len | ref                        | rows   | filtered | Extra           |
-- +----+-------------+------------+------------+-------+------------------------+------------------------+---------+----------------------------+--------+----------+-----------------+
-- |  1 | PRIMARY     | <derived5> | NULL       | ALL   | NULL                   | NULL                   | NULL    | NULL                       |  44634 |   100.00 | Using where     |
-- |  1 | PRIMARY     | <derived2> | NULL       | ref   | <auto_key0>            | <auto_key0>            | 768     | good_pitcher_list.playerID |     10 |   100.00 | NULL            |
-- |  5 | DERIVED     | Pitching   | NULL       | ALL   | NULL                   | NULL                   | NULL    | NULL                       |  44634 |   100.00 | Using temporary |
-- |  6 | SUBQUERY    | <derived7> | NULL       | ALL   | NULL                   | NULL                   | NULL    | NULL                       |  44634 |   100.00 | NULL            |
-- |  7 | DERIVED     | Pitching   | NULL       | ALL   | NULL                   | NULL                   | NULL    | NULL                       |  44634 |   100.00 | Using temporary |
-- |  2 | DERIVED     | Batting    | NULL       | index | index_Batting_playerHR | index_Batting_playerHR | 773     | NULL                       | 102300 |   100.00 | Using index     |
-- |  3 | SUBQUERY    | <derived4> | NULL       | ALL   | NULL                   | NULL                   | NULL    | NULL                       | 102300 |   100.00 | NULL            |
-- |  4 | DERIVED     | Batting    | NULL       | index | index_Batting_playerHR | index_Batting_playerHR | 773     | NULL                       | 102300 |   100.00 | Using index     |
-- +----+-------------+------------+------------+-------+------------------------+------------------------+---------+----------------------------+--------+----------+-----------------+
-- 8 rows in set, 1 warning (0.00 sec)

--Again, derived table cannot be indexed and the third, fifth, sixth, eighth one is already indexed, so no indexing is needed for them. Form the query, since there is a “Sum(HR)”, “Sum(SO)”,  count(*), “AVG(individual_hr_sum)” and “AVG(individual_so_sum)” (Aggregation) the whole table will be scanned no matter what, so index will NOT help in this case.
-- CREATE INDEX index_Pitching_playerSO ON Pitching(playerID,SO);
-- Query OK, 0 rows affected (0.22 sec)
-- Records: 0  Duplicates: 0  Warnings: 0

EXPLAIN SELECT count(*) AS good_player
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
-- +----+-------------+------------+------------+-------+-------------------------+-------------------------+---------+----------------------------+--------+----------+-------------+
-- | id | select_type | table      | partitions | type  | possible_keys           | key                     | key_len | ref                        | rows   | filtered | Extra       |
-- +----+-------------+------------+------------+-------+-------------------------+-------------------------+---------+----------------------------+--------+----------+-------------+
-- |  1 | PRIMARY     | <derived5> | NULL       | ALL   | NULL                    | NULL                    | NULL    | NULL                       |  44634 |   100.00 | Using where |
-- |  1 | PRIMARY     | <derived2> | NULL       | ref   | <auto_key0>             | <auto_key0>             | 768     | good_pitcher_list.playerID |     10 |   100.00 | NULL        |
-- |  5 | DERIVED     | Pitching   | NULL       | index | index_Pitching_playerSO | index_Pitching_playerSO | 773     | NULL                       |  44634 |   100.00 | Using index |
-- |  6 | SUBQUERY    | <derived7> | NULL       | ALL   | NULL                    | NULL                    | NULL    | NULL                       |  44634 |   100.00 | NULL        |
-- |  7 | DERIVED     | Pitching   | NULL       | index | index_Pitching_playerSO | index_Pitching_playerSO | 773     | NULL                       |  44634 |   100.00 | Using index |
-- |  2 | DERIVED     | Batting    | NULL       | index | index_Batting_playerHR  | index_Batting_playerHR  | 773     | NULL                       | 102300 |   100.00 | Using index |
-- |  3 | SUBQUERY    | <derived4> | NULL       | ALL   | NULL                    | NULL                    | NULL    | NULL                       | 102300 |   100.00 | NULL        |
-- |  4 | DERIVED     | Batting    | NULL       | index | index_Batting_playerHR  | index_Batting_playerHR  | 773     | NULL                       | 102300 |   100.00 | Using index |
-- +----+-------------+------------+------------+-------+-------------------------+-------------------------+---------+----------------------------+--------+----------+-------------+
-- 8 rows in set, 1 warning (0.00 sec)