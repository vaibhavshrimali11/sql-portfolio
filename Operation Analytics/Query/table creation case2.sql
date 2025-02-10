CREATE TABLE users (
    user_id INT,
    created_at TIMESTAMP NOT NULL,
    company_id INT,
    language VARCHAR(50),
    activated_at TIMESTAMP,
    state VARCHAR(50)
);

CREATE TABLE events (
    user_id INT ,
    occured_at TIMESTAMP NOT NULL,
    event_type VARCHAR(100),
	event_name VARCHAR(100),
    location VARCHAR(255),
    device VARCHAR(100),
    user_type VARCHAR(50)
);



CREATE TABLE email_events (
    user_id INT NOT NULL,
    occured_at TIMESTAMP NOT NULL,
    action VARCHAR(100),
    user_type VARCHAR(50)
);

