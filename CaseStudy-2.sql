/*-- PIZZA METRICS
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
