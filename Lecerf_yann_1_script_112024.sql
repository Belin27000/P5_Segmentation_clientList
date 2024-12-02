-- SELECT *
-- FROM orders
--     INNER JOIN order_items oi ON orders.order_id = oi.order_id
-- ORDER BY order_purchase_timestamp DESC;
-- ---ORDERS DELIVERY MORE THAN 3 DAYS DELAY---
-- SELECT *
-- FROM orders
-- WHERE order_purchase_timestamp >= DATE(
--         (
--             SELECT MAX(order_purchase_timestamp)
--             FROM orders
--         ),
--         '-3 month'
--     )
--     AND order_status <> 'canceled'
--     AND JULIANDAY(order_delivered_customer_date) - JULIANDAY(order_estimated_delivery_date) > 3;
-- ---Sellers with more than 100K real on delivery orders---
-- SELECT sellers.seller_id,
--     sellers.seller_zip_code_prefix,
--     sellers.seller_city,
--     sellers.seller_state,
--     SUM(order_pymts.payment_value) AS total_revenue
-- FROM order_items
--     INNER JOIN orders ON order_items.order_id = orders.order_id
--     INNER JOIN sellers ON order_items.seller_id = sellers.seller_id
--     INNER JOIN order_pymts ON orders.order_id = order_pymts.order_id
-- WHERE orders.order_status <> 'canceled'
-- GROUP BY sellers.seller_id
-- HAVING SUM(order_pymts.payment_value) > 100000
-- ORDER BY total_revenue DESC;
-- ---Young seller (less than 3 month) with more than 30 products sales ---
-- SELECT oi.seller_id,
--     COUNT(oi.order_item_id) AS total_sales
-- FROM orders o
--     INNER JOIN order_items oi ON o.order_id = oi.order_id
-- WHERE order_purchase_timestamp >= DATE(
--         (
--             SELECT MAX(order_purchase_timestamp)
--             FROM orders
--         ),
--         '-3 month'
--     )
-- GROUP BY oi.seller_id
-- HAVING COUNT(oi.order_item_id) > 30
-- ORDER BY total_sales DESC;
-- --- 5 zip code with more than 30 reviews with the worth score on the last 12 month---
-- SELECT customers.customer_zip_code_prefix AS zip_code,
--     COUNT (order_reviews.review_score) AS review_count,
--     AVG (order_reviews.review_score) AS avg_review_score
-- FROM order_reviews
--     INNER JOIN orders ON order_reviews.order_id = orders.order_id
--     INNER JOIN customers ON orders.customer_id = customers.customer_id
-- WHERE orders.order_purchase_timestamp >= DATE(
--         (
--             SELECT MAX(order_purchase_timestamp)
--             FROM orders
--         ),
--         '-12 month'
--     )
-- GROUP BY customers.customer_zip_code_prefix
-- HAVING COUNT(order_reviews.review_score) > 30
-- ORDER BY avg_review_score ASC
-- LIMIT 5;
---ORDERS DELIVERY MORE THAN 3 DAYS DELAY---
WITH RecentOrders AS (
    SELECT *
    FROM orders
    WHERE order_purchase_timestamp >= DATE(
            (
                SELECT MAX(order_purchase_timestamp)
                FROM orders
            ),
            '-3 month'
        )
),
DelayedOrders AS (
    SELECT *
    FROM RecentOrders
    WHERE order_status <> 'canceled'
        AND JULIANDAY(order_delivered_customer_date) - JULIANDAY(order_estimated_delivery_date) > 3
)
SELECT *
FROM DelayedOrders;
---Sellers with more than 100K real on delivery orders---
WITH SellerOrders AS (
    SELECT sellers.seller_id,
        sellers.seller_zip_code_prefix,
        sellers.seller_city,
        sellers.seller_state,
        SUM(order_pymts.payment_value) AS total_revenue
    FROM order_items
        INNER JOIN orders ON order_items.order_id = orders.order_id
        INNER JOIN sellers ON order_items.seller_id = sellers.seller_id
        INNER JOIN order_pymts ON orders.order_id = order_pymts.order_id
    WHERE orders.order_status <> 'canceled'
    GROUP BY sellers.seller_id
),
HighRevenueSellers AS (
    SELECT *
    FROM SellerOrders
    WHERE total_revenue > 100000
)
SELECT *
FROM HighRevenueSellers
ORDER BY total_revenue DESC;
---Young seller (less than 3 month) with more than 30 products sales ---
WITH RecentOrders AS (
    SELECT *
    FROM orders
    WHERE order_purchase_timestamp >= DATE(
            (
                SELECT MAX(order_purchase_timestamp)
                FROM orders
            ),
            '-3 month'
        )
),
SellerSales AS (
    SELECT oi.seller_id,
        COUNT(oi.order_item_id) AS total_sales
    FROM RecentOrders o
        INNER JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY oi.seller_id
),
ActiveSellers AS (
    SELECT *
    FROM SellerSales
    WHERE total_sales > 30
)
SELECT *
FROM ActiveSellers
ORDER BY total_sales DESC;
--- 5 zip code with more than 30 reviews with the worth score on the last 12 month---
WITH RecentOrders AS (
    SELECT *
    FROM orders
    WHERE order_purchase_timestamp >= DATE(
            (
                SELECT MAX(order_purchase_timestamp)
                FROM orders
            ),
            '-12 month'
        )
),
ZipCodeReviews AS (
    SELECT customers.customer_zip_code_prefix AS zip_code,
        COUNT(order_reviews.review_score) AS review_count,
        AVG(order_reviews.review_score) AS avg_review_score
    FROM order_reviews
        INNER JOIN RecentOrders o ON order_reviews.order_id = o.order_id
        INNER JOIN customers ON o.customer_id = customers.customer_id
    GROUP BY customers.customer_zip_code_prefix
    HAVING COUNT(order_reviews.review_score) > 30
),
WorstZipCodes AS (
    SELECT *
    FROM ZipCodeReviews
    ORDER BY avg_review_score ASC
    LIMIT 5
)
SELECT *
FROM WorstZipCodes;