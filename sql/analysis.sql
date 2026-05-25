-- ==============================================================================
-- EXPLORATORY DATA ANALYSIS (EDA)
-- Purpose: Understand user behavior and identify key drivers for customer churn.
-- Stack: PostgreSQL (Aggregations, JOINs, CTEs, Window Functions)
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- Query 1: Overall Churn Rate (Baseline)
-- Insight: The baseline churn rate is very high at ~48%. This means the dataset 
-- is well-balanced for future machine learning modeling.
-- ------------------------------------------------------------------------------
SELECT 
    COUNT(*) AS total_users,
    SUM(CASE WHEN churned = TRUE THEN 1 ELSE 0 END) AS churned_users,
    ROUND(AVG(CASE WHEN churned = TRUE THEN 1.0 ELSE 0.0 END) * 100, 2) AS churn_rate_pct
FROM subscription;


-- ------------------------------------------------------------------------------
-- Query 2: Churn by Demographics (Country & Gender)
-- Insight: Significant regional differences found. German male users have an 
-- extremely high churn rate (61.54%), while French male users churn at only 30.77%.
-- ------------------------------------------------------------------------------
SELECT 
    u.country,
    u.gender,
    COUNT(u.id) AS total_users,
    ROUND(AVG(CASE WHEN s.churned = TRUE THEN 1.0 ELSE 0.0 END) * 100, 2) AS churn_rate_pct
FROM users u
JOIN subscription s ON u.id = s.user_id
GROUP BY u.country, u.gender
ORDER BY churn_rate_pct DESC;


-- ------------------------------------------------------------------------------
-- Query 3: Churn by Age Groups
-- Insight: Users aged 25-40 are the most stable segment (45.27% churn). 
-- Younger (<25) and older (>40) segments show higher propensity to churn (~50%).
-- ------------------------------------------------------------------------------
SELECT 
    CASE 
        WHEN u.age < 25 THEN 'Under 25'
        WHEN u.age BETWEEN 25 AND 40 THEN '25-40'
        ELSE 'Over 40'
    END AS age_group,
    COUNT(u.id) AS total_users,
    ROUND(AVG(CASE WHEN s.churned = TRUE THEN 1.0 ELSE 0.0 END) * 100, 2) AS churn_rate_pct
FROM users u
JOIN subscription s ON u.id = s.user_id
GROUP BY 1
ORDER BY churn_rate_pct DESC;


-- ------------------------------------------------------------------------------
-- Query 4: Churn by Inactivity and Engagement
-- Insight: Churn scales with inactivity, but recently active users show a spike 
-- in churn as well (2nd highest), indicating abrupt churn patterns.
-- ------------------------------------------------------------------------------
SELECT 
    CASE 
        WHEN a.days_inactive = 0 THEN 'Active recently'
        WHEN a.days_inactive BETWEEN 1 AND 7 THEN 'Inactive < 1 week'
        WHEN a.days_inactive BETWEEN 8 AND 14 THEN 'Inactive 1-2 weeks'
        ELSE 'Inactive > 2 weeks'
    END AS inactivity_group,
    COUNT(u.id) AS total_users,
    ROUND(AVG(a.avg_watch_time)::NUMERIC, 2) AS group_avg_watch_time,
    ROUND(AVG(CASE WHEN s.churned = TRUE THEN 1.0 ELSE 0.0 END) * 100, 2) AS churn_rate_pct
FROM users u
JOIN user_activity a ON u.id = a.user_id
JOIN subscription s ON u.id = s.user_id
GROUP BY 1
ORDER BY churn_rate_pct DESC;


-- ------------------------------------------------------------------------------
-- Query 5: Churn by Payment Failures
-- Insight: Payment issues are a critical operational bottleneck. Failed 
-- transactions strongly correlate with immediate customer loss.
-- ------------------------------------------------------------------------------
SELECT 
    s.payments_failed,
    COUNT(s.user_id) AS total_users,
    ROUND(AVG(CASE WHEN s.churned = TRUE THEN 1.0 ELSE 0.0 END) * 100, 2) AS churn_rate_pct
FROM subscription s
GROUP BY s.payments_failed
ORDER BY s.payments_failed ASC;


-- ------------------------------------------------------------------------------
-- Query 6: Churn Risk Ranking within Countries (CTE & Window Functions)
-- Insight: Ranks demographic segments inside each country by their churn risk.
-- Allows to see the most vulnerable group per specific region.
-- ------------------------------------------------------------------------------
WITH country_age_churn AS (
    SELECT 
        u.country,
        CASE 
            WHEN u.age < 25 THEN 'Under 25'
            WHEN u.age BETWEEN 25 AND 40 THEN '25-40'
            ELSE 'Over 40'
        END AS age_group,
        COUNT(u.id) AS total_users,
        ROUND(AVG(CASE WHEN s.churned = TRUE THEN 1.0 ELSE 0.0 END) * 100, 2) AS churn_rate_pct
    FROM users u
    JOIN subscription s ON u.id = s.user_id
    GROUP BY u.country, age_group
)
SELECT 
    country,
    age_group,
    total_users,
    churn_rate_pct,
    RANK() OVER(PARTITION BY country ORDER BY churn_rate_pct DESC) AS churn_rank_in_country
FROM country_age_churn;


-- ------------------------------------------------------------------------------
-- Query 7: Cohort Analysis based on Country Engagement Benchmarks
-- Insight: Evaluates if users watching more content than their local country's 
-- average benchmark are more loyal. Shows behavioral impact vs local norms.
-- ------------------------------------------------------------------------------
WITH country_averages AS (
    SELECT 
        country,
        AVG(avg_watch_time) AS country_avg_time
    FROM users u
    JOIN user_activity a ON u.id = a.user_id
    GROUP BY country
)
SELECT 
    u.country,
    CASE 
        WHEN a.avg_watch_time > ca.country_avg_time THEN 'Above Country Average'
        ELSE 'Below Country Average'
    END AS engagement_level,
    COUNT(u.id) AS total_users,
    ROUND(AVG(CASE WHEN s.churned = TRUE THEN 1.0 ELSE 0.0 END) * 100, 2) AS churn_rate_pct
FROM users u
JOIN user_activity a ON u.id = a.user_id
JOIN subscription s ON u.id = s.user_id
JOIN country_averages ca ON u.country = ca.country
GROUP BY u.country, engagement_level
ORDER BY u.country, churn_rate_pct DESC;