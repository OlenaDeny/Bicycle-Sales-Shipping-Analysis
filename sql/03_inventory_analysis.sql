-- Inventory Analysis
--
-- Summarize stock by category and compare inventory share with shipped-revenue share.
-- SQL Server syntax; run against a compatible BikeStores database.

-- Inventory units and product counts by category
SELECT
    c.category_name,
    COUNT(DISTINCT p.product_id) AS number_of_products,
    SUM(st.quantity) AS total_units_in_stock,
    COUNT(DISTINCT st.store_id) AS number_of_stores
FROM production.stocks AS st
JOIN production.products AS p
    ON st.product_id = p.product_id
JOIN production.categories AS c
    ON p.category_id = c.category_id
GROUP BY c.category_name
ORDER BY total_units_in_stock DESC;

-- ------------------------------------------------------------------------

-- Inventory share versus shipped-revenue share
WITH inventory AS (
    SELECT
        p.category_id,
        SUM(st.quantity) AS units_in_stock
    FROM production.stocks AS st
    JOIN production.products AS p
        ON st.product_id = p.product_id
    GROUP BY p.category_id
),
shipped_sales AS (
    SELECT
        p.category_id,
        SUM(
            oi.quantity * oi.list_price * (1 - oi.discount)
        ) AS shipped_revenue
    FROM sales.orders AS o
    JOIN sales.order_items AS oi
        ON o.order_id = oi.order_id
    JOIN production.products AS p
        ON oi.product_id = p.product_id
    WHERE o.shipped_date IS NOT NULL
    GROUP BY p.category_id
),
category_metrics AS (
    SELECT
        c.category_name,
        i.units_in_stock,
        s.shipped_revenue
    FROM production.categories AS c
    JOIN inventory AS i
        ON c.category_id = i.category_id
    JOIN shipped_sales AS s
        ON c.category_id = s.category_id
)
SELECT
    category_name,
    units_in_stock,
    CAST(
        100.0 * units_in_stock
        / SUM(units_in_stock) OVER ()
        AS DECIMAL(5,2)
    ) AS inventory_share_pct,
    CAST(shipped_revenue AS DECIMAL(12,2)) AS shipped_revenue,
    CAST(
        100.0 * shipped_revenue
        / SUM(shipped_revenue) OVER ()
        AS DECIMAL(5,2)
    ) AS revenue_share_pct
FROM category_metrics
ORDER BY revenue_share_pct DESC;

-- ------------------------------------------------------------------------
