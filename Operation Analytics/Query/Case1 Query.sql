SELECT 
    DATE_TRUNC('hour', ds::TIMESTAMP) AS review_hour,
    DATE(ds::TIMESTAMP) AS review_date,
    COUNT(*) AS num_jobs_reviewed
FROM job_data
WHERE ds >= '2020-11-01' AND ds < '2020-12-01'  -- Filter for November 2020
GROUP BY review_hour, review_date
ORDER BY review_date, review_hour;


WITH DAILY_METRIC AS (
    SELECT
        DATE(ds::TIMESTAMP) AS review_date,  -- Convert `ds` to TIMESTAMP and extract DATE
        COUNT(job_id) AS job_review
    FROM
        job_data
    GROUP BY
        review_date
)
SELECT
    review_date AS ds,
    job_review,
    AVG(job_review) OVER (ORDER BY review_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS throughput
FROM
    DAILY_METRIC
ORDER BY
    throughput DESC;


SELECT 
    language,
    COUNT(language) AS language_count,
    (COUNT(language) * 100.0 / (SELECT COUNT(*) FROM job_data)) AS percentage_share
FROM job_data
GROUP BY language
ORDER BY percentage_share DESC;


SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY job_id ORDER BY ds) AS duplicate_rows
    FROM job_data
) AS a_r
WHERE duplicate_rows > 1;

