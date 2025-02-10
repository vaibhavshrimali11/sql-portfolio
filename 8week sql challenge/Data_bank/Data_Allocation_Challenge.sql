/*To test out a few different hypotheses - the Data Bank team wants to run an experiment where different groups of customers would be allocated data using 3 different options:

Option 1: data is allocated based off the amount of money at the end of the previous month
Option 2: data is allocated on the average amount of money kept in the account in the previous 30 days
Option 3: data is updated real-time
For this multi-part challenge question - you have been requested to generate the following data elements to help the Data Bank team estimate how much data will need to be provisioned for each option:

running customer balance column that includes the impact each transaction
customer balance at the end of each month
minimum, average and maximum values of the running balance for each customer
Using all of the data available - how much data would have been required for each option on a monthly basis?*/




-- Step 1: Calculate Running Balance for Each Customer
WITH running_balance AS (
  SELECT 
    customer_id,
    txn_date,
    SUM(
      CASE WHEN txn_type = 'deposit' THEN txn_amount ELSE -txn_amount END
    ) OVER (PARTITION BY customer_id ORDER BY txn_date) AS balance
  FROM data_bank.customer_transactions
),

-- Step 2: Get Closing Balance at End of Each Month
closing_balance AS (
  SELECT 
    customer_id,
    DATE_TRUNC('month', txn_date) AS month,
    LAST_VALUE(balance) OVER (
      PARTITION BY customer_id, DATE_TRUNC('month', txn_date) 
      ORDER BY txn_date 
      ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS end_of_month_balance
  FROM running_balance
),

-- Step 3: Calculate Min, Max & Avg Balance for Each Customer
balance_stats AS (
  SELECT 
    customer_id,
    MIN(balance) AS min_balance,
    MAX(balance) AS max_balance,
    AVG(balance) AS avg_balance
  FROM running_balance
  GROUP BY customer_id
)

-- Step 4: Calculate Data Allocation for Each Option
SELECT 
  cb.month,
  SUM(cb.end_of_month_balance) AS option_1_data,   -- Based on closing balance
  SUM(bs.avg_balance) AS option_2_data,           -- Based on 30-day avg balance
  SUM(bs.max_balance) AS option_3_data            -- Based on real-time max balance
FROM closing_balance cb
JOIN balance_stats bs USING (customer_id)
GROUP BY cb.month
ORDER BY cb.month;
