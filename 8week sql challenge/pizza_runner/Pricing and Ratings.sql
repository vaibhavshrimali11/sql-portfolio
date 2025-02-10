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


-- If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
SELECT SUM(
           CASE 
               WHEN pn.pizza_name = 'Meatlovers' THEN 12 
               ELSE 10 
           END
         ) AS total_cost
FROM   temp_customer_orders co 
       JOIN pizza_names pn USING(pizza_id)
       JOIN temp_runner_orders ro USING(order_id)
WHERE  ro.cancellation IS NULL OR ro.cancellation = '';


--What if there was an additional $1 charge for any pizza extras?
--Add cheese is $1 extra

WITH pizza_revenue AS (
    SELECT SUM(
               CASE 
                   WHEN pn.pizza_name = 'Meatlovers' THEN 12 
                   ELSE 10 
               END
           ) AS base_revenue
    FROM   temp_customer_orders co 
           JOIN pizza_names pn USING(pizza_id)
           JOIN temp_runner_orders ro USING(order_id)
    WHERE  ro.cancellation IS NULL OR ro.cancellation = ''
),
topping_revenue AS (
    SELECT SUM(
               CASE 
                   WHEN co.extras IS NULL OR co.extras = '' OR co.extras = 'null' THEN 0
                   ELSE array_length(string_to_array(co.extras, ','), 1)
               END
           ) AS extra_revenue
    FROM   temp_customer_orders co 
           JOIN temp_runner_orders ro USING(order_id)
    WHERE  ro.cancellation IS NULL OR ro.cancellation = ''
)
SELECT (p.base_revenue + t.extra_revenue) AS total_cost
FROM   pizza_revenue p, topping_revenue t;


--The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.
DROP TABLE IF EXISTS runner_rating;

CREATE TABLE runner_rating (
  	order_id INTEGER PRIMARY KEY,
  	rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comments VARCHAR(255) -- Increased length for more detailed feedback
);

INSERT INTO runner_rating (order_id, rating, comments)
VALUES 
    (1, 1, 'Really bad service'),
    (2, 1, NULL),
    (3, 2, 'Took too long...'),
    (4, 1, 'Runner was lost, delivered it AFTER an hour. Pizza arrived cold'),
    (5, 4, 'Good service'),
    (6, 5, 'It was great, good service and fast'),
    (8, 1, 'He tossed it on the doorstep, poor service'),
    (10, 5, 'Delicious! He delivered it sooner than expected too!');

SELECT * FROM runner_rating;

--  Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
SELECT   
    co.customer_id,
    co.order_id,
    ro.runner_id,
    rr.rating,
    co.order_time,
    ro.pickup_time,
    EXTRACT(EPOCH FROM (ro.pickup_time::TIMESTAMP - co.order_time)) / 60 AS preparation_time,
    ro.duration AS delivery_duration,
    ROUND(ro.distance::NUMERIC * 60 / NULLIF(ro.duration::NUMERIC, 0), 2) AS avg_speed, -- Avoid division by zero
    COUNT(co.pizza_id) AS total_pizza_count
FROM     
    temp_customer_orders co 
JOIN 
    temp_runner_orders ro USING(order_id)
JOIN 
    runner_rating rr USING(order_id)
GROUP BY 
    co.customer_id, co.order_id, ro.runner_id, rr.rating, 
    co.order_time, ro.pickup_time, ro.duration, ro.distance
ORDER BY 
    co.customer_id, co.order_id;

--If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?
WITH sales_revenue AS (
    SELECT SUM(CASE WHEN pn.pizza_name = 'Meat Lovers' THEN 12 ELSE 10 END) AS total_sales
    FROM   temp_customer_orders co
    JOIN   pizza_names pn ON co.pizza_id = pn.pizza_id
    JOIN   temp_runner_orders ro ON co.order_id = ro.order_id
    WHERE  ro.cancellation IS NULL
),
runner_expenses AS (
    SELECT SUM(ro.distance::NUMERIC * 0.30) AS total_expenses
    FROM   temp_runner_orders ro
    WHERE  ro.cancellation IS NULL 
           AND ro.distance IS NOT NULL
)
SELECT 
    COALESCE(sr.total_sales, 0) - COALESCE(re.total_expenses, 0) AS leftover_amount
FROM 
    sales_revenue sr, runner_expenses re;
