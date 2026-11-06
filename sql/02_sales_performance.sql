-- Sales Performance Analysis
--
-- Calculate revenue by category, revenue share, top products, and revenue for shipped orders.
-- SQL Server syntax; run against a compatible BikeStores database.

-- Revenue, order count, and units by product category
SELECT
    c.category_name,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    SUM(oi.quantity) AS units_sold,
    CAST(
        SUM(
            oi.quantity * oi.list_price * (1 - oi.discount)
        ) AS DECIMAL(12, 2)
    ) AS revenue
FROM sales.order_items AS oi
JOIN production.products AS p
    ON oi.product_id = p.product_id
JOIN production.categories AS c
    ON p.category_id = c.category_id
GROUP BY c.category_name
ORDER BY revenue DESC;

-- ------------------------------------------------------------------------

-- Revenue share by product category
-- Revenue Share (%)
WITH category_revenue AS (
    SELECT
        c.category_name,
        SUM(
            oi.quantity * oi.list_price * (1 - oi.discount)
        ) AS revenue
    FROM sales.order_items AS oi
    JOIN production.products AS p
        ON oi.product_id = p.product_id
    JOIN production.categories AS c
        ON p.category_id = c.category_id
    GROUP BY c.category_name
)
SELECT
    category_name,
    CAST(revenue AS DECIMAL(12, 2)) AS revenue,
    CAST(
        100.0 * revenue / SUM(revenue) OVER ()
        AS DECIMAL(5, 2)
    ) AS revenue_share_pct
FROM category_revenue
ORDER BY revenue DESC;

-- ------------------------------------------------------------------------

-- Top 10 products by recorded order-item revenue, all statuses
SELECT TOP 10
    p.product_name,
    c.category_name,
    SUM(oi.quantity) AS units_sold,
    CAST(
        SUM(oi.quantity * oi.list_price * (1 - oi.discount))
        AS DECIMAL(12, 2)
    ) AS revenue
FROM sales.order_items AS oi
JOIN production.products AS p
    ON oi.product_id = p.product_id
JOIN production.categories AS c
    ON p.category_id = c.category_id
GROUP BY
    p.product_id,
    p.product_name,
    c.category_name
ORDER BY revenue DESC;

-- ------------------------------------------------------------------------

-- Top 10 products restricted to orders with a recorded shipment date
SELECT TOP 10
    p.product_name,
    c.category_name,
    SUM(oi.quantity) AS units_sold,
    CAST(
        SUM(
            oi.quantity * oi.list_price * (1 - oi.discount)
        )
        AS DECIMAL(12, 2)
    ) AS revenue
FROM sales.order_items AS oi
JOIN sales.orders AS o
    ON oi.order_id = o.order_id
JOIN production.products AS p
    ON oi.product_id = p.product_id
JOIN production.categories AS c
    ON p.category_id = c.category_id
WHERE o.shipped_date IS NOT NULL
GROUP BY
    p.product_id,
    p.product_name,
    c.category_name
ORDER BY revenue DESC;

-- ------------------------------------------------------------------------

-- Category revenue restricted to orders with a recorded shipment date
SELECT
    c.category_name,
    COUNT(DISTINCT o.order_id) AS shipped_orders,
    SUM(oi.quantity) AS units_sold,
    CAST(
        SUM(
            oi.quantity * oi.list_price * (1 - oi.discount)
        ) AS DECIMAL(12, 2)
    ) AS revenue
FROM sales.orders AS o
JOIN sales.order_items AS oi
    ON o.order_id = oi.order_id
JOIN production.products AS p
    ON oi.product_id = p.product_id
JOIN production.categories AS c
    ON p.category_id = c.category_id
WHERE o.shipped_date IS NOT NULL
GROUP BY c.category_name
ORDER BY revenue DESC;

-- ------------------------------------------------------------------------
