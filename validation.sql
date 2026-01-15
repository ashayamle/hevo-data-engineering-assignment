-- =====================================================
-- Validation Queries
-- Hevo Take-Home Assignment
-- =====================================================

-- -----------------------------------------------------
-- Assignment 1: Ingestion Validation
-- -----------------------------------------------------

SELECT COUNT(*) AS pg_customers_count
FROM pg_customers;

SELECT COUNT(*) AS pg_orders_count
FROM pg_orders;

SELECT COUNT(*) AS pg_feedback_count
FROM pg_feedback;

-- -----------------------------------------------------
-- Assignment 1: Transformation Validation
-- -----------------------------------------------------

-- Validate username derivation
SELECT email, username
FROM customers_with_username
WHERE email IS NOT NULL
LIMIT 10;

-- Validate order event generation
SELECT event_type, COUNT(*) AS event_count
FROM order_events
GROUP BY event_type;

-- -----------------------------------------------------
-- Assignment 2: Cleaning Validation
-- -----------------------------------------------------

-- Validate customer deduplication
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT customer_id) AS distinct_customers
FROM customers_cleaned;

-- Validate order status normalization
SELECT order_status, COUNT(*) AS status_count
FROM orders_cleaned
GROUP BY order_status;

-- Validate final analytics dataset row parity
SELECT
    (SELECT COUNT(*) FROM orders_cleaned) AS orders_cleaned_count,
    (SELECT COUNT(*) FROM orders_analytics_final) AS analytics_final_count;
