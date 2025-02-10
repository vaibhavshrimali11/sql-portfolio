--What is the unique count and total amount for each transaction type?
SELECT 
  txn_type, 
  COUNT(*) AS txn_count, 
  SUM(txn_amount) AS total_amount
FROM 
  data_bank.customer_transactions
GROUP BY 
  txn_type
ORDER BY 
  txn_type;

--What is the average total historical deposit counts and amounts for all customers?
SELECT 
  ROUND(AVG(txn_count)) AS avg_count, 
  ROUND(AVG(avg_deposit_amount)) AS avg_deposit_amount
FROM (
  SELECT 
    customer_id, 
    COUNT(*) AS txn_count, 
    AVG(txn_amount) AS avg_deposit_amount
  FROM 
    data_bank.customer_transactions
  WHERE 
    txn_type = 'deposit'
  GROUP BY 
    customer_id
) AS subquery;

--For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
SELECT 
  month, 
  COUNT(*) AS customer_count
FROM (
  SELECT 
    DATE_PART('MONTH', txn_date) AS month, 
    customer_id
  FROM 
    data_bank.customer_transactions
  GROUP BY 
    month, customer_id
  HAVING 
    SUM(CASE WHEN txn_type = 'deposit' THEN 1 ELSE 0 END) > 1
    AND (
      SUM(CASE WHEN txn_type = 'purchase' THEN 1 ELSE 0 END) >= 1
      OR SUM(CASE WHEN txn_type = 'withdrawal' THEN 1 ELSE 0 END) >= 1
    )
) AS filtered_customers
GROUP BY 
  month
ORDER BY 
  month;


--What is the closing balance for each customer at the end of the month?
WITH monthly_balance AS (
  SELECT 
    customer_id, 
    DATE_TRUNC('month', txn_date) AS month, 
    SUM(
      CASE 
        WHEN txn_type = 'deposit' THEN txn_amount 
        ELSE -txn_amount 
      END
    ) AS monthly_change
  FROM 
    data_bank.customer_transactions
  GROUP BY 
    customer_id, month
),
closing_balance AS (
  SELECT 
    customer_id, 
    month, 
    SUM(monthly_change) OVER (
      PARTITION BY customer_id 
      ORDER BY month
    ) AS closing_balance
  FROM 
    monthly_balance
)
SELECT 
  customer_id, 
  TO_CHAR(month, 'YYYY-MM') AS month,  -- Formats month for readability
  closing_balance
FROM 
  closing_balance
ORDER BY 
  customer_id, month;

--What is the percentage of customers who increase their closing balance by more than 5%?
WITH balance AS (
  -- Calculate closing balance for each customer at the end of each month
  SELECT 
    customer_id, 
    DATE_TRUNC('month', txn_date) AS month, 
    SUM(
      CASE 
        WHEN txn_type = 'deposit' THEN txn_amount 
        ELSE -txn_amount 
      END
    ) AS monthly_change
  FROM 
    data_bank.customer_transactions
  GROUP BY 
    customer_id, month
),
closing_balance AS (
  -- Calculate running total balance for each customer
  SELECT 
    customer_id, 
    month, 
    SUM(monthly_change) OVER (
      PARTITION BY customer_id ORDER BY month
    ) AS closing_balance
  FROM 
    balance
),
balance_growth AS (
  -- Compare closing balance with previous month and calculate % change
  SELECT 
    customer_id, 
    month, 
    closing_balance, 
    LAG(closing_balance) OVER (
      PARTITION BY customer_id ORDER BY month
    ) AS prev_balance,
    ROUND(
      100.0 * (closing_balance - LAG(closing_balance) OVER (
        PARTITION BY customer_id ORDER BY month
      )) / NULLIF(LAG(closing_balance) OVER (
        PARTITION BY customer_id ORDER BY month
      ), 0), 2
    ) AS percent_change
  FROM 
    closing_balance
)
-- Calculate the percentage of customers with a balance increase > 5%
SELECT 
  ROUND(100.0 * COUNT(DISTINCT customer_id) 
        FILTER (WHERE percent_change > 5) 
        / COUNT(DISTINCT customer_id), 2) 
  AS percentage_increase
FROM 
  balance_growth;
