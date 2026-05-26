-- ============================================================
-- VIEWS — Real-Time Analytics Dashboards
-- ============================================================

USE inventory_db;

-- ----------------------------------------------------------------
-- VIEW 1: Current Stock Summary (across all warehouses)
-- ----------------------------------------------------------------
CREATE OR REPLACE VIEW vw_stock_summary AS
SELECT
    p.product_id,
    p.sku,
    p.product_name,
    c.category_name,
    s.supplier_name,
    SUM(i.quantity)  AS total_qty,
    p.reorder_level,
    CASE
        WHEN SUM(i.quantity) = 0               THEN 'STOCKOUT'
        WHEN SUM(i.quantity) < p.reorder_level THEN 'LOW STOCK'
        WHEN SUM(i.quantity) > p.reorder_level * 5 THEN 'OVERSTOCK'
        ELSE 'OK'
    END AS stock_status,
    ROUND(SUM(i.quantity) * p.cost_price, 2) AS inventory_value
FROM       products p
JOIN       categories c  ON c.category_id  = p.category_id
JOIN       suppliers  s  ON s.supplier_id  = p.supplier_id
LEFT JOIN  inventory  i  ON i.product_id   = p.product_id
WHERE      p.is_active = TRUE
GROUP BY   p.product_id, p.sku, p.product_name, c.category_name,
           s.supplier_name, p.reorder_level, p.cost_price;

-- ----------------------------------------------------------------
-- VIEW 2: Low Stock / Stockout Alert View
-- ----------------------------------------------------------------
CREATE OR REPLACE VIEW vw_reorder_alerts AS
SELECT
    p.sku,
    p.product_name,
    w.warehouse_name,
    i.quantity          AS current_qty,
    p.reorder_level,
    p.reorder_qty,
    s.supplier_name,
    s.email             AS supplier_email,
    CASE WHEN i.quantity = 0 THEN 'STOCKOUT' ELSE 'LOW STOCK' END AS alert_type
FROM       inventory i
JOIN       products   p ON p.product_id   = i.product_id
JOIN       warehouses w ON w.warehouse_id = i.warehouse_id
JOIN       suppliers  s ON s.supplier_id  = p.supplier_id
WHERE      i.quantity <= p.reorder_level
ORDER BY   i.quantity ASC;

-- ----------------------------------------------------------------
-- VIEW 3: Sales Revenue by Product (monthly)
-- ----------------------------------------------------------------
CREATE OR REPLACE VIEW vw_monthly_sales AS
SELECT
    DATE_FORMAT(t.transaction_date, '%Y-%m')  AS sales_month,
    p.product_name,
    c.category_name,
    SUM(ti.quantity)                           AS units_sold,
    ROUND(SUM(ti.line_total), 2)               AS revenue,
    ROUND(SUM(ti.quantity * p.cost_price), 2)  AS cogs,
    ROUND(SUM(ti.line_total) - SUM(ti.quantity * p.cost_price), 2) AS gross_profit
FROM       transaction_items ti
JOIN       transactions t ON t.transaction_id = ti.transaction_id
JOIN       products     p ON p.product_id     = ti.product_id
JOIN       categories   c ON c.category_id    = p.category_id
WHERE      t.transaction_type = 'sale'
  AND      t.status           = 'completed'
GROUP BY   DATE_FORMAT(t.transaction_date, '%Y-%m'), p.product_name, c.category_name
ORDER BY   sales_month DESC, revenue DESC;

-- ----------------------------------------------------------------
-- VIEW 4: Warehouse Utilization Summary
-- ----------------------------------------------------------------
CREATE OR REPLACE VIEW vw_warehouse_utilization AS
SELECT
    w.warehouse_name,
    w.city,
    w.capacity,
    SUM(i.quantity)                               AS total_stock,
    ROUND(SUM(i.quantity) / w.capacity * 100, 1)  AS utilization_pct,
    COUNT(DISTINCT i.product_id)                   AS unique_products
FROM       warehouses w
LEFT JOIN  inventory  i ON i.warehouse_id = w.warehouse_id
GROUP BY   w.warehouse_id, w.warehouse_name, w.city, w.capacity;
