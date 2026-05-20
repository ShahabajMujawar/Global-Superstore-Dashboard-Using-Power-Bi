-- Olist E-commerce Business Analysis SQL
-- Answers key business questions using the Olist dataset.

-- 1. Why are some customers giving low ratings?
SELECT
    r.review_score,
    AVG(DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date)) AS avg_delivery_delay_days,
    COUNT(*) AS total_orders
FROM olist_order_reviews_dataset r
JOIN olist_orders_dataset o
    ON r.order_id = o.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL
GROUP BY r.review_score
ORDER BY r.review_score;

-- 2. Which product categories generate the most revenue?
SELECT
    t.product_category_name_english AS category,
    ROUND(SUM(oi.price), 2) AS total_revenue,
    COUNT(DISTINCT oi.order_id) AS total_orders
FROM olist_order_items_dataset oi
JOIN olist_products_dataset p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation t
    ON p.product_category_name = t.product_category_name
GROUP BY t.product_category_name_english
ORDER BY total_revenue DESC
LIMIT 10;

-- 3. Which sellers perform best?
SELECT
    oi.seller_id,
    ROUND(SUM(oi.price), 2) AS revenue,
    COUNT(DISTINCT oi.order_id) AS orders_count
FROM olist_order_items_dataset oi
GROUP BY oi.seller_id
ORDER BY revenue DESC
LIMIT 10;

-- 4. What causes delivery delays?
SELECT
    c.customer_state,
    ROUND(AVG(DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date)), 2) AS avg_delay_days
FROM olist_orders_dataset o
JOIN olist_customers_dataset c
    ON o.customer_id = c.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL
GROUP BY c.customer_state
ORDER BY avg_delay_days DESC;

-- 5. Which payment methods are most common?
SELECT
    payment_type,
    COUNT(*) AS transactions,
    ROUND(SUM(payment_value), 2) AS total_amount
FROM olist_order_payments_dataset
GROUP BY payment_type
ORDER BY transactions DESC;

-- 6. Which cities and states drive the most sales?
SELECT
    c.customer_state,
    c.customer_city,
    ROUND(SUM(op.payment_value), 2) AS total_sales
FROM olist_orders_dataset o
JOIN olist_customers_dataset c
    ON o.customer_id = c.customer_id
JOIN olist_order_payments_dataset op
    ON o.order_id = op.order_id
GROUP BY c.customer_state, c.customer_city
ORDER BY total_sales DESC
LIMIT 20;

-- 7. Customer satisfaction improvement opportunities
SELECT
    CASE
        WHEN DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date) > 0 THEN 'Delayed'
        ELSE 'On Time or Early'
    END AS delivery_status,
    ROUND(AVG(r.review_score), 2) AS avg_review_score,
    COUNT(*) AS total_orders
FROM olist_orders_dataset o
JOIN olist_order_reviews_dataset r
    ON o.order_id = r.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL
GROUP BY delivery_status;