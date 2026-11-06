# SQL scripts

These SQL Server scripts reproduce the aggregate analyses in the project when run against a compatible BikeStores database with the `sales` and `production` schemas.

- `01_data_quality.sql` — dataset scope and shipment-date coverage checks.
- `02_sales_performance.sql` — category/product revenue and the shipped-order validation.
- `03_inventory_analysis.sql` — stock distribution and inventory/revenue comparison.
- `04_shipping_performance.sql` — overall, store, annual, coverage, and monthly shipping metrics.

The database itself is not included in this repository. The scripts use SQL Server syntax such as `TOP`, `YEAR()`, and `MONTH()`.
