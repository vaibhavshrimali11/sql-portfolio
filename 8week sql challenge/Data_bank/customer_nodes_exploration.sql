--How many unique nodes are there on the Data Bank system?
WITH cte AS (
  SELECT
    region_id,
    COUNT(DISTINCT node_id) AS number_nodes
  FROM
    data_bank.customer_nodes
  GROUP BY
    region_id
)
SELECT
  SUM(number_nodes) AS total_nodes
FROM
  cte;

--What is the number of nodes per region?
SELECT
  t2.region_name,
  COUNT(DISTINCT t1.node_id) AS number_nodes
FROM
  data_bank.customer_nodes t1
INNER JOIN 
  data_bank.regions t2 
  ON t1.region_id = t2.region_id
GROUP BY 
  t2.region_name
ORDER BY 
  number_nodes DESC;  

--How many customers are allocated to each region?
SELECT
  t2.region_name,
  COUNT(DISTINCT t1.customer_id) AS number_customers  -- Renamed for clarity
FROM
  data_bank.customer_nodes t1
INNER JOIN 
  data_bank.regions t2 
  ON t1.region_id = t2.region_id
GROUP BY 
  t2.region_name
ORDER BY 
  number_customers DESC;

--How many days on average are customers reallocated to a different node?
WITH cte AS (
  SELECT
    customer_id,
    node_id,
    start_date,
    end_date,
    LAG(node_id) OVER (
      PARTITION BY customer_id 
      ORDER BY start_date
    ) AS previous_node,
    end_date - start_date AS duration
  FROM 
    data_bank.customer_nodes
  WHERE 
    DATE_PART('year', end_date) <> 9999
)
SELECT 
  CEILING(AVG(duration))::VARCHAR || ' days' AS avg_duration
FROM 
  cte
WHERE 
  node_id <> previous_node;

--What is the median, 80th and 95th percentile for this same reallocation days metric for each region?

WITH reallocation_days_cte AS (
  SELECT 
    r.region_name,
    c.end_date - c.start_date AS reallocation_days
  FROM 
    data_bank.customer_nodes c
  JOIN 
    data_bank.regions r ON c.region_id = r.region_id
  WHERE 
    DATE_PART('year', c.end_date) <> 9999
)
SELECT 
  region_name,
  PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY reallocation_days) AS median_days,
  PERCENTILE_CONT(0.80) WITHIN GROUP (ORDER BY reallocation_days) AS p80_days,
  PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY reallocation_days) AS p95_days
FROM 
  reallocation_days_cte
GROUP BY 
  region_name
ORDER BY 
  region_name;
