SELECT * FROM human_resources;

ALTER TABLE human_resources
RENAME COLUMN "id" TO emp_id;

SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'human_resources';


SELECT birthdate FROM human_resources;

-- Step 1: Convert and Standardize Birthdate
UPDATE human_resources
SET birthdate = 
    CASE 
        WHEN birthdate::TEXT ~ '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$' 
        THEN TO_DATE(birthdate::TEXT, 'MM/DD/YYYY')
        WHEN birthdate::TEXT ~ '^[0-9]{1,2}-[0-9]{1,2}-[0-9]{4}$' 
        THEN TO_DATE(birthdate::TEXT, 'MM-DD-YYYY')
        ELSE birthdate  -- Keep existing valid DATE values unchanged
    END;

-- Step 2: Remove Future Birthdates
UPDATE human_resources
SET birthdate = NULL  -- OR set it to a default valid date
WHERE birthdate > CURRENT_DATE;

-- Step 3: Enforce Data Type as DATE
ALTER TABLE human_resources 
ALTER COLUMN birthdate TYPE DATE 
USING birthdate::DATE;


UPDATE human_resources
SET hire_date = 
    CASE 
        WHEN hire_date::TEXT ~ '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$' 
        THEN TO_DATE(hire_date::TEXT, 'MM/DD/YYYY')
        WHEN hire_date::TEXT ~ '^[0-9]{1,2}-[0-9]{1,2}-[0-9]{4}$' 
        THEN TO_DATE(hire_date::TEXT, 'MM-DD-YYYY')
        ELSE hire_date  -- Keep valid DATE values unchanged
    END;

ALTER TABLE human_resources
ALTER COLUMN hire_date TYPE DATE 
USING hire_date::DATE;

UPDATE human_resources
SET termdate = 
    CASE 
        WHEN termdate::TEXT = '' THEN NULL  -- Convert empty strings to NULL
        ELSE TO_DATE(termdate::TEXT, 'YYYY-MM-DD HH24:MI:SS UTC')  
    END
WHERE termdate IS NOT NULL;

ALTER TABLE human_resources 
ALTER COLUMN termdate TYPE DATE 
USING termdate::DATE;

ALTER TABLE human_resources ADD COLUMN age INT;

UPDATE human_resources
SET age = DATE_PART('year', AGE(birthdate));

-- Finding the youngest and oldest employee

SELECT 
    MIN(EXTRACT(YEAR FROM AGE(birthdate))) AS youngest,
    MAX(EXTRACT(YEAR FROM AGE(birthdate))) AS oldest
FROM human_resources
WHERE birthdate <= CURRENT_DATE;  -- Exclude future dates


SELECT COUNT(*) 
FROM human_resources 
WHERE age < 18;


SELECT COUNT(*) 
FROM human_resources 
WHERE termdate > CURRENT_DATE;



SELECT COUNT(*) 
FROM human_resources 
WHERE termdate IS NULL;

SELECT location FROM human_resources;











