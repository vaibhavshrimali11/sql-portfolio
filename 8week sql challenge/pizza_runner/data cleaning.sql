DROP TABLE IF EXISTS temp_runner_orders;

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
SELECT * FROM temp_runner_orders;



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

SELECT * 
FROM   temp_customer_orders;
