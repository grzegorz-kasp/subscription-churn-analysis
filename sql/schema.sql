CREATE TABLE IF NOT EXISTS users (
    id  INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    registration_date DATE NOT NULL,
    age INT NOT NULL,
    country VARCHAR(50) NOT NULL,
    gender VARCHAR(10) NOT NULL
);
CREATE TABLE IF NOT EXISTS user_activity (
    id  INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id INT NOT NULL,
    avg_watch_time FLOAT NOT NULL,
    days_inactive INT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES user(id)
);
CREATE TABLE IF NOT EXISTS subscription (
    id  INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id INT NOT NULL,
    payments_failed INT NOT NULL,
    churned BOOLEAN NOT NULL,
    FOREIGN KEY (user_id) REFERENCES user(id)
);