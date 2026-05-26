-- ============================================================
-- ANALYTICAL QUERIES — Real-Time Inventory Analytics
-- Run these in MySQL Workbench for insights
-- ============================================================

USE inventory_db;

-- ----------------------------------------------------------------
-- Q1: Full Stock Dashboard (all products, status, value)
-- ----------------------------------------------------------------
SELECT * FROM vw_stock_summary ORDER BY stock_status, total_qty ASC;


-- ----------------------------------------------------------------
-- Q2: Products Needing Immediate Reorder
-- ----------------------------------------------------------------
SELECT * FROM vw_reorder_alerts;


-- ----------------------------------------------------------------
-- Q3: Monthly Revenue & Profit Trend
-- ----------------------------------------------------------------
SELECT * FROM vw_monthly_sales;


-- ----------------------------------------------------------------
-- Q4: Top 5 Best-Selling Products (by revenue)
-- ----------------------------------------------------------------
SELECT
    p.product_name,
    c.category_name,
    SUM(ti.quantity)             AS total_units_sold,
    ROUND(SUM(ti.line_total), 2) AS total_revenue
FROM transaction_items ti
JOIN transactions t ON t.transaction_id = ti.transaction_id
JOIN products     p ON p.product_id     = ti.product_id
JOIN categories   c ON c.category_id    = p.category_id
WHERE t.transaction_type = 'sale' AND t.status = 'completed'
GROUP BY p.product_id, p.product_name, c.category_name
ORDER BY total_revenue DESC
LIMIT 5;


-- ----------------------------------------------------------------
-- Q5: Stockout Alert History (unresolved)
-- ----------------------------------------------------------------
SELECT
    sa.alert_date,
    p.sku,
    p.product_name,
    w.warehouse_name,
    sa.alert_type,
    sa.quantity_at_alert,
    sa.reorder_level
FROM stockout_alerts sa
JOIN products   p ON p.product_id   = sa.product_id
JOIN warehouses w ON w.warehouse_id = sa.warehouse_id
WHERE sa.is_resolved = FALSE
ORDER BY sa.alert_date DESC;


-- ----------------------------------------------------------------
-- Q6: Warehouse Utilization
-- ----------------------------------------------------------------
SELECT * FROM vw_warehouse_utilization;


-- ----------------------------------------------------------------
-- Q7: Total Inventory Value by Category
-- ----------------------------------------------------------------
SELECT
    c.category_name,
    COUNT(DISTINCT p.product_id)                  AS num_products,
    SUM(i.quantity)                                AS total_units,
    ROUND(SUM(i.quantity * p.cost_price), 2)       AS inventory_value
FROM       categories c
JOIN       products   p ON p.category_id  = c.category_id
LEFT JOIN  inventory  i ON i.product_id   = p.product_id
GROUP BY   c.category_id, c.category_name
ORDER BY   inventory_value DESC;


-- ----------------------------------------------------------------
-- Q8: Supplier-wise Purchase Summary
-- ----------------------------------------------------------------
SELECT
    s.supplier_name,
    COUNT(DISTINCT t.transaction_id)   AS total_purchases,
    SUM(ti.quantity)                   AS total_units_purchased,
    ROUND(SUM(ti.line_total), 2)       AS total_spent
FROM       suppliers s
JOIN       products   p  ON p.supplier_id   = s.supplier_id
JOIN       transaction_items ti ON ti.product_id = p.product_id
JOIN       transactions t ON t.transaction_id = ti.transaction_id
WHERE      t.transaction_type = 'purchase'
GROUP BY   s.supplier_id, s.supplier_name
ORDER BY   total_spent DESC;


-- ----------------------------------------------------------------
-- Q9: Record a Sale using Stored Procedure
-- ----------------------------------------------------------------
CALL sp_record_sale(
    'INV-2024-005',   -- reference number
    3,                -- customer_id
    1,                -- warehouse_id
    9,                -- product_id (Stainless Steel Bottle)
    20,               -- quantity
    349.00,           -- unit_price
    0,                -- discount %
    @result
);
SELECT @result AS sale_result;


-- ----------------------------------------------------------------
-- Q10: Stockout Reduction Rate (KPI query)
-- Used to track the 15% reduction in stockout incidents
-- ----------------------------------------------------------------
SELECT
    DATE_FORMAT(alert_date, '%Y-%m')   AS month,
    COUNT(*)                           AS total_alerts,
    SUM(alert_type = 'stockout')       AS stockouts,
    SUM(alert_type = 'low_stock')      AS low_stock_alerts,
    ROUND(SUM(alert_type = 'stockout') / COUNT(*) * 100, 1) AS stockout_pct
FROM stockout_alerts
GROUP BY DATE_FORMAT(alert_date, '%Y-%m')
ORDER BY month;
