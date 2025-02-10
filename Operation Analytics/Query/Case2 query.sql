SELECT
    DATE_TRUNC('week', created_at) AS week_start_date,
    COUNT(DISTINCT user_id) AS active_users_count
FROM
    users
GROUP BY
    week_start_date
ORDER BY
    week_start_date;

SELECT
    DATE_TRUNC('month', created_at) AS month_start_date,
    COUNT(DISTINCT user_id) AS total_users
FROM
    users
GROUP BY
    month_start_date
ORDER BY
    month_start_date;



WITH user_signups AS (
    SELECT
        user_id,
        DATE_TRUNC('week', created_at) AS signup_week
    FROM
        users
),
user_activity AS (
    SELECT
        user_id,
        DATE_TRUNC('week', occured_at) AS activity_week  -- Corrected column name here
    FROM
        events
)
SELECT
    us.signup_week AS cohort_week,
    ua.activity_week AS retention_week,
    COUNT(DISTINCT ua.user_id) AS retained_users
FROM
    user_signups us
LEFT JOIN
    user_activity ua ON us.user_id = ua.user_id AND ua.activity_week >= us.signup_week
GROUP BY
    us.signup_week, ua.activity_week
ORDER BY
    us.signup_week, ua.activity_week;

SELECT
    DATE_TRUNC('week', e.occured_at) AS week_start_date,  -- Corrected column name here
    e.device,
    COUNT(DISTINCT e.user_id) AS active_users_count
FROM
    events e
GROUP BY
    week_start_date, e.device
ORDER BY
    week_start_date, e.device;

SELECT
    action,
    COUNT(DISTINCT user_id) AS unique_users_count,
    COUNT(*) AS total_actions_count
FROM
    email_events
GROUP BY
    action
ORDER BY
    action;

