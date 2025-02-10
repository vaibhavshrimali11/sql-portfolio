-- How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

SELECT EXTRACT(WEEK FROM registration_date) AS week_number,
       COUNT(runner_id) AS runners_count
FROM runners
GROUP BY week_number
ORDER BY week_number;

--What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
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

SELECT   ro.runner_id,
         ROUND(AVG(EXTRACT(EPOCH FROM (ro.pickup_time::TIMESTAMP - co.order_time)) / 60), 2) AS avg_time_to_pickup
FROM     temp_runner_orders ro 
JOIN     temp_customer_orders co ON ro.order_id = co.order_id
WHERE    ro.pickup_time IS NOT NULL 
AND      (ro.cancellation IS NULL OR ro.cancellation = '')  -- Fixed condition
GROUP BY ro.runner_id;


--Is there any relationship between the number of pizzas and how long the order takes to prepare?

WITH order_count AS (
   SELECT   order_id,
            COUNT(pizza_id) AS pizzas_order_count,  -- Fixed COUNT to count pizzas correctly
            EXTRACT(EPOCH FROM (pickup_time::TIMESTAMP - order_time)) / 60 AS preparation_time
   FROM     temp_runner_orders 
   JOIN     temp_customer_orders USING (order_id)
   WHERE    pickup_time IS NOT NULL 
   AND      (cancellation IS NULL OR cancellation = '')  -- Fixed condition
   GROUP BY order_id, pickup_time, order_time
)
SELECT   pizzas_order_count, 
         ROUND(AVG(preparation_time), 2) AS avg_prep_time
FROM     order_count
GROUP BY pizzas_order_count
ORDER BY pizzas_order_count;

--What was the average distance travelled for each customer?

SELECT   customer_id,
         ROUND(AVG(distance)::NUMERIC, 2) AS avg_distance_travelled  -- Ensure proper rounding to 2 decimal places
FROM     temp_runner_orders 
JOIN     temp_customer_orders USING (order_id)
WHERE    cancellation IS NULL
GROUP BY customer_id
ORDER BY customer_id;

--What was the difference between the longest and shortest delivery times for all orders?
SELECT ROUND((MAX(duration) - MIN(duration))::NUMERIC, 2) AS maximum_difference
FROM   temp_runner_orders
WHERE  duration IS NOT NULL;



--What was the average speed for each runner for each delivery and do you notice any trend for these values?

SELECT   runner_id, 
         order_id,
         distance::NUMERIC AS distance_km,
         ROUND(duration::NUMERIC / 60, 2) AS duration_hr,
         ROUND(
             CASE 
                 WHEN duration::NUMERIC > 0 THEN (distance::NUMERIC * 60 / duration::NUMERIC) 
                 ELSE NULL 
             END, 2
         ) AS average_speed
FROM     temp_runner_orders
WHERE    cancellation IS NULL
ORDER BY runner_id, order_id;

--What is the successful delivery percentage for each runner?

SELECT   runner_id,
         COUNT(pickup_time) AS delivered_orders,
         COUNT(*) AS total_orders,
         ROUND(100.0 * COUNT(pickup_time) / COUNT(*), 2) AS delivery_success_percentage
FROM     temp_runner_orders
GROUP BY runner_id
ORDER BY runner_id;

