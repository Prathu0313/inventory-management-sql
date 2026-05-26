-- ============================================================
-- STORED PROCEDURES — Business Logic Encapsulation
-- ============================================================

USE inventory_db;

DELIMITER $$

-- ----------------------------------------------------------------
-- PROC 1: Record a Sale (validates stock before deducting)
-- ----------------------------------------------------------------
CREATE PROCEDURE sp_record_sale(
    IN  p_reference_no  VARCHAR(50),
    IN  p_customer_id   INT,
    IN  p_warehouse_id  INT,
    IN  p_product_id    INT,
    IN  p_quantity      INT,
    IN  p_unit_price    DECIMAL(10,2),
    IN  p_discount_pct  DECIMAL(5,2),
    OUT p_status        VARCHAR(100)
)
BEGIN
    DECLARE v_available INT DEFAULT 0;
    DECLARE v_txn_id    INT;

    -- Check available stock
    SELECT quantity INTO v_available
    FROM   inventory
    WHERE  product_id = p_product_id AND warehouse_id = p_warehouse_id;

    IF v_available IS NULL OR v_available < p_quantity THEN
        SET p_status = CONCAT('ERROR: Insufficient stock. Available: ', IFNULL(v_available, 0));
    ELSE
        -- Create transaction header
        INSERT INTO transactions (transaction_type, reference_no, customer_id, warehouse_id, transaction_date, status)
        VALUES ('sale', p_reference_no, p_customer_id, p_warehouse_id, CURDATE(), 'completed');

        SET v_txn_id = LAST_INSERT_ID();

        -- Add line item (trigger deducts stock automatically)
        INSERT INTO transaction_items (transaction_id, product_id, quantity, unit_price, discount_pct)
        VALUES (v_txn_id, p_product_id, p_quantity, p_unit_price, p_discount_pct);

        SET p_status = CONCAT('SUCCESS: Sale recorded. Transaction ID: ', v_txn_id);
    END IF;
END$$

-- ----------------------------------------------------------------
-- PROC 2: Generate Reorder Report
-- ----------------------------------------------------------------
CREATE PROCEDURE sp_reorder_report()
BEGIN
    SELECT
        sku,
        product_name,
        warehouse_name,
        current_qty,
        reorder_level,
        reorder_qty,
        supplier_name,
        supplier_email,
        alert_type
    FROM vw_reorder_alerts;
END$$

-- ----------------------------------------------------------------
-- PROC 3: Adjust Inventory (manual correction / return)
-- ----------------------------------------------------------------
CREATE PROCEDURE sp_adjust_inventory(
    IN  p_product_id   INT,
    IN  p_warehouse_id INT,
    IN  p_adjustment   INT      COMMENT 'Positive=add, Negative=subtract',
    IN  p_reason       TEXT,
    OUT p_status       VARCHAR(100)
)
BEGIN
    DECLARE v_current INT;

    SELECT quantity INTO v_current
    FROM   inventory
    WHERE  product_id = p_product_id AND warehouse_id = p_warehouse_id;

    IF v_current IS NULL THEN
        SET p_status = 'ERROR: Product-Warehouse combination not found.';
    ELSEIF (v_current + p_adjustment) < 0 THEN
        SET p_status = CONCAT('ERROR: Adjustment would result in negative stock. Current: ', v_current);
    ELSE
        UPDATE inventory
        SET    quantity = quantity + p_adjustment
        WHERE  product_id = p_product_id AND warehouse_id = p_warehouse_id;

        INSERT INTO transactions (transaction_type, warehouse_id, transaction_date, status, notes)
        VALUES ('adjustment', p_warehouse_id, CURDATE(), 'completed', p_reason);

        SET p_status = CONCAT('SUCCESS: Inventory adjusted. New quantity: ', v_current + p_adjustment);
    END IF;
END$$

DELIMITER ;
