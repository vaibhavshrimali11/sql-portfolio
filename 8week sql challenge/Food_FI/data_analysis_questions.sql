--How many customers has Foodie-Fi ever had?
SELECT COUNT(DISTINCT customer_id) AS total_customers  
FROM foodie_fi.subscriptions;

--What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
SELECT  
    EXTRACT(MONTH FROM s.start_date) AS month_number,
    COUNT(s.customer_id) AS trial_subscriptions
FROM foodie_fi.plans p  
JOIN foodie_fi.subscriptions s USING(plan_id)  
WHERE p.plan_name = 'trial'  
GROUP BY month_number  
ORDER BY month_number;

--What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
SELECT   
    p.plan_name,
    COUNT(*) AS subscription_count
FROM foodie_fi.plans p  
JOIN foodie_fi.subscriptions s USING(plan_id)  
WHERE EXTRACT(YEAR FROM s.start_date) > 2020  
GROUP BY p.plan_name  
ORDER BY subscription_count DESC;

--What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
SELECT 
    COUNT(DISTINCT customer_id) FILTER (WHERE plan_id = (SELECT plan_id FROM foodie_fi.plans WHERE plan_name = 'churn')) AS churned_customers,
    ROUND(100.0 * COUNT(DISTINCT customer_id) FILTER (WHERE plan_id = (SELECT plan_id FROM foodie_fi.plans WHERE plan_name = 'churn')) 
          / COUNT(DISTINCT customer_id), 1) AS churn_percentage
FROM foodie_fi.subscriptions;

--How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
WITH customer_journeys AS (
    SELECT  s.customer_id,
            p.plan_name,
            LEAD(p.plan_name) OVER (PARTITION BY s.customer_id ORDER BY s.start_date) AS next_plan
    FROM    foodie_fi.subscriptions s 
    JOIN    foodie_fi.plans p USING(plan_id)
)
SELECT 
    COUNT(DISTINCT customer_id) AS churned_customers,
    ROUND(100.0 * COUNT(DISTINCT customer_id) / 
                 (SELECT COUNT(DISTINCT customer_id) FROM foodie_fi.subscriptions), 1) 
                 AS churn_percentage
FROM   customer_journeys
WHERE  plan_name = 'trial' AND next_plan = 'churn';

--What is the number and percentage of customer plans after their initial free trial?
WITH customer_journeys AS (
    SELECT  s.customer_id,
            p.plan_name AS current_plan,
            LEAD(p.plan_name) OVER (PARTITION BY s.customer_id ORDER BY s.start_date) AS next_plan
    FROM    foodie_fi.subscriptions s 
    JOIN    foodie_fi.plans p USING(plan_id)
)
SELECT   
    next_plan AS plan_name,
    COUNT(DISTINCT customer_id) AS conversion_count,
    ROUND(100.0 * COUNT(DISTINCT customer_id) / 
                 (SELECT COUNT(DISTINCT customer_id) FROM foodie_fi.subscriptions), 1) 
                 AS conversion_percentage
FROM     customer_journeys
WHERE    current_plan = 'trial' AND next_plan IS NOT NULL
GROUP BY next_plan
ORDER BY conversion_count DESC;

--What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
WITH customer_last_plan AS (
    SELECT  customer_id,
            plan_name,
            start_date,
            LEAD(start_date) OVER (PARTITION BY customer_id ORDER BY start_date) AS next_date
    FROM    foodie_fi.subscriptions s 
    JOIN    foodie_fi.plans p USING(plan_id)
    WHERE   start_date <= '2020-12-31'
)
SELECT   
    plan_name,
    COUNT(DISTINCT customer_id) AS customer_count,
    ROUND(100.0 * COUNT(DISTINCT customer_id) / 
                 (SELECT COUNT(DISTINCT customer_id) FROM foodie_fi.subscriptions), 1) 
                 AS percentage
FROM     customer_last_plan
WHERE    next_date IS NULL  -- Only selecting customers whose last recorded plan was before 2021
GROUP BY plan_name
ORDER BY customer_count DESC;

--How many customers have upgraded to an annual plan in 2020?

WITH previous_plan AS (
    SELECT customer_id,
           plan_id,
           start_date,
           LAG(plan_id) OVER(PARTITION BY customer_id ORDER BY start_date) AS prev_plan_id
    FROM   foodie_fi.subscriptions
)
SELECT COUNT(DISTINCT customer_id) AS customer_count
FROM   previous_plan
WHERE  prev_plan_id < 3  -- Ensures customer upgraded from a lower plan
AND    plan_id = 3        -- Only consider customers who upgraded to Plan 3
AND    EXTRACT(YEAR FROM start_date) = 2020;

--How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
WITH trial_plan_cte AS (
    SELECT customer_id, start_date AS trial_start_date
    FROM   foodie_fi.subscriptions
    WHERE  plan_id = 0
),
annual_plan_cte AS (
    SELECT customer_id, start_date AS annual_start_date
    FROM   foodie_fi.subscriptions
    WHERE  plan_id = 3
)
SELECT ROUND(AVG(a.annual_start_date - t.trial_start_date)) AS avg_conversion_days
FROM   trial_plan_cte t
JOIN   annual_plan_cte a USING (customer_id);

--Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
WITH trial_plan_cte AS (
    SELECT customer_id, start_date AS trial_start_date
    FROM   foodie_fi.subscriptions
    WHERE  plan_id = 0
),
annual_plan_cte AS (
    SELECT customer_id, start_date AS annual_start_date
    FROM   foodie_fi.subscriptions
    WHERE  plan_id = 3
),
conversion_times AS (
    SELECT  tpc.customer_id,
            (apc.annual_start_date - tpc.trial_start_date) AS days_to_convert
    FROM    trial_plan_cte tpc
    JOIN    annual_plan_cte apc USING(customer_id)
)
SELECT  CASE 
            WHEN days_to_convert <= 30 THEN '0-30 days'
            WHEN days_to_convert <= 60 THEN '31-60 days'
            WHEN days_to_convert <= 90 THEN '61-90 days'
            WHEN days_to_convert <= 120 THEN '91-120 days'
            ELSE 'Over 120 days'
        END AS conversion_period,
        COUNT(*) AS customer_count,
        ROUND(AVG(days_to_convert), 0) AS avg_conversion_days
FROM    conversion_times
GROUP BY 1
ORDER BY MIN(days_to_convert);


--How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
WITH customer_journeys AS (
    SELECT s.customer_id,  
           p.plan_name, 
           LEAD(p.plan_name) OVER (PARTITION BY s.customer_id ORDER BY s.start_date) AS next_plan_name
    FROM   foodie_fi.subscriptions s JOIN foodie_fi.plans p USING(plan_id)
    WHERE  EXTRACT(YEAR from start_date) = 2020
)
SELECT  COUNT(customer_id) AS downgraded_customers
FROM    customer_journeys
WHERE   plan_name='pro monthly' and next_plan_name='basic monthly';
