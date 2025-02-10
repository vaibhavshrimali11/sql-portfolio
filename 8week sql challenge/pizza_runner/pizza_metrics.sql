-- Total pizza ordered
SELECT COUNT(pizza_id) AS total_pizzas_ordered
FROM customer_orders;

--How many unique customer orders were made?
SELECT COUNT(DISTINCT order_id) AS total_unique_orders
FROM customer_orders;

--How many successful orders were delivered by each runner?
-- Recreate the temporary table
CREATE TEMP TABLE temp_runner_orders AS
SELECT 
    order_id,
    runner_id,
    NULLIF(pickup_time, 'null') AS pickup_time,
    -- Remove non-numeric characters and convert to FLOAT
    NULLIF(NULLIF(regexp_replace(distance, '[^0-9.]', '', 'g'), ''), 'null')::FLOAT AS distance,
    NULLIF(NULLIF(regexp_replace(duration, '[^0-9.]', '', 'g'), ''), 'null')::FLOAT AS duration,
    NULLIF(NULLIF(cancellation, ''), 'null') AS cancellation
FROM runner_orders;

-- Verify the data in temp table
SELECT runner_id, COUNT(order_id) AS successful_orders
FROM temp_runner_orders
WHERE cancellation IS NULL
GROUP BY runner_id;

-- How many of each type of pizza was delivered?

CREATE TEMP TABLE temp_customer_orders AS
SELECT
  order_id,
  customer_id,
  pizza_id,
  CASE
    WHEN exclusions = '' OR exclusions = 'null' THEN NULL
    ELSE exclusions
  END AS exclusions,
  CASE
    WHEN extras = '' OR extras = 'null' THEN NULL
    ELSE extras
  END AS extras,
  order_time
FROM
  customer_orders;

  
SELECT pn.pizza_name, COUNT(co.order_id) AS successful_orders
FROM temp_runner_orders ro
JOIN temp_customer_orders co USING(order_id)
JOIN pizza_names pn USING(pizza_id)
WHERE ro.cancellation IS NULL
GROUP BY pn.pizza_name;

-- How many Vegetarian and Meatlovers were ordered by each customer?
SELECT 
    co.customer_id, 
    pn.pizza_name, 
    COUNT(co.order_id) AS successful_orders
FROM temp_runner_orders ro 
JOIN temp_customer_orders co USING(order_id)
JOIN pizza_names pn USING(pizza_id)
WHERE ro.cancellation IS NULL  
GROUP BY co.customer_id, pn.pizza_name
ORDER BY co.customer_id;


-- What was the maximum number of pizzas delivered in a single order?
SELECT order_id, COUNT(pizza_id) AS pizza_count
FROM temp_customer_orders
GROUP BY order_id
ORDER BY pizza_count DESC
LIMIT 1;

--For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT customer_id,
       SUM(CASE WHEN exclusions IS NOT NULL OR extras IS NOT NULL THEN 1 ELSE 0 END) AS orders_with_changes,
       SUM(CASE WHEN exclusions IS NULL AND extras IS NULL THEN 1 ELSE 0 END) AS orders_without_changes
FROM temp_customer_orders co
JOIN temp_runner_orders ro USING (order_id)
WHERE ro.cancellation IS NULL
GROUP BY customer_id
ORDER BY customer_id;

-- How many pizzas were delivered that had both exclusions and extras?
SELECT customer_id,
       COUNT(*) AS changes_in_both
FROM temp_customer_orders co
JOIN temp_runner_orders ro USING (order_id)
WHERE ro.cancellation IS NULL
AND co.exclusions IS NOT NULL
AND co.extras IS NOT NULL
GROUP BY customer_id
ORDER BY customer_id;

--What was the total volume of pizzas ordered for each hour of the day?
SELECT EXTRACT(HOUR FROM order_time) AS hour_of_day,
       COUNT(pizza_id) AS total_pizzas_ordered
FROM temp_customer_orders
GROUP BY hour_of_day
ORDER BY hour_of_day;


