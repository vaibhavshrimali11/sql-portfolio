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


--What are the standard ingredients for each pizza?
SELECT   pn.pizza_id, 
         pn.pizza_name, 
         pt.topping_id, 
         pt.topping_name
FROM     pizza_names pn 
         JOIN pizza_recipes pr USING (pizza_id)
         JOIN LATERAL unnest(string_to_array(pr.toppings, ',')::INTEGER[]) AS t(topping_id) ON true
         JOIN pizza_toppings pt ON pt.topping_id = t.topping_id
ORDER BY pn.pizza_id, pt.topping_id;

--What was the most commonly added extra?
WITH extras_expanded AS (
  SELECT unnest(string_to_array(extras, ',')::INTEGER[]) AS extra_id
  FROM   temp_customer_orders
  WHERE  extras IS NOT NULL AND extras <> ''
),
counted_extras AS (
  SELECT   extra_id, COUNT(*) AS frequency
  FROM     extras_expanded
  GROUP BY extra_id
)
SELECT   pt.topping_name, ce.frequency
FROM     counted_extras ce 
         JOIN pizza_toppings pt ON ce.extra_id = pt.topping_id
ORDER BY ce.frequency DESC;

--What was the most common exclusion?
WITH exclusions_expanded AS (
  SELECT unnest(string_to_array(exclusions, ',')::INTEGER[]) AS exclusion_id
  FROM   temp_customer_orders
  WHERE  exclusions IS NOT NULL AND exclusions <> '' AND exclusions <> 'null'
),
counted_exclusions AS (
  SELECT   exclusion_id, COUNT(*) AS frequency
  FROM     exclusions_expanded
  GROUP BY exclusion_id
)
SELECT   pt.topping_name, ce.frequency
FROM     counted_exclusions ce 
         JOIN pizza_toppings pt ON ce.exclusion_id = pt.topping_id
ORDER BY ce.frequency DESC;



--Generate an order item for each record in the customers_orders table in the format of one of the following:
--Meat Lovers
--Meat Lovers - Exclude Beef
--Meat Lovers - Extra Bacon
--Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

WITH exclusion_names AS (
    SELECT co.order_id,
           STRING_AGG(pt.topping_name, ', ') AS exclusions
    FROM   temp_customer_orders co 
           CROSS JOIN LATERAL unnest(string_to_array(co.exclusions, ',')::INTEGER[]) AS excl(topping_id)
           JOIN pizza_toppings pt ON pt.topping_id = excl.topping_id
    WHERE  co.exclusions <> '' AND co.exclusions IS NOT NULL AND co.exclusions <> 'null'
    GROUP BY co.order_id
), 
extra_names AS (
    SELECT co.order_id,
           STRING_AGG(pt.topping_name, ', ') AS extras
    FROM   temp_customer_orders co 
           CROSS JOIN LATERAL unnest(string_to_array(co.extras, ',')::INTEGER[]) AS extr(topping_id)
           JOIN pizza_toppings pt ON pt.topping_id = extr.topping_id
    WHERE  co.extras <> '' AND co.extras IS NOT NULL AND co.extras <> 'null'
    GROUP BY co.order_id
)
SELECT   co.order_id,
         co.customer_id,
         pn.pizza_name ||
         COALESCE(' - Exclude ' || en.exclusions, '') ||
         COALESCE(' - Extra ' || ex.extras, '') AS order_description
FROM     temp_customer_orders co 
         JOIN pizza_names pn USING(pizza_id)
         LEFT JOIN exclusion_names en USING(order_id)
         LEFT JOIN extra_names ex USING(order_id)
ORDER BY co.order_id, co.customer_id;


--Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
--For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
WITH Ingredients AS (
    SELECT    co.order_id,
              co.pizza_id,
              pt.topping_name,
              CASE
                  WHEN pt.topping_id = ANY(string_to_array(co.extras, ',')::INTEGER[]) THEN '2x ' || pt.topping_name
                  ELSE pt.topping_name
              END AS ingredient_with_extra
    FROM      temp_customer_orders co
              CROSS JOIN LATERAL unnest(string_to_array(
                  (SELECT toppings FROM pizza_recipes WHERE pizza_id = co.pizza_id), ',')::INTEGER[]
              ) AS r(topping_id)
              JOIN pizza_toppings pt USING(topping_id)
),
AggregatedIngredients AS (
    SELECT   order_id,
             pizza_id,
             STRING_AGG(DISTINCT ingredient_with_extra, ', ' ORDER BY ingredient_with_extra) AS ingredients
    FROM     Ingredients
    GROUP BY 1, 2
)
SELECT   ai.order_id,
         CONCAT(pn.pizza_name, ': ', ai.ingredients) AS order_description
FROM     AggregatedIngredients ai 
         JOIN pizza_names pn USING(pizza_id)
ORDER BY ai.order_id;


--What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

WITH BaseIngredients AS (
    SELECT   pt.topping_id,
             COUNT(*) AS base_count 
    FROM     pizza_recipes pr 
             JOIN pizza_toppings pt ON pt.topping_id = ANY(string_to_array(pr.toppings, ',')::INTEGER[])
    GROUP BY pt.topping_id
), 
Extras AS (
    SELECT   unnest(string_to_array(co.extras, ',')::INTEGER[]) AS topping_id,
             COUNT(*) AS extra_count
    FROM     temp_customer_orders co
    WHERE    co.extras IS NOT NULL AND co.extras <> ''
    GROUP BY topping_id
), 
TotalIngredients AS (
    SELECT   COALESCE(bi.topping_id, e.topping_id) AS topping_id,
             COALESCE(bi.base_count, 0) + COALESCE(e.extra_count, 0) AS total_count
    FROM     BaseIngredients bi 
             FULL OUTER JOIN Extras e ON bi.topping_id = e.topping_id
)
SELECT   pt.topping_name,
         ti.total_count
FROM     TotalIngredients ti 
         JOIN pizza_toppings pt ON ti.topping_id = pt.topping_id
ORDER BY ti.total_count DESC;
