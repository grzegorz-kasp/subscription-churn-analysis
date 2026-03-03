-- Temporary table to hold raw churn data, churned is int (0 or 1) in CSV, will be converted to boolean in final table
CREATE TEMP TABLE stg_churn_data (
    user_id INT,
    registration_date DATE,
    age INT,
    country VARCHAR(50),
    gender VARCHAR(10),
    avg_watch_time FLOAT,
    payments_failed INT,
    days_inactive INT,
    churned INT 
);
-- Load data from CSV into staging table
COPY stg_churn_data 
FROM 'PATH_TO_YOUR_CSV/churn_data_base.csv' 
DELIMITER ',' 
CSV HEADER;
-- Insert data into final tables with necessary transformations and handle duplicates
INSERT INTO users (id, registration_date, age, country, gender)
OVERRIDING SYSTEM VALUE
SELECT user_id, registration_date, age, country, gender
FROM stg_churn_data
ON CONFLICT (id) DO NOTHING;

INSERT INTO user_activity (user_id, avg_watch_time, days_inactive)
SELECT user_id, avg_watch_time, days_inactive
FROM stg_churn_data;

INSERT INTO subscription (user_id, payments_failed, churned)
SELECT user_id, payments_failed, CAST(churned AS BOOLEAN)
FROM stg_churn_data;

DROP TABLE stg_churn_data;