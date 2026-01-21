-- =====================================================
-- Tata Neu Customer Order Management Dataset Setup Script for BigQuery
-- =====================================================
-- Run this script in BigQuery to create the order management tables
-- and populate them with sample data for Tata Neu platform
-- =====================================================

-- Create the dataset (run manually in BigQuery Console)
-- CREATE SCHEMA IF NOT EXISTS `general-ak.tata_neu_orders`;

-- =====================================================
-- 1. CUSTOMERS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS `general-ak.tata_neu_orders.customers` (
    customer_id STRING NOT NULL,
    first_name STRING NOT NULL,
    last_name STRING NOT NULL,
    email STRING,
    phone_number STRING,
    date_of_birth DATE,
    address STRING,
    city STRING,
    state STRING,
    pincode STRING,
    neucoins_balance INT64 DEFAULT 0,
    customer_tier STRING,  -- 'bronze', 'silver', 'gold', 'platinum'
    registered_date DATE,
    last_activity_date DATE,
    preferred_language STRING DEFAULT 'en'
);

-- Sample Customers
INSERT INTO `general-ak.tata_neu_orders.customers` VALUES
('NEU001', 'Rajesh', 'Sharma', 'rajesh.sharma@email.com', '+91-9876543210', '1985-03-15', '42 MG Road, Koramangala', 'Bangalore', 'Karnataka', '560034', 15250, 'gold', '2023-01-15', '2025-01-20', 'hi'),
('NEU002', 'Priya', 'Patel', 'priya.patel@email.com', '+91-9988776655', '1990-07-22', '15 Linking Road, Bandra', 'Mumbai', 'Maharashtra', '400050', 45000, 'platinum', '2022-06-10', '2025-01-19', 'en'),
('NEU003', 'Amit', 'Singh', 'amit.singh@email.com', '+91-8877665544', '1978-11-08', '78 Civil Lines', 'Delhi', 'Delhi', '110054', 8500, 'silver', '2023-05-20', '2025-01-18', 'hi'),
('NEU004', 'Neha', 'Gupta', 'neha.gupta@email.com', '+91-7766554433', '1995-02-28', '23 Park Street', 'Kolkata', 'West Bengal', '700016', 2500, 'bronze', '2024-01-05', '2025-01-17', 'en'),
('NEU005', 'Vikram', 'Joshi', 'vikram.joshi@email.com', '+91-9955443322', '1982-09-14', '56 Jubilee Hills', 'Hyderabad', 'Telangana', '500033', 12000, 'gold', '2023-08-12', '2025-01-20', 'en'),
('NEU006', 'Ananya', 'Iyer', 'ananya.iyer@email.com', '+91-8866552211', '1988-04-03', '12 Anna Nagar', 'Chennai', 'Tamil Nadu', '600040', 32000, 'platinum', '2022-09-25', '2025-01-19', 'ta'),
('NEU007', 'Suresh', 'Kumar', 'suresh.kumar@email.com', '+91-9944332211', '1975-12-19', '89 Aundh Road', 'Pune', 'Maharashtra', '411007', 6800, 'silver', '2023-04-05', '2025-01-16', 'mr'),
('NEU008', 'Kavita', 'Reddy', 'kavita.reddy@email.com', '+91-7788996655', '1992-06-30', '34 Indiranagar', 'Bangalore', 'Karnataka', '560038', 1200, 'bronze', '2024-06-15', '2025-01-15', 'en');

-- =====================================================
-- 2. TATA NEU CREDIT CARDS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS `general-ak.tata_neu_orders.neu_cards` (
    card_id STRING NOT NULL,
    customer_id STRING NOT NULL,
    card_number STRING,  -- Masked in queries
    card_type STRING,  -- 'neu_infinity', 'neu_plus', 'neu_hipcard'
    card_status STRING,  -- 'active', 'blocked', 'expired', 'pending_activation'
    credit_limit NUMERIC,
    available_limit NUMERIC,
    outstanding_balance NUMERIC,
    minimum_due NUMERIC,
    due_date DATE,
    billing_cycle_date INT64,  -- Day of month
    issued_date DATE,
    expiry_date DATE,
    neucoins_earned_this_month INT64,
    total_neucoins_earned INT64,
    autopay_enabled BOOL DEFAULT FALSE,
    linked_bank_account STRING
);

-- Sample Neu Cards
INSERT INTO `general-ak.tata_neu_orders.neu_cards` VALUES
('CARD001', 'NEU001', '4532123456781234', 'neu_infinity', 'active', 500000.00, 425000.00, 75000.00, 7500.00, '2025-02-15', 15, '2023-02-10', '2028-02-10', 1250, 45000, TRUE, 'HDFC****4567'),
('CARD002', 'NEU002', '4916123456789012', 'neu_infinity', 'active', 1000000.00, 850000.00, 150000.00, 15000.00, '2025-02-20', 20, '2022-08-15', '2027-08-15', 3500, 125000, TRUE, 'ICICI****7890'),
('CARD003', 'NEU003', '5412345678901234', 'neu_plus', 'active', 200000.00, 175000.00, 25000.00, 2500.00, '2025-02-10', 10, '2023-06-01', '2028-06-01', 850, 18500, FALSE, NULL),
('CARD004', 'NEU004', '4539876543210987', 'neu_hipcard', 'active', 75000.00, 62000.00, 13000.00, 1300.00, '2025-02-18', 18, '2024-02-01', '2029-02-01', 450, 3500, FALSE, NULL),
('CARD005', 'NEU005', '5425678901234567', 'neu_plus', 'active', 300000.00, 250000.00, 50000.00, 5000.00, '2025-02-12', 12, '2023-09-10', '2028-09-10', 1100, 28000, TRUE, 'SBI****1234'),
('CARD006', 'NEU006', '4111222233334444', 'neu_infinity', 'active', 750000.00, 680000.00, 70000.00, 7000.00, '2025-02-22', 22, '2022-10-20', '2027-10-20', 2800, 95000, TRUE, 'AXIS****5678'),
('CARD007', 'NEU007', '4532987654321098', 'neu_plus', 'blocked', 250000.00, 0, 250000.00, 250000.00, '2025-01-08', 8, '2023-05-15', '2028-05-15', 0, 22000, FALSE, NULL),
('CARD008', 'NEU008', '5412876543219876', 'neu_hipcard', 'pending_activation', 50000.00, 50000.00, 0, 0, NULL, 25, '2025-01-10', '2030-01-10', 0, 0, FALSE, NULL);

-- =====================================================
-- 3. CARD TRANSACTIONS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS `general-ak.tata_neu_orders.card_transactions` (
    transaction_id STRING NOT NULL,
    card_id STRING NOT NULL,
    transaction_date TIMESTAMP,
    transaction_type STRING,  -- 'purchase', 'refund', 'emi_conversion', 'cashback', 'payment'
    amount NUMERIC,
    merchant_name STRING,
    merchant_category STRING,  -- 'groceries', 'electronics', 'fashion', 'travel', 'dining', 'fuel', 'utilities', 'entertainment'
    description STRING,
    neucoins_earned INT64,
    status STRING,  -- 'completed', 'pending', 'reversed', 'disputed'
    emi_tenure INT64,  -- NULL if not converted to EMI
    reference_number STRING
);

-- Sample Card Transactions for CARD001 (NEU001)
INSERT INTO `general-ak.tata_neu_orders.card_transactions` VALUES
('CTX001001', 'CARD001', '2025-01-20 10:30:00', 'purchase', 15000.00, 'Croma', 'electronics', 'Samsung Galaxy Buds Pro', 450, 'completed', NULL, 'NEU20250120001'),
('CTX001002', 'CARD001', '2025-01-18 14:45:00', 'purchase', 8500.00, 'BigBasket', 'groceries', 'Monthly Groceries', 255, 'completed', NULL, 'NEU20250118001'),
('CTX001003', 'CARD001', '2025-01-15 18:20:00', 'purchase', 45000.00, 'Air India', 'travel', 'Flight BLR-DEL Round Trip', 1350, 'completed', 6, 'NEU20250115001'),
('CTX001004', 'CARD001', '2025-01-12 12:00:00', 'payment', -30000.00, 'Tata Neu App', 'payment', 'Card Bill Payment', 0, 'completed', NULL, 'PAY20250112001'),
('CTX001005', 'CARD001', '2025-01-10 20:30:00', 'purchase', 3200.00, 'Westside', 'fashion', 'Winter Collection', 96, 'completed', NULL, 'NEU20250110001');

-- Sample Card Transactions for CARD002 (NEU002)
INSERT INTO `general-ak.tata_neu_orders.card_transactions` VALUES
('CTX002001', 'CARD002', '2025-01-19 16:00:00', 'purchase', 125000.00, 'Tanishq', 'jewellery', 'Gold Necklace', 3750, 'completed', 12, 'NEU20250119001'),
('CTX002002', 'CARD002', '2025-01-17 11:30:00', 'purchase', 25000.00, 'Taj Hotels', 'travel', 'Hotel Booking - Mumbai', 750, 'completed', NULL, 'NEU20250117001'),
('CTX002003', 'CARD002', '2025-01-15 09:45:00', 'refund', -5000.00, 'Croma', 'electronics', 'Return - Headphones', 0, 'completed', NULL, 'REF20250115001');

-- =====================================================
-- 4. ORDERS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS `general-ak.tata_neu_orders.orders` (
    order_id STRING NOT NULL,
    customer_id STRING NOT NULL,
    order_date TIMESTAMP,
    order_status STRING,  -- 'placed', 'confirmed', 'processing', 'shipped', 'out_for_delivery', 'delivered', 'cancelled', 'return_requested', 'returned', 'refund_initiated', 'refund_completed'
    total_amount NUMERIC,
    discount_amount NUMERIC,
    neucoins_used INT64,
    neucoins_earned INT64,
    payment_method STRING,  -- 'neu_card', 'upi', 'netbanking', 'cod', 'wallet'
    payment_status STRING,  -- 'pending', 'completed', 'failed', 'refunded'
    shipping_address STRING,
    delivery_date DATE,
    estimated_delivery DATE,
    brand STRING,  -- 'bigbasket', 'croma', 'westside', 'tanishq', 'titan', 'tata_1mg', 'air_india', 'taj_hotels', 'tata_cliq'
    tracking_number STRING,
    delivery_partner STRING,  -- 'delhivery', 'bluedart', 'ecom_express', 'brand_delivery'
    cancellation_reason STRING,
    return_reason STRING
);

-- Sample Orders for various customers
INSERT INTO `general-ak.tata_neu_orders.orders` VALUES
-- NEU001 Orders
('ORD001001', 'NEU001', '2025-01-18 10:30:00', 'delivered', 8500.00, 500.00, 200, 255, 'neu_card', 'completed', '42 MG Road, Koramangala, Bangalore - 560034', '2025-01-20', '2025-01-20', 'bigbasket', 'BB123456789', 'brand_delivery', NULL, NULL),
('ORD001002', 'NEU001', '2025-01-15 14:00:00', 'shipped', 45000.00, 2000.00, 500, 1350, 'neu_card', 'completed', '42 MG Road, Koramangala, Bangalore - 560034', NULL, '2025-01-22', 'croma', 'CR987654321', 'bluedart', NULL, NULL),
('ORD001003', 'NEU001', '2025-01-10 09:00:00', 'return_requested', 3500.00, 0.00, 0, 105, 'upi', 'completed', '42 MG Road, Koramangala, Bangalore - 560034', '2025-01-13', '2025-01-13', 'westside', 'WS456789123', 'delhivery', NULL, 'Size does not fit'),

-- NEU002 Orders
('ORD002001', 'NEU002', '2025-01-19 11:00:00', 'out_for_delivery', 125000.00, 5000.00, 1000, 3750, 'neu_card', 'completed', '15 Linking Road, Bandra, Mumbai - 400050', NULL, '2025-01-21', 'tanishq', 'TQ111222333', 'brand_delivery', NULL, NULL),
('ORD002002', 'NEU002', '2025-01-16 16:30:00', 'delivered', 2500.00, 100.00, 50, 75, 'wallet', 'completed', '15 Linking Road, Bandra, Mumbai - 400050', '2025-01-18', '2025-01-18', 'tata_1mg', 'MG444555666', 'delhivery', NULL, NULL),
('ORD002003', 'NEU002', '2025-01-05 08:00:00', 'cancelled', 18000.00, 0.00, 0, 0, 'neu_card', 'refunded', '15 Linking Road, Bandra, Mumbai - 400050', NULL, '2025-01-08', 'titan', NULL, NULL, 'Found better price elsewhere', NULL),

-- NEU003 Orders
('ORD003001', 'NEU003', '2025-01-17 15:00:00', 'processing', 12000.00, 800.00, 300, 360, 'netbanking', 'completed', '78 Civil Lines, Delhi - 110054', NULL, '2025-01-23', 'croma', NULL, NULL, NULL, NULL),
('ORD003002', 'NEU003', '2025-01-12 12:45:00', 'delivered', 1800.00, 0.00, 0, 54, 'cod', 'completed', '78 Civil Lines, Delhi - 110054', '2025-01-15', '2025-01-15', 'bigbasket', 'BB777888999', 'brand_delivery', NULL, NULL),

-- NEU004 Orders  
('ORD004001', 'NEU004', '2025-01-20 09:30:00', 'confirmed', 5500.00, 250.00, 100, 165, 'upi', 'completed', '23 Park Street, Kolkata - 700016', NULL, '2025-01-25', 'westside', NULL, NULL, NULL, NULL),
('ORD004002', 'NEU004', '2025-01-08 18:00:00', 'refund_completed', 8000.00, 500.00, 0, 0, 'neu_card', 'refunded', '23 Park Street, Kolkata - 700016', '2025-01-11', '2025-01-11', 'croma', 'CR123123123', 'bluedart', NULL, 'Product defective'),

-- NEU005 Orders
('ORD005001', 'NEU005', '2025-01-19 20:00:00', 'placed', 35000.00, 1500.00, 800, 1050, 'neu_card', 'pending', '56 Jubilee Hills, Hyderabad - 500033', NULL, '2025-01-26', 'air_india', NULL, NULL, NULL, NULL);

-- =====================================================
-- 5. ORDER ITEMS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS `general-ak.tata_neu_orders.order_items` (
    item_id STRING NOT NULL,
    order_id STRING NOT NULL,
    product_name STRING,
    product_category STRING,
    quantity INT64,
    unit_price NUMERIC,
    total_price NUMERIC,
    item_status STRING,  -- 'active', 'cancelled', 'returned'
    return_eligible BOOL DEFAULT TRUE,
    return_window_days INT64 DEFAULT 7
);

-- Sample Order Items
INSERT INTO `general-ak.tata_neu_orders.order_items` VALUES
('ITEM001001', 'ORD001001', 'Organic Vegetables Combo', 'groceries', 1, 850.00, 850.00, 'active', FALSE, 0),
('ITEM001002', 'ORD001001', 'Dairy Products Pack', 'groceries', 2, 450.00, 900.00, 'active', FALSE, 0),
('ITEM001003', 'ORD001001', 'Monthly Essentials Kit', 'groceries', 1, 6750.00, 6750.00, 'active', FALSE, 0),
('ITEM002001', 'ORD001002', 'Samsung 55" QLED TV', 'electronics', 1, 45000.00, 45000.00, 'active', TRUE, 10),
('ITEM003001', 'ORD001003', 'Winter Jacket - Blue', 'fashion', 1, 3500.00, 3500.00, 'return_requested', TRUE, 15),
('ITEM004001', 'ORD002001', '22KT Gold Necklace', 'jewellery', 1, 125000.00, 125000.00, 'active', TRUE, 30),
('ITEM005001', 'ORD002002', 'Vitamin D3 Supplements', 'healthcare', 2, 750.00, 1500.00, 'active', TRUE, 7),
('ITEM005002', 'ORD002002', 'Multivitamin Tablets', 'healthcare', 1, 1000.00, 1000.00, 'active', TRUE, 7),
('ITEM006001', 'ORD002003', 'Titan Automatic Watch', 'watches', 1, 18000.00, 18000.00, 'cancelled', TRUE, 15),
('ITEM007001', 'ORD003001', 'Wireless Earbuds', 'electronics', 1, 12000.00, 12000.00, 'active', TRUE, 10),
('ITEM008001', 'ORD004001', 'Formal Shirt Pack', 'fashion', 2, 2750.00, 5500.00, 'active', TRUE, 15),
('ITEM009001', 'ORD004002', 'Bluetooth Speaker', 'electronics', 1, 8000.00, 8000.00, 'returned', TRUE, 10),
('ITEM010001', 'ORD005001', 'Flight Ticket BLR-DEL', 'travel', 2, 17500.00, 35000.00, 'active', FALSE, 0);

-- =====================================================
-- 6. CARD STATEMENTS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS `general-ak.tata_neu_orders.card_statements` (
    statement_id STRING NOT NULL,
    card_id STRING NOT NULL,
    statement_date DATE,
    billing_period_start DATE,
    billing_period_end DATE,
    opening_balance NUMERIC,
    total_purchases NUMERIC,
    total_payments NUMERIC,
    closing_balance NUMERIC,
    minimum_due NUMERIC,
    due_date DATE,
    payment_status STRING,  -- 'paid', 'partial', 'unpaid', 'overdue'
    late_fee NUMERIC DEFAULT 0,
    interest_charged NUMERIC DEFAULT 0
);

-- Sample Statements
INSERT INTO `general-ak.tata_neu_orders.card_statements` VALUES
('STMT001001', 'CARD001', '2025-01-15', '2024-12-16', '2025-01-15', 45000.00, 95000.00, 65000.00, 75000.00, 7500.00, '2025-02-05', 'unpaid', 0, 0),
('STMT001002', 'CARD001', '2024-12-15', '2024-11-16', '2024-12-15', 30000.00, 80000.00, 65000.00, 45000.00, 4500.00, '2025-01-05', 'paid', 0, 0),
('STMT002001', 'CARD002', '2025-01-20', '2024-12-21', '2025-01-20', 50000.00, 175000.00, 75000.00, 150000.00, 15000.00, '2025-02-10', 'unpaid', 0, 0),
('STMT003001', 'CARD003', '2025-01-10', '2024-12-11', '2025-01-10', 15000.00, 35000.00, 25000.00, 25000.00, 2500.00, '2025-01-31', 'partial', 0, 0);

-- =====================================================
-- 7. SUPPORT TICKETS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS `general-ak.tata_neu_orders.support_tickets` (
    ticket_id STRING NOT NULL,
    customer_id STRING NOT NULL,
    ticket_type STRING,  -- 'order_issue', 'payment_issue', 'card_issue', 'refund_request', 'delivery_issue', 'product_complaint', 'general_inquiry'
    related_order_id STRING,
    related_card_id STRING,
    subject STRING,
    description STRING,
    status STRING,  -- 'open', 'in_progress', 'waiting_customer', 'resolved', 'closed'
    priority STRING,  -- 'low', 'medium', 'high', 'urgent'
    created_date TIMESTAMP,
    updated_date TIMESTAMP,
    resolved_date TIMESTAMP,
    assigned_to STRING,
    resolution_notes STRING
);

-- Sample Support Tickets
INSERT INTO `general-ak.tata_neu_orders.support_tickets` VALUES
('TKT001001', 'NEU001', 'delivery_issue', 'ORD001002', NULL, 'Delivery Delayed', 'My order was supposed to be delivered on 20th but still showing shipped', 'in_progress', 'medium', '2025-01-20 14:00:00', '2025-01-20 16:00:00', NULL, 'Delivery Team', NULL),
('TKT001002', 'NEU001', 'refund_request', 'ORD001003', NULL, 'Return Pickup Request', 'Please arrange pickup for return. Size does not fit.', 'open', 'medium', '2025-01-18 10:00:00', '2025-01-18 10:00:00', NULL, NULL, NULL),
('TKT002001', 'NEU002', 'card_issue', NULL, 'CARD002', 'EMI Conversion Query', 'I want to convert my Tanishq purchase to 12 month EMI', 'resolved', 'low', '2025-01-19 12:00:00', '2025-01-19 14:00:00', '2025-01-19 14:00:00', 'Card Support', 'EMI conversion completed successfully'),
('TKT003001', 'NEU003', 'payment_issue', 'ORD003001', NULL, 'Payment Deducted Twice', 'Amount deducted twice for order ORD003001', 'in_progress', 'high', '2025-01-17 16:00:00', '2025-01-18 09:00:00', NULL, 'Payment Team', NULL),
('TKT004001', 'NEU004', 'product_complaint', 'ORD004002', NULL, 'Defective Product Received', 'Received defective Bluetooth speaker, not working', 'resolved', 'high', '2025-01-12 11:00:00', '2025-01-15 10:00:00', '2025-01-15 10:00:00', 'Returns Team', 'Full refund processed');

-- =====================================================
-- 8. NEUCOINS TRANSACTIONS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS `general-ak.tata_neu_orders.neucoins_transactions` (
    transaction_id STRING NOT NULL,
    customer_id STRING NOT NULL,
    transaction_date TIMESTAMP,
    transaction_type STRING,  -- 'earned', 'redeemed', 'expired', 'bonus', 'reversal'
    neucoins_amount INT64,
    source STRING,  -- 'order', 'card_purchase', 'referral', 'promotion', 'birthday_bonus'
    reference_id STRING,  -- order_id or card_transaction_id
    description STRING,
    balance_after INT64
);

-- Sample NeuCoins Transactions
INSERT INTO `general-ak.tata_neu_orders.neucoins_transactions` VALUES
('NCT001001', 'NEU001', '2025-01-20 10:30:00', 'earned', 255, 'order', 'ORD001001', 'Earned from BigBasket order', 15250),
('NCT001002', 'NEU001', '2025-01-18 10:30:00', 'redeemed', -200, 'order', 'ORD001001', 'Used for BigBasket order', 14995),
('NCT001003', 'NEU001', '2025-01-15 14:00:00', 'earned', 1350, 'card_purchase', 'CTX001003', 'Earned from Air India booking', 14740),
('NCT002001', 'NEU002', '2025-01-19 11:00:00', 'earned', 3750, 'order', 'ORD002001', 'Earned from Tanishq purchase', 45000),
('NCT002002', 'NEU002', '2025-01-19 11:00:00', 'redeemed', -1000, 'order', 'ORD002001', 'Used for Tanishq order', 42250),
('NCT002003', 'NEU002', '2025-01-15 00:00:00', 'bonus', 500, 'promotion', NULL, 'Republic Day Bonus', 43250);

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================
-- Run these to verify data was inserted correctly:

-- SELECT COUNT(*) as customer_count FROM `general-ak.tata_neu_orders.customers`;
-- SELECT COUNT(*) as card_count FROM `general-ak.tata_neu_orders.neu_cards`;
-- SELECT COUNT(*) as order_count FROM `general-ak.tata_neu_orders.orders`;
-- SELECT COUNT(*) as ticket_count FROM `general-ak.tata_neu_orders.support_tickets`;

-- =====================================================
-- SAMPLE QUERIES FOR COMMON USE CASES
-- =====================================================

-- Get customer's active orders:
-- SELECT order_id, order_date, order_status, total_amount, brand, estimated_delivery
-- FROM `general-ak.tata_neu_orders.orders`
-- WHERE customer_id = 'NEU001' AND order_status NOT IN ('delivered', 'cancelled', 'refund_completed')
-- ORDER BY order_date DESC;

-- Get customer's Neu Card summary:
-- SELECT card_id, card_type, credit_limit, available_limit, outstanding_balance, due_date
-- FROM `general-ak.tata_neu_orders.neu_cards`
-- WHERE customer_id = 'NEU001' AND card_status = 'active';

-- Get recent card transactions:
-- SELECT ct.transaction_date, ct.merchant_name, ct.amount, ct.neucoins_earned, ct.status
-- FROM `general-ak.tata_neu_orders.card_transactions` ct
-- JOIN `general-ak.tata_neu_orders.neu_cards` nc ON ct.card_id = nc.card_id
-- WHERE nc.customer_id = 'NEU001'
-- ORDER BY ct.transaction_date DESC LIMIT 10;

-- Get order with items:
-- SELECT o.order_id, o.order_status, oi.product_name, oi.quantity, oi.total_price
-- FROM `general-ak.tata_neu_orders.orders` o
-- JOIN `general-ak.tata_neu_orders.order_items` oi ON o.order_id = oi.order_id
-- WHERE o.order_id = 'ORD001001';
