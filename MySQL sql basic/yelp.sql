-- yelp.sql
-- Part 2
-- a.
SELECT user_id,
       name
FROM user
ORDER BY review_count DESC
LIMIT 1;

-- MySql Output
-- +------------------------+--------+
-- | user_id                | name   |
-- +------------------------+--------+
-- | 8k3aO-mPeyhbR5HUucA5aA | Victor |
-- +------------------------+--------+
-- 1 row in set (0.70 sec)

-- b.
SELECT business_id,
       name
FROM business
ORDER BY review_count DESC
LIMIT 1;

-- MySql Output
-- +------------------------+--------------+
-- | business_id            | name         |
-- +------------------------+--------------+
-- | 4JNXUYY8wbaaDmk3BPzlWw | Mon Ami Gabi |
-- +------------------------+--------------+
-- 1 row in set (0.12 sec)


-- c. 
SELECT AVG(individual_review_sum) AS users_average_review_count
FROM
  (SELECT Sum(review_count) AS individual_review_sum
   FROM user
   GROUP BY user_id) AS sum_list;

-- MySql Output
-- +----------------------------+
-- | users_average_review_count |
-- +----------------------------+
-- |                    24.3193 |
-- +----------------------------+
-- 1 row in set (1.00 sec)



-- d.
SELECT count(*) AS users_count_difference_larger_than_point_five
FROM
  (SELECT user_id,
          avg(average_stars) AS average_star_user
   FROM user
   GROUP BY user_id) AS a_method
INNER JOIN
  (SELECT user_id,
          avg(stars) AS average_star_review
   FROM review
   GROUP BY user_id) AS b_method ON a_method.user_id = b_method.user_id
WHERE ABS(average_star_user - average_star_review) > 0.5;

-- MySql Output
-- +-----------------------------------------------+
-- | users_count_difference_larger_than_point_five |
-- +-----------------------------------------------+
-- |                                            66 |
-- +-----------------------------------------------+
-- 1 row in set (13.52 sec)


-- e.
SELECT
  (SELECT count(*)
   FROM
     (SELECT user_id,
             sum(review_count) AS user_review_sum_more_than_ten
      FROM user
      GROUP BY user_id
      HAVING user_review_sum_more_than_ten > 10) AS user_review_sum_more_than_ten_table) /
  (SELECT count(*)
   FROM
     (SELECT user_id,
             sum(review_count) AS user_review_sum
      FROM user
      GROUP BY user_id) AS user_review_sum_table) AS fraction_of_user;

-- MySql Output
-- +------------------+
-- | fraction_of_user |
-- +------------------+
-- |           0.3311 |
-- +------------------+
-- 1 row in set (1.41 sec)

-- f.
SELECT avg(LENGTH) AS review_avg_length
FROM
  (SELECT char_length(text) AS LENGTH
   FROM
     (SELECT text
      FROM
        (SELECT user_id,
                sum(review_count) AS user_review_sum_more_than_ten
         FROM user
         GROUP BY user_id
         HAVING user_review_sum_more_than_ten > 10) AS user_review_sum_more_than_ten_table
      INNER JOIN review ON review.user_id = user_review_sum_more_than_ten_table.user_id) AS text_table) AS length_table;

-- MySql Output
-- +-------------------+
-- | review_avg_length |
-- +-------------------+
-- |          698.7808 |
-- +-------------------+
-- 1 row in set (11.26 sec)