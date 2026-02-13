SELECT DISTINCT event_type 
FROM events;

SELECT 
    event_type,
    COUNT(DISTINCT session_id) AS sessions
FROM events
GROUP BY event_type
ORDER BY sessions DESC;

SELECT
    session_id,
    MAX(event_type = 'view') AS viewed,
    MAX(event_type = 'add_to_cart') AS added_to_cart,
    MAX(event_type = 'checkout') AS checked_out,
    MAX(event_type = 'purchase') AS purchased
FROM events
GROUP BY session_id;

WITH funnel AS (
    SELECT
        session_id,
        MAX(event_type = 'view') AS viewed,
        MAX(event_type = 'add_to_cart') AS carted,
        MAX(event_type = 'checkout') AS checkouted,
        MAX(event_type = 'purchase') AS purchased
    FROM events
    GROUP BY session_id
)
SELECT
    COUNT(*) AS total_sessions,
    SUM(viewed) AS viewed,
    SUM(carted) AS carted,
    SUM(checkouted) AS checkouted,
    SUM(purchased) AS purchased,
    ROUND(SUM(carted)/SUM(viewed)*100,2) AS view_to_cart_pct,
    ROUND(SUM(checkouted)/SUM(carted)*100,2) AS cart_to_checkout_pct,
    ROUND(SUM(purchased)/SUM(checkouted)*100,2) AS checkout_to_purchase_pct
FROM funnel;

SELECT
    CASE
        WHEN viewed = 1 AND carted = 0 THEN 'View → Drop'
        WHEN carted = 1 AND checkouted = 0 THEN 'Cart → Drop'
        WHEN checkouted = 1 AND purchased = 0 THEN 'Checkout → Drop'
        ELSE 'Converted'
    END AS drop_stage,
    COUNT(*) AS sessions
FROM (
    SELECT
        session_id,
        MAX(event_type = 'view') AS viewed,
        MAX(event_type = 'add_to_cart') AS carted,
        MAX(event_type = 'checkout') AS checkouted,
        MAX(event_type = 'purchase') AS purchased
    FROM events
    GROUP BY session_id
) t
GROUP BY drop_stage
ORDER BY sessions DESC;

SELECT
    AVG(TIMESTAMPDIFF(MINUTE, view_time, purchase_time)) AS avg_minutes_to_purchase
FROM (
    SELECT
        session_id,
        MIN(CASE WHEN event_type = 'view' THEN timestamp END) AS view_time,
        MIN(CASE WHEN event_type = 'purchase' THEN timestamp END) AS purchase_time
    FROM events
    GROUP BY session_id
) t
WHERE view_time IS NOT NULL
  AND purchase_time IS NOT NULL
  AND purchase_time > view_time;

SELECT
    product_id,
    SUM(event_type = 'view') AS views,
    SUM(event_type = 'add_to_cart') AS carts,
    SUM(event_type = 'purchase') AS purchases,
    ROUND(
        SUM(event_type = 'purchase') /
        NULLIF(SUM(event_type = 'view'), 0) * 100,
    2) AS conversion_rate
FROM events
GROUP BY product_id
HAVING views >= 10
ORDER BY conversion_rate ASC;

-- How many sessions actually purchased?
SELECT COUNT(DISTINCT session_id)
FROM events
WHERE event_type = 'purchase';

-- Max views per product
SELECT product_id, COUNT(*) AS views
FROM events
WHERE event_type = 'view'
GROUP BY product_id
ORDER BY views DESC
LIMIT 5;

SELECT event_type, COUNT(*) 
FROM events 
GROUP BY event_type;

SELECT COUNT(*) FROM orders;

SELECT 
    COUNT(*) AS total_rows,
    COUNT(product_id) AS product_present
FROM events;

SELECT 
    MIN(timestamp),
    MAX(timestamp)
FROM events;

SELECT
    AVG(TIMESTAMPDIFF(MINUTE, first_view, first_purchase)) AS avg_minutes_to_purchase
FROM (
    SELECT
        s.customer_id,
        MIN(e.timestamp) AS first_view,
        MIN(o.order_time) AS first_purchase
    FROM sessions s
    JOIN events e 
        ON s.session_id = e.session_id 
       AND e.event_type = 'view'
    JOIN orders o 
        ON s.customer_id = o.customer_id
    GROUP BY s.customer_id
) t
WHERE first_purchase > first_view;

SELECT
    e.product_id,
    COUNT(*) AS views,
    COUNT(DISTINCT oi.order_id) AS purchases,
    ROUND(
        COUNT(DISTINCT oi.order_id) / NULLIF(COUNT(*), 0) * 100,
    2) AS conversion_rate
FROM events e
LEFT JOIN order_items oi
    ON e.product_id = oi.product_id
WHERE e.event_type = 'view'
GROUP BY e.product_id
HAVING views >= 5
ORDER BY conversion_rate ASC;


SELECT
    AVG(TIMESTAMPDIFF(MINUTE, first_view, first_purchase)) AS avg_minutes_to_purchase
FROM (
    SELECT
        session_id,
        MIN(CASE WHEN event_type = 'page_view' THEN timestamp END) AS first_view,
        MIN(CASE WHEN event_type = 'purchase' THEN timestamp END) AS first_purchase
    FROM events
    GROUP BY session_id
) t
WHERE first_view IS NOT NULL
  AND first_purchase IS NOT NULL
  AND first_purchase > first_view;

SELECT
    product_id,
    COUNT(*) AS views,
    SUM(event_type = 'purchase') AS purchases,
    ROUND(
        SUM(event_type = 'purchase') / NULLIF(COUNT(*), 0) * 100,
    2) AS conversion_rate
FROM events
WHERE event_type IN ('page_view', 'purchase')
  AND product_id IS NOT NULL
GROUP BY product_id
HAVING views >= 10
ORDER BY conversion_rate ASC;

-- sanity check: page views with product
SELECT COUNT(*) 
FROM events 
WHERE event_type = 'page_view' AND product_id IS NOT NULL;

-- sanity check: purchases with product
SELECT COUNT(*) 
FROM events 
WHERE event_type = 'purchase' AND product_id IS NOT NULL;
