/* Create index on accident_index as it is using in both vehicles and accident tables and join clauses using indexes will perform faster */
CREATE INDEX accident_index
ON accident(accident_index);

CREATE INDEX accident_index
ON vehicles(accident_index);


/* Get Accident Severity and Total Accidents per Vehicle Type */
SELECT vt.vehicle_type AS "Vehicle Type", 
       a.accident_severity AS "Severity", 
       COUNT(vt.vehicle_type) AS "Number of Accidents"
FROM accident a
JOIN vehicles v ON a.accident_index = v.accident_index
JOIN vehicle_types vt ON CAST(v.vehicle_type AS VARCHAR(50)) = CAST(vt.vehicle_code AS VARCHAR(50))
GROUP BY vt.vehicle_type, a.accident_severity
ORDER BY a.accident_severity, "Number of Accidents";

/* Average Severity by Vehicle Type */
SELECT vt.vehicle_type AS "Vehicle Type", 
       AVG(a.accident_severity) AS "Average Severity", 
       COUNT(vt.vehicle_type) AS "Number of Accidents"
FROM accident a
JOIN vehicles v ON a.accident_index = v.accident_index
JOIN vehicle_types vt ON CAST(v.vehicle_type AS VARCHAR(50)) = CAST(vt.vehicle_code AS VARCHAR(50))
GROUP BY vt.vehicle_type
ORDER BY "Average Severity" DESC, "Number of Accidents" DESC;

/* Average Severity and Total Accidents by Motorcycle */
SELECT vt.vehicle_type AS "Vehicle Type", 
       AVG(a.accident_severity) AS "Average Severity", 
       COUNT(vt.vehicle_type) AS "Number of Accidents"
FROM accident a
JOIN vehicles v ON a.accident_index = v.accident_index
JOIN vehicle_types vt ON CAST(v.vehicle_type AS VARCHAR(50)) = CAST(vt.vehicle_code AS VARCHAR(50))
WHERE vt.vehicle_type LIKE '%otorcycle%'
GROUP BY vt.vehicle_type
ORDER BY "Average Severity" DESC, "Number of Accidents" DESC;

