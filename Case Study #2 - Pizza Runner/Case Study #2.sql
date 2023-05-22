CREATE DATABASE pizza_runner;

USE pizza_runner;

-- ------------ CREATING DATA SET ------------ --
CREATE TABLE runners (
  runner_id INTEGER,
  registration_date DATE
)
;

INSERT INTO runners
  (runner_id, registration_date)
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15')
  ;

CREATE TABLE customer_orders (
  order_id INTEGER,
  customer_id INTEGER,
  pizza_id INTEGER,
  exclusions VARCHAR(4),
  extras VARCHAR(4),
  order_time TIMESTAMP
)
;

INSERT INTO customer_orders
  (order_id, customer_id, pizza_id, exclusions, extras, order_time)
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49')
  ;

CREATE TABLE runner_orders (
  order_id INTEGER,
  runner_id INTEGER,
  pickup_time VARCHAR(19),
  distance VARCHAR(7),
  duration VARCHAR(10),
  cancellation VARCHAR(23)
)
;

INSERT INTO runner_orders
  (order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null')
  ;


CREATE TABLE pizza_names (
  pizza_id INTEGER,
  pizza_name TEXT
)
;

INSERT INTO pizza_names
  (pizza_id, pizza_name)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian')
  ;

DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  pizza_id INTEGER,
  toppings TEXT
)
;

INSERT INTO pizza_recipes
  (pizza_id, toppings)
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12')
  ;

CREATE TABLE pizza_toppings (
  topping_id INTEGER,
  topping_name TEXT
)
;

INSERT INTO pizza_toppings
  (topping_id, topping_name)
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce')
  ;
  
-- ------------ DATA CLEANING ------------ --
-- Table : customer_order
-- we remove all the blank spaces and replace all stringed (null/NaN) values as a NULL value for constistency.
UPDATE customer_orders
SET
  exclusions = CASE
    WHEN TRIM(exclusions) = '' THEN NULL
    WHEN exclusions = 'null' THEN NULL
    WHEN exclusions = 'NaN' THEN NULL
    ELSE exclusions
  END,
  extras = CASE 
	WHEN extras = '' THEN NULL 
	WHEN extras = 'null' THEN NULL
	WHEN extras = 'NaN' THEN NULL
  ELSE extras 
  END
  ;

-- Table : runner_order
-- We used to prime the existing data and remove the text from the stringed numerical values.
UPDATE runner_orders
SET
  pickup_time = CASE
		WHEN pickup_time = 'null' THEN NULL
		ELSE pickup_time
	END,
  distance = CASE
		WHEN distance = 'null' THEN NULL
		WHEN distance LIKE '%km' THEN TRIM(TRAILING 'km' FROM distance)
        ELSE distance
	END, 
  duration =CASE
		WHEN duration = 'null' THEN NULL
		WHEN TRIM(duration) LIKE '%min' THEN TRIM(TRAILING 'min' FROM duration)
        WHEN TRIM(duration) LIKE '%mins' THEN TRIM(TRAILING 'mins' FROM duration)
		WHEN TRIM(duration) LIKE '%minutes' THEN TRIM(TRAILING 'minutes' FROM duration)
		WHEN TRIM(duration) LIKE '%minute' THEN TRIM(TRAILING 'minute' FROM duration)
		ELSE duration
	END,
  cancellation = CASE
		WHEN cancellation = '' THEN NULL
		WHEN cancellation = 'null' THEN NULL
		ELSE cancellation
		END
        ;   

--  we change the data type of the stringed numbers to decimals or integers to enable numerical functions and aggregation capabilities.
ALTER TABLE runner_orders
CHANGE COLUMN distance distance_km DECIMAL(10, 2),
CHANGE COLUMN duration duration_min DECIMAL(10, 2),
MODIFY COLUMN pickup_time DATETIME
;

-- ------------ A. Pizza Metrics QUESTIONS ------------ --

-- ------------ 1. How many pizzas were ordered? ------------ --
SELECT 
	COUNT(*) AS total_pizza_ordered
FROM customer_orders
;

-- ------------ 2. How many unique customer orders were made? ------------ --
SELECT COUNT(DISTINCT order_id) AS unique_pizza_count
FROM customer_orders
;

-- ------------ 3. How many successful orders were delivered by each runner? ------------ --
SELECT 
	runner_id, 
	COUNT(order_id) AS total_pizza_delivered
FROM runner_orders
WHERE duration_min IS NOT NULL
GROUP BY 1
;

-- ------------ 4. How many of each type of pizza was delivered? ------------ --
SELECT 
	p.pizza_name, 
	COUNT(c.order_id) AS total_pizza_delivered
FROM pizza_names p
JOIN customer_orders c 
	ON p.pizza_id = c.pizza_id 
JOIN runner_orders r 
	ON c.order_id = r.order_id
WHERE duration_min IS NOT NULL
GROUP BY 1
;

-- ------------ 5. How many Vegetarian and Meatlovers were ordered by each customer? ------------ --
SELECT 
	c.customer_id,
	SUM(CASE WHEN p.pizza_name = 'Vegetarian' THEN 1 ELSE 0 END) AS total_Vegetarian,
    SUM(CASE WHEN p.pizza_name = 'Meatlovers' THEN 1 ELSE 0 END) AS total_Meatlovers
FROM pizza_names p
JOIN customer_orders c 
	ON p.pizza_id = c.pizza_id 
GROUP BY 1
;

-- ------------ 6. What was the maximum number of pizzas delivered in a single order? ------------ --
SELECT 
	r.order_id, 
	COUNT(c.pizza_id) AS total_pizza_delivered
FROM runner_orders r
JOIN customer_orders c 
	ON r.order_id = c.order_id
WHERE r.duration_min IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1
;

-- ------------ 7.For each customer, how many delivered pizzas had at least 1 change and how many had no changes? ------------ --
SELECT 
	c.customer_id, 
	SUM(CASE WHEN c.exclusions IS NOT NULL OR c.extras IS NOT NULL THEN 1 ELSE 0 END) AS  pizza_with_changes,
    SUM(CASE WHEN c.exclusions IS NULL AND c.extras IS NULL THEN 1 ELSE 0 END) AS  pizza_with_on_changes
FROM customer_orders c 
JOIN runner_orders r
	ON c.order_id = r.order_id 
GROUP BY 1
;

-- ------------ 8. How many pizzas were delivered that had both exclusions and extras? ------------ --
SELECT  
	SUM(CASE WHEN c.exclusions IS NOT NULL AND c.extras IS NOT NULL THEN 1 ELSE 0 END) AS  total_pizza
FROM customer_orders c 
JOIN runner_orders r
	ON c.order_id = r.order_id
;

-- ------------ 9. What was the total volume of pizzas ordered for each hour of the day? ------------ --
SELECT 
	HOUR(order_time) AS hour_of_day,
    COUNT(order_id) AS order_count
FROM customer_orders
GROUP BY 1
;

-- ------------ 10. What was the volume of orders for each day of the week? ------------ --
SELECT 
	DAYNAME(order_time) AS day_of_week,
    COUNT(order_id) AS order_count
FROM customer_orders
GROUP BY 1
;

-- ------------ B. Runner and Customer Experience QUESTIONS ------------ --

-- ------------ 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01) ------------ --
SELECT 
	DATEPART(WEEK, registration_date) AS registration_week,
    COUNT(runner_id) AS no_of_runners
FROM runners
GROUP BY 1
;

-- ------------ 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order? ------------ --
SELECT 
	r.runner_id,
    AVG(TIMESTAMPDIFF(MINUTE, c.order_time, r.pickup_time)) AS avg_time
FROM runner_orders r 
JOIN customer_orders c 
	ON r.order_id = c.order_id
GROUP BY 1;
    
-- ------------ 3. Is there any relationship between the number of pizzas and how long the order takes to prepare? ------------ --
WITH prep_time AS
	(
    SELECT 
		r.runner_id,
         c.order_time, 
		r.pickup_time,
        COUNT(r.order_id) AS pizza_order,
		AVG(TIMESTAMPDIFF(MINUTE, c.order_time, r.pickup_time)) AS avg_prep_time
	FROM runner_orders r 
	JOIN customer_orders c 
		ON r.order_id = c.order_id
	GROUP BY 1,2,3
    )
SELECT 
	pizza_order,
    avg_prep_time
FROM prep_time
GROUP BY 1
;
    
-- ------------ 4. What was the average distance travelled for each customer? ------------ --
SELECT 
	c.customer_id,
    AVG(distance_km) AS avg_distance_travelled
FROM customer_orders c 
JOIN runner_orders r 
	USING(order_id)
WHERE distance_km != 0
GROUP BY 1
;

-- ------------ 5. What was the difference between the longest and shortest delivery times for all orders? ------------ --
SELECT 
	(MAX(duration_min) - MIN(duration_min)) AS difference
FROM runner_orders
;

-- ------------ 6. What was the average speed for each runner for each delivery and do you notice any trend for these values? ------------ --
SELECT 
	runner_id,
    order_id,
    ROUND(AVG(distance_km / (duration_min / 60)), 2) AS avg_speed_km_hr
FROM runner_orders
WHERE distance_km != 0
GROUP BY 1,2
;

-- ------------ 7.What is the successful delivery percentage for each runner? ------------ --
SELECT 
	runner_id,
    ROUND(100 * SUM(
				CASE WHEN cancellation IS NOT NULL THEN 0
                ELSE 1 END) / COUNT(*), 2) AS seccessful_delivery_perc
FROM runner_orders
GROUP BY 1
;

