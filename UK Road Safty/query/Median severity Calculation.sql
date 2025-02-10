SELECT vehicle_type 
FROM vehicle_types 
WHERE vehicle_type LIKE '%torcycle%';

SELECT vt.vehicle_type, a.accident_severity
FROM accident a
JOIN vehicles v ON a.accident_index = v.accident_index
JOIN vehicle_types vt ON v.vehicle_type = CAST(vt.vehicle_code AS text)  -- Cast vehicle_code to text
WHERE vt.vehicle_type LIKE '%motorcycle%'  -- Adjust as needed
ORDER BY a.accident_severity;


INSERT INTO accidents_median (vehicle_types, severity)
VALUES ('Motorcycle', 5), ('Motorcycle', 3);

WITH accident_severity AS (
    SELECT vt.vehicle_type, a.accident_severity
    FROM accident a
    JOIN vehicles v ON a.accident_index = v.accident_index
    JOIN vehicle_types vt ON CAST(v.vehicle_type AS VARCHAR) = CAST(vt.vehicle_code AS VARCHAR)
    WHERE vt.vehicle_type LIKE '%motorcycle%'  -- Adjust based on your need
    ORDER BY a.accident_severity
),
accident_count AS (
    SELECT vehicle_type, COUNT(accident_severity) AS total_accidents
    FROM accident_severity
    GROUP BY vehicle_type
)
, median_calc AS (
    SELECT a.vehicle_type,
           CASE
               WHEN ac.total_accidents % 2 = 1 THEN
                   -- Odd number of accidents, take the middle value
                   (SELECT accident_severity
                    FROM accident_severity
                    WHERE vehicle_type = a.vehicle_type
                    LIMIT 1 OFFSET (ac.total_accidents / 2))
               ELSE
                   -- Even number of accidents, average the two middle values
                   (SELECT AVG(accident_severity)
                    FROM accident_severity
                    WHERE vehicle_type = a.vehicle_type
                    LIMIT 2 OFFSET (ac.total_accidents / 2 - 1))
           END AS median_severity
    FROM accident_severity a
    JOIN accident_count ac ON a.vehicle_type = ac.vehicle_type
    GROUP BY a.vehicle_type, ac.total_accidents
)
-- Insert the calculated median severity into the accidents_median table
INSERT INTO accidents_median (vehicle_types, severity)
SELECT vehicle_type, median_severity
FROM median_calc;

