-- ==============================================================================
-- ANALYTICAL VIEWS FOR MACHINE LEARNING
-- Purpose: Consolidate normalized tables into a single flat view for Python ingestion.
-- ==============================================================================

CREATE OR REPLACE VIEW v_ml_features AS
SELECT 
    u.id AS user_id,
    u.age,
    u.country,
    u.gender,
    a.avg_watch_time,
    a.days_inactive,
    s.payments_failed,
    CASE WHEN s.churned = TRUE THEN 1 ELSE 0 END AS churned
FROM users u
JOIN user_activity a ON u.id = a.user_id
JOIN subscription s ON u.id = s.user_id;