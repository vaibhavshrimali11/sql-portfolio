WITH daily_interest AS (
  SELECT 
    customer_id,
    txn_date,
    balance,
    (balance * (0.06 / 365)) AS daily_simple_interest -- Simple Interest Calculation (No Compounding)
  FROM (
    -- Step 1: Calculate Running Balance for Each Customer
    SELECT 
      customer_id,
      txn_date,
      SUM(
        CASE WHEN txn_type = 'deposit' THEN txn_amount ELSE -txn_amount END
      ) OVER (PARTITION BY customer_id ORDER BY txn_date) AS balance
    FROM data_bank.customer_transactions
  ) sub
),

compounded_interest AS (
  -- Step 2: Calculate Compounded Interest (Daily)
  SELECT 
    customer_id,
    txn_date,
    balance,
    balance * (POWER(1 + (0.06 / 365), RANK() OVER (PARTITION BY customer_id ORDER BY txn_date)) - 1) AS daily_compounded_interest
  FROM daily_interest
)

-- Step 3: Aggregate Monthly Interest-Based Data Growth
SELECT 
  DATE_TRUNC('month', txn_date) AS month,
  SUM(daily_simple_interest) AS total_simple_interest,  -- Total Simple Interest (No Compounding)
  SUM(daily_compounded_interest) AS total_compounded_interest -- Total Compounded Daily Interest
FROM daily_interest
JOIN compounded_interest USING (customer_id, txn_date)
GROUP BY month
ORDER BY month;
