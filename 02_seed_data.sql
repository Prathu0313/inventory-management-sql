-- ============================================================
-- SAMPLE DATA — Seed file for testing & demo
-- Run after: 01_create_database.sql
-- ============================================================

USE inventory_db;

-- Categories
INSERT INTO categories (category_name, description) VALUES
('Electronics',    'Consumer electronics and accessories'),
('Groceries',      'Food and beverage items'),
('Apparel',        'Clothing and fashion items'),
('Home & Kitchen', 'Household and kitchen products'),
('Stationery',     'Office and school supplies');

-- Suppliers
INSERT INTO suppliers (supplier_name, contact_name, email, phone, city) VALUES
('TechSource Pvt Ltd',   'Arjun Mehta',   'arjun@techsource.in',  '9876543210', 'Mumbai'),
('FreshFarm Supplies',   'Priya Nair',    'priya@freshfarm.in',   '9845001122', 'Pune'),
('FashionHub India',     'Rohan Shah',    'rohan@fashionhub.in',  '9823334455', 'Surat'),
('HomeWorld Trading',    'Sneha Joshi',   'sneha@homeworld.in',   '9811122233', 'Delhi'),
('OfficeDesk Co.',       'Vikram Singh',  'vikram@officedesk.in', '9800112233', 'Bangalore');

-- Warehouses
INSERT INTO warehouses (warehouse_name, location, city, capacity, manager_name) VALUES
('Warehouse A - Pune',      'Plot 12, Chakan MIDC, Pune',       'Pune',      50000, 'Amit Kulkarni'),
('Warehouse B - Mumbai',    'Unit 5, Bhiwandi Logistics Park',  'Mumbai',    80000, 'Deepa Rao'),
('Warehouse C - Bangalore', 'Sy No 34, Hoskote Industrial Area','Bangalore', 60000, 'Suresh Iyer');

-- Products
INSERT INTO products (sku, product_name, category_id, supplier_id, unit_price, cost_price, unit_of_measure, reorder_level, reorder_qty) VALUES
('EL-001', 'USB-C Fast Charger 65W',      1, 1, 1299.00,  850.00, 'pcs',  20, 100),
('EL-002', 'Wireless Bluetooth Headset',  1, 1, 2499.00, 1600.00, 'pcs',  15,  50),
('EL-003', 'Laptop Stand Adjustable',     1, 1,  899.00,  550.00, 'pcs',  10,  60),
('GR-001', 'Basmati Rice 5kg',            2, 2,  450.00,  310.00, 'bag',  50, 200),
('GR-002', 'Cold Pressed Sunflower Oil 1L',2,2,  180.00,  120.00, 'litre',40, 150),
('AP-001', 'Cotton Formal Shirt - M',     3, 3,  799.00,  450.00, 'pcs',  25, 100),
('AP-002', 'Denim Jeans - 32',            3, 3, 1499.00,  900.00, 'pcs',  20,  80),
('HK-001', 'Non-Stick Kadai 24cm',        4, 4,  649.00,  400.00, 'pcs',  15,  60),
('HK-002', 'Stainless Steel Water Bottle',4, 4,  349.00,  200.00, 'pcs',  30, 120),
('ST-001', 'A4 Copier Paper 500 Sheets',  5, 5,  280.00,  190.00, 'ream', 40, 200),
('ST-002', 'Gel Pen Set 10 pcs',          5, 5,   99.00,   55.00, 'set',  50, 300);

-- Inventory (Stock levels per warehouse)
INSERT INTO inventory (product_id, warehouse_id, quantity) VALUES
(1,  1, 150), (1,  2, 200), (1,  3, 80),
(2,  1,  60), (2,  2, 120),
(3,  1,  90), (3,  3, 110),
(4,  1, 500), (4,  2, 300),
(5,  1, 200), (5,  2, 180),
(6,  1, 250), (6,  3, 150),
(7,  1, 180), (7,  2, 120),
(8,  2, 140), (8,  3,  90),
(9,  1, 300), (9,  2, 250),
(10, 1, 400), (10, 2, 350),
(11, 1, 600), (11, 3, 400);

-- Customers
INSERT INTO customers (customer_name, email, phone, city, customer_type) VALUES
('Reliance Retail Ltd',    'orders@relianceretail.com', '9000001111', 'Mumbai',    'wholesale'),
('BigBasket Online',       'supply@bigbasket.com',      '9000002222', 'Bangalore', 'online'),
('Shoppers Stop Pune',     'buyer@shoppersstop.com',    '9000003333', 'Pune',      'retail'),
('D-Mart Chakan',          'purchase@dmart.in',         '9000004444', 'Pune',      'wholesale'),
('Ananya Kapoor',          'ananya.k@email.com',        '9812345678', 'Mumbai',    'retail');

-- Users
INSERT INTO users (username, full_name, email, role) VALUES
('prathmesh_admin', 'Prathmesh',       'prathmesh@company.com', 'admin'),
('mgr_pune',        'Amit Kulkarni',   'amit.k@company.com',    'manager'),
('analyst_01',      'Divya Sharma',    'divya.s@company.com',   'analyst'),
('staff_01',        'Ravi Tiwari',     'ravi.t@company.com',    'staff');

-- Sample Transactions (Sales)
INSERT INTO transactions (transaction_type, reference_no, customer_id, warehouse_id, transaction_date, status) VALUES
('sale', 'INV-2024-001', 1, 2, '2024-11-05', 'completed'),
('sale', 'INV-2024-002', 4, 1, '2024-11-10', 'completed'),
('sale', 'INV-2024-003', 2, 3, '2024-11-15', 'completed'),
('sale', 'INV-2024-004', 3, 1, '2024-11-20', 'completed'),
('purchase', 'PO-2024-001', NULL, 1, '2024-11-01', 'completed');

-- Transaction Items
INSERT INTO transaction_items (transaction_id, product_id, quantity, unit_price, discount_pct) VALUES
(1, 1, 50, 1299.00, 5.00),
(1, 2, 20, 2499.00, 3.00),
(2, 4, 100, 450.00, 2.00),
(2, 5, 80,  180.00, 0.00),
(3, 9, 60,  349.00, 0.00),
(4, 6, 30,  799.00, 5.00),
(4, 7, 25, 1499.00, 5.00),
(5, 1, 100, 850.00, 0.00);
