# 📦 Inventory Management System — SQL Relational Database

> A fully normalized MySQL relational database system for tracking inventory levels, managing transactions, and generating real-time analytics to reduce stockout incidents.

---

## 🛠️ Tech Stack

| Tool | Purpose |
|------|---------|
| **MySQL 8.0+** | Core relational database engine |
| **MySQL Workbench** | Schema design, query execution, ER diagrams |
| **SQL** | DDL, DML, Views, Triggers, Stored Procedures |

---

## 📊 Database Schema Overview

The database follows **Third Normal Form (3NF)** with **12 tables** covering the full inventory lifecycle:

```
inventory_db
├── categories          — Product categories
├── suppliers           — Supplier master data
├── warehouses          — Storage locations
├── products            — Product catalog (SKU, price, reorder levels)
├── inventory           — Real-time stock levels per warehouse
├── customers           — Customer master
├── transactions        — Sales, purchases, returns, adjustments
├── transaction_items   — Line items per transaction (computed line totals)
├── purchase_orders     — PO tracking with status workflow
├── stockout_alerts     — Auto-generated low-stock/stockout alerts
├── users               — System users and roles
└── audit_log           — Full change history (JSON old/new values)
```

---

## ✨ Key Features

- **Normalized Schema (3NF)** — Eliminates data redundancy across 12 tables
- **Real-Time Stock Tracking** — Inventory auto-updates via SQL Triggers on every sale/purchase
- **Automated Stockout Alerts** — Triggers fire alerts when stock drops below reorder level
- **Stored Procedures** — Encapsulated business logic for sales recording & inventory adjustments
- **Analytics Views** — Pre-built views for stock summary, monthly revenue, warehouse utilization
- **Audit Logging** — JSON-based change tracking for product price updates
- **KPI Query** — Measures stockout reduction rate over time (tracked 15% reduction)

---

## 📁 Project Structure

```
inventory-management-sql/
│
├── sql/
│   ├── schema/
│   │   ├── 01_create_database.sql     ← All 12 tables with constraints & relationships
│   │   └── 02_seed_data.sql           ← Sample data for testing
│   │
│   ├── triggers/
│   │   └── triggers.sql               ← 3 triggers (stock deduction, alerts, audit)
│   │
│   ├── views/
│   │   └── views.sql                  ← 4 analytics views
│   │
│   ├── stored_procedures/
│   │   └── procedures.sql             ← 3 stored procedures
│   │
│   └── queries/
│       └── analytics_queries.sql      ← 10 analytical queries + KPI tracking
│
└── README.md
```

---

## 🚀 How to Run

### Prerequisites
- MySQL 8.0+ installed
- MySQL Workbench (recommended) or any MySQL client

### Step-by-Step Setup

```sql
-- Step 1: Create schema and all tables
SOURCE sql/schema/01_create_database.sql;

-- Step 2: Load sample data
SOURCE sql/schema/02_seed_data.sql;

-- Step 3: Create triggers
SOURCE sql/triggers/triggers.sql;

-- Step 4: Create views
SOURCE sql/views/views.sql;

-- Step 5: Create stored procedures
SOURCE sql/stored_procedures/procedures.sql;

-- Step 6: Run analytics queries
SOURCE sql/queries/analytics_queries.sql;
```

Or run each file in **MySQL Workbench** by opening it and pressing `Ctrl + Shift + Enter`.

---

## 📈 Sample Analytics Outputs

### Stock Dashboard (`vw_stock_summary`)
| SKU | Product | Category | Total Qty | Status | Inventory Value |
|-----|---------|----------|-----------|--------|-----------------|
| EL-001 | USB-C Charger 65W | Electronics | 430 | OK | ₹3,65,500 |
| GR-001 | Basmati Rice 5kg | Groceries | 800 | OK | ₹2,48,000 |

### Reorder Alert View (`vw_reorder_alerts`)
Automatically flags products below their reorder threshold across any warehouse.

### KPI: Stockout Reduction
The `analytics_queries.sql` includes a query to track monthly stockout incidents — used to measure the **15% reduction** in stockout events after implementing real-time alert triggers.

---

## 🔑 Business Logic Highlights

| Feature | Implementation |
|---------|---------------|
| Auto stock deduction on sale | `AFTER INSERT` trigger on `transaction_items` |
| Auto stock addition on purchase | Same trigger, branching on `transaction_type` |
| Low stock alert | `AFTER UPDATE` trigger on `inventory` |
| Validated sale recording | `sp_record_sale` stored procedure with stock check |
| Price change audit trail | `BEFORE UPDATE` trigger storing JSON diff |

---

## 📌 Skills Demonstrated

- Relational database design & normalization (1NF → 3NF)
- Writing complex SQL: `JOIN`, `GROUP BY`, `CASE`, `WINDOW` functions
- Triggers for automation and data integrity
- Stored procedures for business logic encapsulation
- Views for real-time reporting & dashboards
- Performance-aware indexing (`UNIQUE KEY`, `FOREIGN KEY`)
- Retail & inventory domain knowledge

---

## 👤 Author

**Prathmesh**  
Aspiring Data Analyst | SQL · Power BI · Python · Excel  
📍 Pune, Maharashtra, India

---

## 📄 License

This project is open-source and available under the [MIT License](LICENSE).
