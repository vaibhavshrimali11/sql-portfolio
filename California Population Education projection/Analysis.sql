SELECT 
    ca_edu.age, 
    ca_edu.edu_attainment, 
    (SUM(ca_edu.population) * 100.0 / total_pop_by_age.total_population) AS percentage
FROM ca_edu
JOIN 
    (SELECT age, SUM(population) AS total_population
     FROM ca_edu
     GROUP BY age) AS total_pop_by_age
ON ca_edu.age = total_pop_by_age.age
GROUP BY ca_edu.age, ca_edu.edu_attainment, total_pop_by_age.total_population
ORDER BY ca_edu.age, percentage DESC;


CREATE TABLE demographics AS
SELECT 
    ca_edu.age, 
    ca_edu.edu_attainment, 
    (SUM(ca_edu.population) * 100.0 / total_pop_by_age.total_population) AS percentage
FROM ca_edu
JOIN 
    (SELECT age, SUM(population) AS total_population
     FROM ca_edu
     GROUP BY age) AS total_pop_by_age
ON ca_edu.age = total_pop_by_age.age
GROUP BY ca_edu.age, ca_edu.edu_attainment, total_pop_by_age.total_population
ORDER BY ca_edu.age, percentage DESC;

SELECT 
    TO_CHAR(temp_pop.date_year::DATE, 'YYYY') AS Year,
    demographics.edu_attainment AS Education,
    ROUND(SUM(temp_pop.total_pop * demographics.percentage) / 100) AS Demand
FROM 
    -- Aggregate population by year and age group
    (SELECT date_year, age, SUM(population) AS total_pop
     FROM ca_edu
     GROUP BY date_year, age) AS temp_pop
JOIN demographics
    -- Join with the demographics table based on age group
    ON demographics.age = temp_pop.age
WHERE demographics.edu_attainment != 'Children under 15'  -- Exclude children under 15
GROUP BY temp_pop.date_year, demographics.edu_attainment
ORDER BY temp_pop.date_year, Demand DESC;
