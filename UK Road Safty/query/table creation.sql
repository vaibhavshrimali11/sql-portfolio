/* Create Tables */
CREATE TABLE accident (
    accident_index VARCHAR(50),  
    accident_severity INTEGER    
);

CREATE TABLE vehicles(
	accident_index VARCHAR(13),
    vehicle_type VARCHAR(50)
);

/* First: for vehicle types, create new csv by extracting data from Vehicle Type sheet from Road-Accident-Safety-Data-Guide.xls */
CREATE TABLE vehicle_types(
	vehicle_code INT,
    vehicle_type VARCHAR(10)
);

ALTER TABLE vehicle_types
ALTER COLUMN vehicle_type TYPE character varying(50);


-- Step 1: Create a temporary table with all columns
CREATE TEMP TABLE temp_accident (
    col1 VARCHAR(50),
    col2 VARCHAR(50),
    col3 VARCHAR(50),
    col4 VARCHAR(50),
    col5 VARCHAR(50),
    col6 VARCHAR(50),
    col7 INTEGER,
    col8 VARCHAR(50),
    col9 VARCHAR(50),
    col10 VARCHAR(50),
    col11 VARCHAR(50),
    col12 VARCHAR(50),
    col13 VARCHAR(50),
    col14 VARCHAR(50),
    col15 VARCHAR(50),
    col16 VARCHAR(50),
    col17 VARCHAR(50),
    col18 VARCHAR(50),
    col19 VARCHAR(50),
    col20 VARCHAR(50),
    col21 VARCHAR(50),
    col22 VARCHAR(50),
    col23 VARCHAR(50),
    col24 VARCHAR(50),
    col25 VARCHAR(50),
    col26 VARCHAR(50),
    col27 VARCHAR(50),
    col28 VARCHAR(50),
    col29 VARCHAR(50),
    col30 VARCHAR(50),
    col31 VARCHAR(50),
    col32 VARCHAR(50)
);

-- Step 2: Load data into the temporary table
COPY temp_accident FROM 'C:\Users\cvyas\Downloads\Accidents_2015.csv' WITH CSV HEADER DELIMITER ',' QUOTE '"';

-- Step 3: Insert only the required columns into the `accident` table
INSERT INTO accident (accident_index, accident_severity)
SELECT col1, col7 FROM temp_accident;

-- Step 4: Drop the temporary table (optional)
DROP TABLE temp_accident;



COPY vehicles(accident_index, vehicle_type)
FROM 'C:\Users\cvyas\Downloads\Vehicles_2015.csv'
WITH CSV HEADER DELIMITER ',' QUOTE '"';


COPY vehicle_types
FROM 'C:\Users\cvyas\Downloads\vehicle_types.csv'
WITH CSV HEADER DELIMITER ',' QUOTE '"';


CREATE TABLE accidents_median(
vehicle_types VARCHAR(100),
severity INT
);