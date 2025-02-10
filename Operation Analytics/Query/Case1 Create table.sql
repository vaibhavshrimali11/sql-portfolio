CREATE TABLE job_data (
    ds DATE,
    job_id SERIAL,
    actor_id INT,
    event TEXT CHECK (event IN ('decision', 'skip', 'transfer')),  
    language TEXT,
    time_spent INT CHECK (time_spent >= 0),  
    org TEXT NOT NULL  
);
