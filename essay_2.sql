--Q1
-- Create dim_user table
CREATE TABLE dim_user (
    user_id INT PRIMARY KEY,
    user_name VARCHAR(100),
    country VARCHAR(50)
);

-- Create dim_post table
CREATE TABLE dim_post (
    post_id INT PRIMARY KEY,
    post_text VARCHAR(500),
    post_date DATE,
    user_id INT REFERENCES dim_user(user_id)
);

-- Create dim_date table
CREATE TABLE dim_date (
    date_id INT PRIMARY KEY,
    post_date DATE
);

--Q2
-- Populate dim_user
INSERT INTO dim_user (user_id, user_name, country)
SELECT DISTINCT user_id, user_name, country FROM raw_users;

-- Populate dim_post
INSERT INTO dim_post (post_id, post_text, post_date, user_id)
SELECT DISTINCT post_id, post_text, post_date, user_id FROM raw_posts;

-- Populate dim_date
INSERT INTO dim_date (post_date)
SELECT DISTINCT post_date FROM raw_posts;

--Q3
-- Create fact_post_performance table
CREATE TABLE fact_post_performance (
    performance_id SERIAL PRIMARY KEY,
    post_id INT REFERENCES dim_post(dim_post),
    date_id INT REFERENCES dim_date(dim_date),
    views INT,
    likes INT
);

--Q4
INSERT INTO fact_post_performance (post_id, date_id, views, likes)
SELECT
    p.post_id,
    date(p.post_date) AS date_id,
    COUNT(DISTINCT v.user_id) AS views,
    COUNT(DISTINCT l.user_id) AS likes
FROM raw_posts p
LEFT JOIN raw_likes l ON p.post_id = l.post_id
LEFT JOIN (
    SELECT post_id, user_id
    FROM raw_likes
    GROUP BY post_id, user_id ) AS v ON p.post_id = v.post_id
GROUP BY p.post_id, date(p.post_date);

--Q5
-- Create fact_daily_posts table
CREATE TABLE fact_daily_posts (
    daily_post_id INT PRIMARY KEY,
    user_id INT REFERENCES dim_user(user_id),
    date_id INT REFERENCES dim_date(date_id),
    num_posts INT
);

--Q6
-- Populate fact_daily_posts
INSERT INTO fact_daily_posts (user_id, date_id, num_posts)
SELECT
    user_id,
    date_id,
    COUNT(post_id) AS num_posts
FROM dim_post
GROUP BY user_id, date_id;


