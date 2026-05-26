-- ============================================================
-- TRIGGERS — Automate inventory updates & alerts
-- ============================================================

USE inventory_db;

DELIMITER $$

-- ----------------------------------------------------------------
-- TRIGGER 1: After a SALE is completed → deduct stock
-- ----------------------------------------------------------------
CREATE TRIGGER trg_after_sale_item_insert
AFTER INSERT ON transaction_items
FOR EACH ROW
BEGIN
    DECLARE v_type   VARCHAR(20);
    DECLARE v_wh_id  INT;

    SELECT t.transaction_type, t.warehouse_id
    INTO   v_type, v_wh_id
    FROM   transactions t
    WHERE  t.transaction_id = NEW.transaction_id;

    IF v_type = 'sale' THEN
        UPDATE inventory
        SET    quantity = quantity - NEW.quantity
        WHERE  product_id   = NEW.product_id
          AND  warehouse_id = v_wh_id;
    ELSEIF v_type = 'purchase' THEN
        -- Upsert: add stock if row exists, else create it
        INSERT INTO inventory (product_id, warehouse_id, quantity)
        VALUES (NEW.product_id, v_wh_id, NEW.quantity)
        ON DUPLICATE KEY UPDATE quantity = quantity + NEW.quantity;
    END IF;
END$$

-- ----------------------------------------------------------------
-- TRIGGER 2: After inventory update → check stockout alert
-- ----------------------------------------------------------------
CREATE TRIGGER trg_check_stock_alert
AFTER UPDATE ON inventory
FOR EACH ROW
BEGIN
    DECLARE v_reorder INT;

    SELECT reorder_level INTO v_reorder
    FROM   products
    WHERE  product_id = NEW.product_id;

    -- Stockout
    IF NEW.quantity = 0 THEN
        INSERT INTO stockout_alerts (product_id, warehouse_id, alert_type, quantity_at_alert, reorder_level)
        VALUES (NEW.product_id, NEW.warehouse_id, 'stockout', NEW.quantity, v_reorder);

    -- Low Stock (below reorder level but not zero)
    ELSEIF NEW.quantity < v_reorder AND NEW.quantity > 0 THEN
        INSERT INTO stockout_alerts (product_id, warehouse_id, alert_type, quantity_at_alert, reorder_level)
        VALUES (NEW.product_id, NEW.warehouse_id, 'low_stock', NEW.quantity, v_reorder);
    END IF;
END$$

-- ----------------------------------------------------------------
-- TRIGGER 3: Audit log on product price update
-- ----------------------------------------------------------------
CREATE TRIGGER trg_audit_product_update
BEFORE UPDATE ON products
FOR EACH ROW
BEGIN
    IF OLD.unit_price <> NEW.unit_price OR OLD.cost_price <> NEW.cost_price THEN
        INSERT INTO audit_log (table_name, record_id, action, old_values, new_values)
        VALUES (
            'products',
            OLD.product_id,
            'UPDATE',
            JSON_OBJECT('unit_price', OLD.unit_price, 'cost_price', OLD.cost_price),
            JSON_OBJECT('unit_price', NEW.unit_price, 'cost_price', NEW.cost_price)
        );
    END IF;
END$$

DELIMITER ;
