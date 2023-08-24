/* A-- PIZZA METRICS
[Q1] How many pizzas were ordered? */
SELECT
	COUNT(order_id) AS Pizzas_Ordered
FROM customer_orders;

SELECT * FROM customer_orders;
/* [Q2] How many unique customer orders were made? */
SELECT
	COUNT(DISTINCT order_id) AS Unique_Orders
FROM customer_orders;

/* [Q3] How many successful orders were delivered by each runner? */
SELECT 
	runner_id,
    COUNT(order_id) AS orders_delivered
FROM runner_orders
WHERE pickup_time IS NOT NULL
GROUP BY runner_id;

/* [Q4] How many of each type of pizza was delivered? */
SELECT
    p.pizza_name,
    COUNT(c.pizza_id)
FROM customer_orders c
JOIN pizza_names p ON c.pizza_id = p.pizza_id
JOIN runner_orders ro ON c.order_id = ro.order_id
WHERE ro.pickup_time IS NOT NULL
GROUP BY p.pizza_name;

/* [Q5] How many Vegetarian and Meatlovers were ordered by each customer? */
SELECT
	c.customer_id,
    p.pizza_name,
    COUNT(c.pizza_id) AS Pizza_orders
FROM customer_orders c
JOIN pizza_names p ON c.pizza_id = p.pizza_id
GROUP BY c.customer_id, p.pizza_name
ORDER BY c.customer_id;

/* [Q6] What was the maximum number of pizzas delivered in a single order? */
SELECT 
	COUNT(c.pizza_id) AS Max_Pizza_Deilvered
FROM customer_orders c
JOIN runner_orders ro ON c.order_id = ro.order_id
WHERE ro.pickup_time IS NOT NULL
GROUP BY c.order_id
ORDER BY COUNT(c.pizza_id)  DESC
LIMIT 1;

/* [Q7] For each customer, how many delivered pizzas had at least 1 change and how many had no changes? */
WITH Pizza_delivered AS (
SELECT 
	c.customer_id,
    ro.order_id,
    ro.cancellation,
    COUNT(*) AS num_changes
FROM customer_orders c
JOIN runner_orders ro ON c.order_id = ro.order_id
WHERE ro.pickup_time IS NOT NULL
	AND (c.exclusions IS NOT NULL OR c.extras IS NOT NULL)
GROUP BY c.customer_id, ro.order_id, ro.cancellation
)
SELECT 
	pd.customer_id,
    COUNT(CASE WHEN pd.num_changes > 0 THEN 1 END) AS pizzas_with_changes,
    COUNT(CASE WHEN pd.num_changes = 1 THEN 1 END) AS pizzas_with_no_changes
    FROM Pizza_delivered pd
    GROUP BY pd.customer_id;

/* [Q8] How many pizzas were delivered that had both exclusions and extras? */
SELECT 
	c.customer_id,
    ro.order_id,
    COUNT(pizza_id) AS num_of_pizzas
FROM customer_orders c
JOIN runner_orders ro ON c.order_id = ro.order_id
WHERE ro.pickup_time IS NOT NULL
	AND (c.exclusions IS NOT NULL AND c.extras IS NOT NULL)
GROUP BY c.customer_id, ro.order_id;


/* [Q9] What was the total volume of pizzas ordered for each hour of the day? */

SELECT
	EXTRACT(HOUR FROM order_time) AS hour_of_day,
    COUNT(pizza_id) AS total_pizzas_ordered
FROM customer_orders
GROUP BY hour_of_day
ORDER BY hour_of_day;

/* [Q10] What was the volume of orders for each day of the week?  */
SELECT
	DAYOFWEEK(order_time) AS day_of_week,
    COUNT(pizza_id) AS total_pizzas_ordered
FROM customer_orders
GROUP BY day_of_week
ORDER BY day_of_week;


/* -- B Runner and Customer Experience
[Q1] How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01) */
SELECT 
	DATE_FORMAT(registration_date, '%Y-%m-%d') AS start_of_week,
	COUNT(runner_id) AS no_of_runners
FROM runners
GROUP BY YEARWEEK(registration_date, 1)
ORDER BY start_of_week;
    
/* [Q2] What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order? */
SELECT 
	runner_id,
    AVG(TIME_TO_SEC(TIMEDIFF(pickup_time, CAST(pickup_time AS DATE))) / 60) AS avg_time_taken_minutes
FROM runner_orders
WHERE pickup_time IS NOT NULL
GROUP BY runner_id;

/* [Q3] Is there any relationship between the number of pizzas and how long the order takes to prepare? */
SELECT
	c.customer_id,
    COUNT(c.pizza_id),
    SUM(TIME_TO_SEC(TIMEDIFF(ro.pickup_time, CAST(ro.pickup_time AS DATE))) / 60) AS time_taken_to_prepare_minutes
FROM customer_orders c
JOIN runner_orders ro ON c.order_id = ro.order_id
GROUP BY c.customer_id
ORDER BY time_taken_to_prepare_minutes;
    
/* [Q4] What was the average distance travelled for each customer? */
SELECT
	c.customer_id,
	AVG(CAST(SUBSTRING_INDEX(ro.distance, 'km', 1) AS DECIMAL)) AS avg_distance
FROM customer_orders c
JOIN runner_orders ro ON c.order_id = ro.order_id
GROUP BY c.customer_id;

/* [Q5] What was the difference between the longest and shortest delivery times for all orders? */
WITH time AS(
SELECT
	ro.order_id,
	MAX(TIME_TO_SEC(TIMEDIFF(ro.pickup_time, CAST(ro.pickup_time AS DATE))) / 60) AS max_time_taken,
    MIN(TIME_TO_SEC(TIMEDIFF(ro.pickup_time, CAST(ro.pickup_time AS DATE))) / 60) AS min_time_taken
FROM runner_orders ro
WHERE ro.pickup_time IS NOT NULL
GROUP BY ro.order_id)
SELECT 
	MAX(max_time_taken) - MIN(min_time_taken) AS time_difference
FROM time;

/* [Q6] What was the average speed for each runner for each delivery and do you notice any trend for these values? */
WITH dis_time AS(
SELECT 
	c.customer_id,
	CAST(SUBSTRING_INDEX(ro.distance, 'km', 1) AS DECIMAL) AS distance_km,
    TIME_TO_SEC(TIMEDIFF(ro.pickup_time, CAST(ro.pickup_time AS DATE)) / 60) AS time_taken
FROM customer_orders c
JOIN runner_orders ro ON c.order_id = ro.order_id
)
SELECT
	customer_id,
    distance_km,
    time_taken,
	(distance_km / time_taken) AS avg_speed
FROM dis_time
GROUP BY customer_id;

/* [Q7] What is the successful delivery percentage for each runner? */
WITH total_deliveries AS (
    SELECT
        runner_id,
        COUNT(order_id) AS total_orders
    FROM runner_orders
    WHERE pickup_time IS NOT NULL
    GROUP BY runner_id
),
successful_deliveries AS (
    SELECT
        runner_id,
        COUNT(order_id) AS successful_orders
    FROM runner_orders
    WHERE pickup_time IS NOT NULL AND cancellation IS NULL
    GROUP BY runner_id
)
SELECT
    td.runner_id,
    COALESCE((sd.successful_orders * 100.0) / td.total_orders, 0) AS success_percentage
FROM total_deliveries td
LEFT JOIN successful_deliveries sd ON td.runner_id = sd.runner_id;
