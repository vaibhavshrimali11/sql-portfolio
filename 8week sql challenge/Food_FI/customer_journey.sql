/* Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.

Try to keep it as short as possible - you may also want to run some sort of join to make your explanations a bit easier! */

WITH random_customers AS (
    SELECT customer_id
    FROM foodie_fi.subscriptions
    ORDER BY RANDOM()
    LIMIT 8
)
SELECT rc.customer_id,
       p.plan_id,
       p.plan_name,
       s.start_date
FROM random_customers rc
JOIN foodie_fi.subscriptions s ON rc.customer_id = s.customer_id
JOIN foodie_fi.plans p ON s.plan_id = p.plan_id
ORDER BY rc.customer_id, p.plan_id, s.start_date;
