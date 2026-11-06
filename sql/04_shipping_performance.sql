-- Shipping Performance Analysis
--
-- Measure late shipments by overall status, store, year, data coverage, and order month.
-- SQL Server syntax; run against a compatible BikeStores database.

-- Overall shipping performance
SELECT
    COUNT(*) AS shipped_orders,
    SUM(
        CASE
            WHEN shipped_date > required_date THEN 1
            ELSE 0
        END
    ) AS late_shipped_orders,
    SUM(
        CASE
            WHEN shipped_date <= required_date THEN 1
            ELSE 0
        END
    ) AS on_time_shipped_orders,
    CAST(
        100.0 * SUM(
            CASE
                WHEN shipped_date > required_date THEN 1
                ELSE 0
            END
        ) / COUNT(*)
        AS DECIMAL(5,2)
    ) AS late_shipment_rate_pct
FROM sales.orders
WHERE shipped_date IS NOT NULL;

-- ------------------------------------------------------------------------

-- Overall on-time versus late split
WITH shipped_orders AS (
    SELECT
        CASE
            WHEN shipped_date > required_date THEN 'Late'
            ELSE 'On time'
        END AS shipping_status
    FROM sales.orders
    WHERE shipped_date IS NOT NULL
)
SELECT
    shipping_status,
    COUNT(*) AS order_count,
    CAST(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER ()
        AS DECIMAL(5, 2)
    ) AS percentage
FROM shipped_orders
GROUP BY shipping_status
ORDER BY
    CASE
        WHEN shipping_status = 'On time' THEN 1
        ELSE 2
    END;

-- ------------------------------------------------------------------------

-- Shipping performance by store
SELECT
    s.store_name,
    COUNT(*) AS shipped_orders,
    SUM(
        CASE
            WHEN o.shipped_date > o.required_date THEN 1
            ELSE 0
        END
    ) AS late_shipped_orders,
    CAST(
        100.0 * SUM(
            CASE
                WHEN o.shipped_date > o.required_date THEN 1
                ELSE 0
            END
        ) / COUNT(*)
        AS DECIMAL(5,2)
    ) AS late_shipment_rate_pct
FROM sales.orders AS o
JOIN sales.stores AS s
    ON o.store_id = s.store_id
WHERE o.shipped_date IS NOT NULL
GROUP BY s.store_name
ORDER BY late_shipment_rate_pct DESC;

-- ------------------------------------------------------------------------

-- Annual shipping performance grouped by order year
SELECT
    YEAR(o.order_date) AS order_year,
    COUNT(*) AS shipped_orders,
    SUM(
        CASE
            WHEN o.shipped_date > o.required_date THEN 1
            ELSE 0
        END
    ) AS late_shipped_orders,
    CAST(
        100.0 * SUM(
            CASE
                WHEN o.shipped_date > o.required_date THEN 1
                ELSE 0
            END
        ) / COUNT(*)
        AS DECIMAL(5,2)
    ) AS late_shipment_rate_pct
FROM sales.orders AS o
WHERE o.shipped_date IS NOT NULL
GROUP BY YEAR(o.order_date)
ORDER BY order_year;

-- ------------------------------------------------------------------------

-- Shipping-date coverage grouped by order year
SELECT
    YEAR(order_date) AS order_year,
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
    ) AS orders_without_shipped_date,
    CAST(
        100.0 * SUM(
            CASE
                WHEN shipped_date IS NOT NULL THEN 1
                ELSE 0
            END
        ) / COUNT(*)
        AS DECIMAL(5,2)
    ) AS shipping_date_coverage_pct
FROM sales.orders
GROUP BY YEAR(order_date)
ORDER BY order_year;

-- ------------------------------------------------------------------------

-- Monthly shipping performance grouped by order year and month
SELECT
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month,
    COUNT(*) AS shipped_orders,
    SUM(
        CASE
            WHEN shipped_date > required_date THEN 1
            ELSE 0
        END
    ) AS late_shipped_orders,
    CAST(
        100.0 * SUM(
            CASE
                WHEN shipped_date > required_date THEN 1
                ELSE 0
            END
        ) / COUNT(*)
        AS DECIMAL(5,2)
    ) AS late_shipment_rate_pct
FROM sales.orders
WHERE shipped_date IS NOT NULL
GROUP BY
    YEAR(order_date),
    MONTH(order_date)
ORDER BY
    order_year,
    order_month;

-- ------------------------------------------------------------------------
