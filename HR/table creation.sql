CREATE TABLE human_resources (
    id TEXT PRIMARY KEY,
    first_name TEXT,
    last_name TEXT,
    birthdate DATE,
    gender TEXT,
    race TEXT,
    department TEXT,
    jobtitle TEXT,
    location TEXT,
    hire_date DATE,
    termdate TIMESTAMP NULL,
    location_city TEXT,
    location_state TEXT
);