---ORDERS DELIVERY MORE THAN 3 DAYS DELAY---
SELECT *
FROM orders
WHERE order_purchase_timestamp >= DATE(
        (
            SELECT MAX(order_purchase_timestamp)
            FROM orders
        ),
        '-3 month'
    )
    AND order_status <> 'canceled'
    AND JULIANDAY(order_delivered_customer_date) - JULIANDAY(order_estimated_delivery_date) > 3;
---Sellers with more than 100K real on delivery orders---
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
HAVING SUM(order_pymts.payment_value) > 100000
ORDER BY total_revenue DESC;
--- 3- Qui sont les nouveaux vendeurs (moins de 3 mois d'ancienneté) qui sont déjà très engagés avec la plateforme (ayant déjà vendu plus de 30 produits) ?---
SELECT *
FROM orders --- 3- Qui sont les nouveaux vendeurs (moins de 3 mois d'ancienneté) qui sont déjà très engagés avec la plateforme (ayant déjà vendu plus de 30 produits) ?---
SELECT *
FROM order_items --- 3- Qui sont les nouveaux vendeurs (moins de 3 mois d'ancienneté) qui sont déjà très engagés avec la plateforme (ayant déjà vendu plus de 30 produits) ?---
    ---Young seller (less than 3 month) with more than 30 products sales ---
    --- 4- Quels sont les 5 codes postaux, enregistrant plus de 30 reviews, avec le pire review score moyen sur les 12 derniers mois ?----
    --- 5 zip code with more than 30 reviews with the worth score on the last 12 month---