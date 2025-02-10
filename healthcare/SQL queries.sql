-- Viewing Data
SELECT * FROM healthcare;

-- Count total records in the Database
SELECT COUNT(*) FROM healthcare;

--Finding max age of patient admitted
SELECT MAX(healthcare.Age) AS Maximuin_age 
FROM healthcare;

--Finding avg age of hospitalized person

SELECT ROUND(AVG(age),0) AS Average_age
FROM healthcare;

-- Patient Count according to age

SELECT age, COUNT(age) AS Total
FROM healthcare
GROUP BY age
ORDER BY age DESC, Total DESC;

-- Ranking age category according to highest to lowest patient count
SELECT age, 
       COUNT(age) AS total, 
       DENSE_RANK() OVER (ORDER BY COUNT(age) DESC, age DESC) AS ranking_admitted
FROM healthcare
GROUP BY age
HAVING COUNT(age) > (SELECT AVG(age) FROM healthcare);

-- Finding count of patient for diff medical condition
SELECT medical_condition, 
       COUNT(*) AS total_patient
FROM healthcare
GROUP BY medical_condition
ORDER BY total_patient DESC;

--Most common medication used for various  medical condition
SELECT medical_condition, medication, COUNT(medication) AS Total_medication_to_patient,
RANK() OVER(PARTITION BY medical_condition ORDER BY COUNT(medication) DESC) AS Rank_Medicine
FROM healthcare
GROUP BY 1,2
ORDER BY 1;

-- Most preferred Insurance Provider by patient hospitalized
SELECT insurance_provider, COUNT(insurance_provider) AS Total
FROM healthcare
GROUP BY insurance_provider;

SELECT hospital, COUNT(hospital) AS Total
FROM healthcare
GROUP BY hospital
ORDER BY COUNT(hospital) DESC;

--Identifying AVG billing amount for medical_condition
SELECT medical_condition, ROUND(AVG(billing_amount),2) AS Avg_billing_Amount
FROM healthcare
GROUP BY medical_condition
ORDER BY  ROUND(AVG(billing_amount),2) DESC;

-- 12. Finding Billing Amount of patients admitted and number of days spent in respective hospital.
SELECT 
    medical_condition, 
    name, 
    hospital, 
    (discharge_date - date_of_admission) AS number_of_days,  
    SUM(billing_amount) OVER (PARTITION BY hospital ORDER BY hospital DESC) AS total_amount
FROM healthcare
ORDER BY medical_condition;

-- Hospital with success
SELECT Medical_Condition, Hospital, (Discharge_Date-Date_of_Admission) as Total_Hospitalized_days,Test_results
FROM Healthcare
WHERE Test_results LIKE 'Normal'
ORDER BY Medical_Condition, Hospital;

--Calculate number of blood type of patient with age 20 -45
SELECT age, blood_type, COUNT(blood_type) AS count_blood_type
FROM healthcare
WHERE age BETWEEN 20 AND 45
GROUP BY 1,2
ORDER BY blood_type DESC;

--Find universal blood doner and reciever
SELECT DISTINCT (SELECT Count(Blood_Type) FROM healthcare WHERE Blood_Type IN ('O-')) AS Universal_Blood_Donor, 
(SELECT Count(Blood_Type) FROM healthcare WHERE Blood_Type  IN ('AB+')) as Universal_Blood_reciever
FROM healthcare;
-- Insurance provider billing amount

SELECT Insurance_Provider, ROUND(AVG(Billing_Amount),0) as Average_Amount, ROUND(Min(Billing_Amount),0) as Minimum_Amount, ROUND(Max(Billing_Amount),0) as Maximum_Amount
FROM healthcare
GROUP BY 1;
-- Patient reprt
SELECT Name, 
       Medical_Condition, 
       Test_Results,
       CASE 
           WHEN Test_Results = 'Inconclusive' THEN 'Need More Checks / CANNOT be Discharged'
           WHEN Test_Results = 'Normal' THEN 'Can take discharge, But need to follow Prescribed medications timely'
           WHEN Test_Results = 'Abnormal' THEN 'Needs more attention and more tests'
       END AS "Status",  -- Corrected aliasing with double quotes
       Hospital, 
       Doctor
FROM Healthcare;
