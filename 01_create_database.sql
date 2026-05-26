-- ============================================================
-- INVENTORY MANAGEMENT SYSTEM
-- Database Schema | MySQL 8.0+
-- Author: Prathmesh
-- Description: Normalized relational database (3NF) with 10+
--              tables to track inventory, transactions, and
--              generate real-time analytics.
-- ============================================================

CREATE DATABASE IF NOT EXISTS inventory_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE inventory_db;

-- ============================================================
-- TABLE 1: CATEGORIES
-- ============================================================
CREATE TABLE categories (
    category_id   INT            AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100)   NOT NULL UNIQUE,
    description   TEXT,
    created_at    TIMESTAMP      DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- TABLE 2: SUPPLIERS
-- ============================================================
CREATE TABLE suppliers (
    supplier_id   INT            AUTO_INCREMENT PRIMARY KEY,
    supplier_name VARCHAR(150)   NOT NULL,
    contact_name  VARCHAR(100),
    email         VARCHAR(150)   UNIQUE,
    phone         VARCHAR(20),
    address       TEXT,
    city          VARCHAR(80),
    country       VARCHAR(80)    DEFAULT 'India',
    is_active     BOOLEAN        DEFAULT TRUE,
    created_at    TIMESTAMP      DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- TABLE 3: WAREHOUSES
-- ============================================================
CREATE TABLE warehouses (
    warehouse_id   INT           AUTO_INCREMENT PRIMARY KEY,
    warehouse_name VARCHAR(100)  NOT NULL,
    location       TEXT,
    city           VARCHAR(80),
    capacity       INT           COMMENT 'Max units storable',
    manager_name   VARCHAR(100),
    created_at     TIMESTAMP     DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- TABLE 4: PRODUCTS
-- ============================================================
CREATE TABLE products (
    product_id      INT            AUTO_INCREMENT PRIMARY KEY,
    sku             VARCHAR(50)    NOT NULL UNIQUE COMMENT 'Stock Keeping Unit',
    product_name    VARCHAR(200)   NOT NULL,
    category_id     INT            NOT NULL,
    supplier_id     INT            NOT NULL,
    unit_price      DECIMAL(10,2)  NOT NULL,
    cost_price      DECIMAL(10,2)  NOT NULL,
    unit_of_measure VARCHAR(30)    DEFAULT 'unit' COMMENT 'pcs, kg, litre, box',
    reorder_level   INT            DEFAULT 10     COMMENT 'Trigger restock below this',
    reorder_qty     INT            DEFAULT 50     COMMENT 'Default order quantity',
    is_active       BOOLEAN        DEFAULT TRUE,
    created_at      TIMESTAMP      DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP      DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(category_id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
);

-- ============================================================
-- TABLE 5: INVENTORY (Stock Levels per Warehouse)
-- ============================================================
CREATE TABLE inventory (
    inventory_id   INT    AUTO_INCREMENT PRIMARY KEY,
    product_id     INT    NOT NULL,
    warehouse_id   INT    NOT NULL,
    quantity       INT    NOT NULL DEFAULT 0,
    last_updated   TIMESTAMP      DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_product_warehouse (product_id, warehouse_id),
    FOREIGN KEY (product_id)  REFERENCES products(product_id),
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id)
);

-- ============================================================
-- TABLE 6: CUSTOMERS
-- ============================================================
CREATE TABLE customers (
    customer_id   INT            AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(150)   NOT NULL,
    email         VARCHAR(150)   UNIQUE,
    phone         VARCHAR(20),
    address       TEXT,
    city          VARCHAR(80),
    customer_type ENUM('retail','wholesale','online') DEFAULT 'retail',
    created_at    TIMESTAMP      DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- TABLE 7: TRANSACTIONS (Orders / Sales / Purchases)
-- ============================================================
CREATE TABLE transactions (
    transaction_id   INT    AUTO_INCREMENT PRIMARY KEY,
    transaction_type ENUM('purchase','sale','adjustment','return') NOT NULL,
    reference_no     VARCHAR(50)   UNIQUE COMMENT 'PO/Invoice number',
    customer_id      INT           NULL     COMMENT 'For sales only',
    supplier_id      INT           NULL     COMMENT 'For purchases only',
    warehouse_id     INT           NOT NULL,
    transaction_date DATE          NOT NULL,
    status           ENUM('pending','completed','cancelled') DEFAULT 'pending',
    notes            TEXT,
    created_by       VARCHAR(80)   DEFAULT 'system',
    created_at       TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id)  REFERENCES customers(customer_id),
    FOREIGN KEY (supplier_id)  REFERENCES suppliers(supplier_id),
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id)
);

-- ============================================================
-- TABLE 8: TRANSACTION_ITEMS (Line Items per Transaction)
-- ============================================================
CREATE TABLE transaction_items (
    item_id          INT            AUTO_INCREMENT PRIMARY KEY,
    transaction_id   INT            NOT NULL,
    product_id       INT            NOT NULL,
    quantity         INT            NOT NULL,
    unit_price       DECIMAL(10,2)  NOT NULL,
    discount_pct     DECIMAL(5,2)   DEFAULT 0.00,
    line_total       DECIMAL(12,2)  GENERATED ALWAYS AS
                     (quantity * unit_price * (1 - discount_pct/100)) STORED,
    FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id)     REFERENCES products(product_id)
);

-- ============================================================
-- TABLE 9: PURCHASE_ORDERS
-- ============================================================
CREATE TABLE purchase_orders (
    po_id          INT            AUTO_INCREMENT PRIMARY KEY,
    supplier_id    INT            NOT NULL,
    warehouse_id   INT            NOT NULL,
    po_date        DATE           NOT NULL,
    expected_date  DATE,
    status         ENUM('draft','sent','received','cancelled') DEFAULT 'draft',
    total_amount   DECIMAL(12,2)  DEFAULT 0.00,
    created_by     VARCHAR(80),
    created_at     TIMESTAMP      DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (supplier_id)  REFERENCES suppliers(supplier_id),
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id)
);

-- ============================================================
-- TABLE 10: STOCKOUT_ALERTS
-- ============================================================
CREATE TABLE stockout_alerts (
    alert_id     INT    AUTO_INCREMENT PRIMARY KEY,
    product_id   INT    NOT NULL,
    warehouse_id INT    NOT NULL,
    alert_type   ENUM('low_stock','stockout','overstock') NOT NULL,
    quantity_at_alert INT,
    reorder_level     INT,
    is_resolved   BOOLEAN   DEFAULT FALSE,
    alert_date    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_date TIMESTAMP NULL,
    FOREIGN KEY (product_id)  REFERENCES products(product_id),
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id)
);

-- ============================================================
-- TABLE 11: USERS (System Users / Staff)
-- ============================================================
CREATE TABLE users (
    user_id    INT           AUTO_INCREMENT PRIMARY KEY,
    username   VARCHAR(60)   NOT NULL UNIQUE,
    full_name  VARCHAR(150),
    email      VARCHAR(150)  UNIQUE,
    role       ENUM('admin','manager','staff','analyst') DEFAULT 'staff',
    is_active  BOOLEAN       DEFAULT TRUE,
    created_at TIMESTAMP     DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- TABLE 12: AUDIT_LOG (Track all critical changes)
-- ============================================================
CREATE TABLE audit_log (
    log_id       INT    AUTO_INCREMENT PRIMARY KEY,
    table_name   VARCHAR(80)  NOT NULL,
    record_id    INT          NOT NULL,
    action       ENUM('INSERT','UPDATE','DELETE') NOT NULL,
    changed_by   VARCHAR(80)  DEFAULT 'system',
    changed_at   TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    old_values   JSON,
    new_values   JSON
);
