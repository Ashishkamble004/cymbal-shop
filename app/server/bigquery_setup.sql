-- =====================================================
-- Tata Neu Simplified BigQuery Setup
-- =====================================================
-- Run this script to set up simplified customer and order tables
-- =====================================================

-- Delete existing tables (run these manually if tables exist)
DROP TABLE IF EXISTS `general-ak.tata_neu_orders.customers`;
DROP TABLE IF EXISTS `general-ak.tata_neu_orders.orders`;
DROP TABLE IF EXISTS `general-ak.tata_neu_orders.neu_cards`;
DROP TABLE IF EXISTS `general-ak.tata_neu_orders.card_transactions`;
DROP TABLE IF EXISTS `general-ak.tata_neu_orders.order_items`;
DROP TABLE IF EXISTS `general-ak.tata_neu_orders.card_statements`;
DROP TABLE IF EXISTS `general-ak.tata_neu_orders.support_tickets`;
DROP TABLE IF EXISTS `general-ak.tata_neu_orders.neucoins_transactions`;

-- =====================================================
-- 1. CUSTOMERS TABLE (Simple - 3 customers)
-- =====================================================
CREATE OR REPLACE TABLE `general-ak.tata_neu_orders.customers` (
    customer_id STRING NOT NULL,
    name STRING NOT NULL,
    email STRING,
    phone STRING,
    address STRING,
    city STRING,
    neucard_number STRING,
    neucard_type STRING,  -- 'neu_infinity', 'neu_plus', 'neu_hipcard'
    neucoins_balance INT64 DEFAULT 0,
    created_date DATE
);

-- Insert 3 customers
INSERT INTO `general-ak.tata_neu_orders.customers` VALUES
('CUST001', 'Rajesh Sharma', 'rajesh.sharma@email.com', '+91-9876543210', '42 MG Road, Koramangala', 'Bangalore', '4532-XXXX-XXXX-1234', 'neu_infinity', 15000, '2024-01-15'),
('CUST002', 'Priya Patel', 'priya.patel@email.com', '+91-9988776655', '15 Linking Road, Bandra', 'Mumbai', '4916-XXXX-XXXX-5678', 'neu_plus', 8500, '2024-03-20'),
('CUST003', 'Amit Singh', 'amit.singh@email.com', '+91-8877665544', '78 Civil Lines', 'Delhi', '5412-XXXX-XXXX-9012', 'neu_hipcard', 3200, '2024-06-10');

-- =====================================================
-- 2. ORDERS TABLE (9 orders - 3 per customer)
-- =====================================================
CREATE OR REPLACE TABLE `general-ak.tata_neu_orders.orders` (
    order_id STRING NOT NULL,
    customer_id STRING NOT NULL,
    order_date DATE,
    product_name STRING,
    brand STRING,  -- 'bigbasket', 'croma', 'westside', 'tanishq', 'tata_1mg'
    amount NUMERIC,
    order_status STRING,  -- 'delivered', 'shipped', 'processing', 'cancelled', 'return_requested'
    delivery_date DATE,
    tracking_number STRING,
    neucoins_earned INT64,
    payment_method STRING  -- 'neucard', 'upi', 'cod'
);

-- Insert 9 orders (3 per customer)
-- NeuCoins rates (Infinity Card on Tata Neu App): 
-- 10% for NeuCard payment (5% Card + 5% App)
-- 5% for other payments (App only)
INSERT INTO `general-ak.tata_neu_orders.orders` VALUES
-- Rajesh Sharma (CUST001) orders
('ORD001', 'CUST001', '2026-01-15', 'Samsung 55" QLED TV', 'croma', 45000.00, 'delivered', '2026-01-18', 'CR123456789', 4500, 'neucard'),       -- 10% of 45000
('ORD002', 'CUST001', '2026-01-18', 'Monthly Groceries', 'bigbasket', 3500.00, 'shipped', NULL, 'BB987654321', 350, 'neucard'),                 -- 10% of 3500
('ORD003', 'CUST001', '2026-01-20', 'Winter Jacket', 'westside', 2800.00, 'processing', NULL, NULL, 140, 'upi'),                                -- 5% of 2800

-- Priya Patel (CUST002) orders
('ORD004', 'CUST002', '2026-01-10', 'Gold Necklace', 'tanishq', 85000.00, 'delivered', '2026-01-14', 'TQ111222333', 8500, 'neucard'),           -- 10% of 85000
('ORD005', 'CUST002', '2026-01-16', 'Vitamin Supplements', 'tata_1mg', 1200.00, 'delivered', '2026-01-18', 'MG444555666', 60, 'upi'),           -- 5% of 1200
('ORD006', 'CUST002', '2026-01-21', 'Designer Kurti Set', 'westside', 4500.00, 'shipped', NULL, 'WS789456123', 450, 'neucard'),                 -- 10% of 4500

-- Amit Singh (CUST003) orders
('ORD007', 'CUST003', '2026-01-12', 'Wireless Earbuds', 'croma', 8000.00, 'delivered', '2026-01-15', 'CR555666777', 800, 'neucard'),            -- 10% of 8000
('ORD008', 'CUST003', '2026-01-19', 'Organic Groceries', 'bigbasket', 2200.00, 'cancelled', NULL, NULL, 0, 'cod'),                              -- cancelled = 0
('ORD009', 'CUST003', '2026-01-22', 'Running Shoes', 'westside', 3800.00, 'processing', NULL, NULL, 190, 'upi');                                -- 5% of 3800

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================
-- SELECT * FROM `general-ak.tata_neu_orders.customers`;
-- SELECT * FROM `general-ak.tata_neu_orders.orders`;

-- Get customer with orders:
-- SELECT c.name, c.neucoins_balance, o.order_id, o.product_name, o.order_status, o.neucoins_earned
-- FROM `general-ak.tata_neu_orders.customers` c
-- JOIN `general-ak.tata_neu_orders.orders` o ON c.customer_id = o.customer_id
-- ORDER BY c.customer_id, o.order_date DESC;
