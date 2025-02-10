-- What is the gender breakdown of employees in the company?
SELECT gender, COUNT(*) AS count
FROM human_resources
WHERE age >= 18
GROUP BY gender;

-- Race/Ethnicity Breakdown of Employees
SELECT race, COUNT(*) AS total_employees
FROM human_resources
WHERE age >= 18
GROUP BY race
ORDER BY total_employees DESC;

--. What is the age distribution of employees in the company?

SELECT 
  CASE 
    WHEN age >= 18 AND age <= 24 THEN '18-24'
    WHEN age >= 25 AND age <= 34 THEN '25-34'
    WHEN age >= 35 AND age <= 44 THEN '35-44'
    WHEN age >= 45 AND age <= 54 THEN '45-54'
    WHEN age >= 55 AND age <= 64 THEN '55-64'
    ELSE '65+' 
  END AS age_group, gender,
  COUNT(*) AS count
FROM 
  human_resources
WHERE 
  age >= 18
GROUP BY age_group, gender
ORDER BY age_group, gender;
--4. Employees at Headquarters vs. Remote Locations

SELECT location, COUNT(*) as count
FROM human_resources
WHERE age >= 18
GROUP BY location;

-- Average Length of Employment for Terminated Employees
SELECT 
    ROUND(AVG(EXTRACT(YEAR FROM AGE(termdate, hire_date))), 2) AS avg_years_employed
FROM human_resources
WHERE termdate IS NOT NULL;
--How does the gender distribution vary across departments?
SELECT department, gender, COUNT(*) as count
FROM human_resources
WHERE age >= 18
GROUP BY department, gender
ORDER BY department;
--What is the distribution of job titles across the company?
SELECT jobtitle, COUNT(*) as count
FROM human_resources
WHERE age >= 18
GROUP BY jobtitle
ORDER BY jobtitle DESC;

--Which department has the highest turnover rate?
SELECT department, 
       COUNT(*) AS total_count, 
       SUM(CASE WHEN termdate IS NOT NULL AND termdate <= CURRENT_DATE THEN 1 ELSE 0 END) AS terminated_count, 
       SUM(CASE WHEN termdate IS NULL THEN 1 ELSE 0 END) AS active_count,
       ROUND((SUM(CASE WHEN termdate IS NOT NULL AND termdate <= CURRENT_DATE THEN 1 ELSE 0 END) * 1.0 / COUNT(*)) * 100, 2) AS termination_rate
FROM human_resources
WHERE age >= 18
GROUP BY department
ORDER BY termination_rate DESC;

--Employee Distribution Across Locations by City  State
SELECT location_city AS city, location_state AS state, COUNT(*) AS total_employees
FROM human_resources
GROUP BY city, state
ORDER BY total_employees DESC;

-- How has the company's employee count changed over time based on hire and term dates?

SELECT 
    EXTRACT(YEAR FROM hire_date) AS year, 
    COUNT(*) AS hires, 
    SUM(CASE WHEN termdate IS NOT NULL AND termdate <= CURRENT_DATE THEN 1 ELSE 0 END) AS terminations, 
    COUNT(*) - SUM(CASE WHEN termdate IS NOT NULL AND termdate <= CURRENT_DATE THEN 1 ELSE 0 END) AS net_change,
    ROUND(
        (COUNT(*) - SUM(CASE WHEN termdate IS NOT NULL AND termdate <= CURRENT_DATE THEN 1 ELSE 0 END))::NUMERIC 
        / COUNT(*) * 100, 2
    ) AS net_change_percent
FROM human_resources
WHERE age >= 18
GROUP BY EXTRACT(YEAR FROM hire_date)
ORDER BY EXTRACT(YEAR FROM hire_date) ASC;


