-- Data Exploration and Quality Checks
--
-- Summarize dataset scope, order statuses, shipment-date availability, and order status by year.
-- SQL Server syntax; run against a compatible BikeStores database.

-- Dataset overview: order count and date range
-- Number of orders and the time period covered by the data
SELECT
    COUNT(*) AS total_orders,
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date
FROM sales.orders;

-- ------------------------------------------------------------------------

-- Order counts by status
SELECT
    order_status,
    COUNT(*) AS number_of_orders
FROM sales.orders
GROUP BY order_status
ORDER BY number_of_orders DESC;

-- ------------------------------------------------------------------------

-- Shipment-date availability by order status
SELECT
    order_status,
    COUNT(*) AS total_orders,
    SUM(
        CASE
            WHEN shipped_date IS NOT NULL THEN 1
            ELSE 0
        END
    ) AS shipped_orders,
    SUM(
        CASE
            WHEN shipped_date IS NULL THEN 1
            ELSE 0
        END
    ) AS orders_without_shipped_date
FROM sales.orders
GROUP BY order_status
ORDER BY order_status;

-- ------------------------------------------------------------------------

-- Orders by year and status
SELECT
    YEAR(order_date) AS order_year,
    order_status,
    COUNT(*) AS total_orders,
    SUM(
        CASE
            WHEN shipped_date IS NULL THEN 1
            ELSE 0
        END
    ) AS orders_without_shipped_date
FROM sales.orders
GROUP BY
    YEAR(order_date),
    order_status
ORDER BY
    order_year,
    order_status;

-- ------------------------------------------------------------------------
