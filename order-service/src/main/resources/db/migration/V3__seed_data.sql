-- =============================================================================
-- Order Service — V3 Seed Data
-- Demo-ready: 8 customers, 20 sales orders, 40 order line items
-- Migration Tool : Flyway
-- Author        : Misba (Database Engineer)
--
-- SO IDs use the j0000000 prefix referenced in Inventory seed stock_movement data.
-- SKU codes match Inventory service stock_item.sku values.
-- =============================================================================

-- ─────────────────────────────────────────────────────────────────────────────
-- CUSTOMERS  (8 buyers)
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO customer (id, customer_code, name, contact_name, email, phone,
                       billing_address, shipping_address,
                       credit_limit, credit_used, is_active) VALUES

('k1000000-0000-0000-0000-000000000001', 'CUST-001', 'Larsen & Toubro Engineering Ltd.',
 'Vikram Joshi', 'v.joshi@lte.in', '+91-22-6752-5656',
 'L&T House, Ballard Estate, Mumbai 400001',
 'L&T Powai Campus, Mumbai 400072',
 5000000.0000, 1250000.0000, TRUE),

('k1000000-0000-0000-0000-000000000002', 'CUST-002', 'Infosys BPM Limited',
 'Ananya Krishnan', 'a.krishnan@infosysbpm.com', '+91-80-2852-0261',
 'Electronics City, Bengaluru 560100',
 'Infosys Campus, Hosur Road, Bengaluru 560100',
 2000000.0000, 380000.0000, TRUE),

('k1000000-0000-0000-0000-000000000003', 'CUST-003', 'Mahindra Auto Components',
 'Sunil Pawar', 's.pawar@mahindra.com', '+91-20-6600-1000',
 'Mahindra Towers, Mumbai 400018',
 'Chakan Plant, Pune 410501',
 3000000.0000, 870000.0000, TRUE),

('k1000000-0000-0000-0000-000000000004', 'CUST-004', 'Asian Paints Distribution Hub',
 'Pooja Agarwal', 'p.agarwal@asianpaints.com', '+91-22-6218-1000',
 '6A, Shantinagar, Santacruz East, Mumbai 400055',
 'Andheri Warehouse, Mumbai 400099',
 1500000.0000, 420000.0000, TRUE),

('k1000000-0000-0000-0000-000000000005', 'CUST-005', 'Sun Pharmaceutical Industries',
 'Dr. Rohit Shah', 'r.shah@sunpharma.com', '+91-22-4324-4324',
 'SPARC, Tandalja, Vadodara 390020',
 'Halol Plant, Panchmahal, Gujarat 389350',
 4000000.0000, 1100000.0000, TRUE),

('k1000000-0000-0000-0000-000000000006', 'CUST-006', 'Godrej Consumer Products Ltd.',
 'Meera Thakkar', 'm.thakkar@godrejcp.com', '+91-22-2518-8010',
 'Pirojshanagar, Vikhroli, Mumbai 400079',
 'Vikhroli Distribution, Mumbai 400083',
 2500000.0000, 650000.0000, TRUE),

('k1000000-0000-0000-0000-000000000007', 'CUST-007', 'Bosch India Automotive',
 'Peter Maier', 'p.maier@bosch.in', '+91-80-2299-2752',
 'Hosur Road, Adugodi, Bengaluru 560030',
 'Nasik Plant, Maharashtra 422010',
 6000000.0000, 2100000.0000, TRUE),

('k1000000-0000-0000-0000-000000000008', 'CUST-008', 'Flipkart Logistics Pvt. Ltd.',
 'Rahul Sharma', 'r.sharma@flipkart.com', '+91-80-4908-3910',
 'Ozone Manay Tech Park, Bengaluru 560068',
 'Bilaspur Warehouse, Gurugram 122001',
 8000000.0000, 3200000.0000, TRUE);

-- ─────────────────────────────────────────────────────────────────────────────
-- SALES ORDERS  (20 orders)
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO sales_order (id, order_number, customer_id, status, order_date,
                          required_delivery_date, actual_delivery_date,
                          currency, subtotal_amount, tax_amount, shipping_amount, total_amount,
                          shipping_address, payment_method, payment_status,
                          notes, created_by) VALUES

('j0000000-0000-0000-0000-000000000001', 'SO-2024-0001',
 'k1000000-0000-0000-0000-000000000001', 'DELIVERED',
 '2024-02-10', '2024-02-20', '2024-02-18',
 'USD', 18750.0000, 3375.0000, 500.0000, 22625.0000,
 'L&T Powai Campus, Mumbai 400072', 'BANK_TRANSFER', 'PAID',
 'Q1 steel delivery for Powai campus', 'sales_user_001'),

('j0000000-0000-0000-0000-000000000002', 'SO-2024-0002',
 'k1000000-0000-0000-0000-000000000002', 'DELIVERED',
 '2024-02-15', '2024-02-28', '2024-02-26',
 'USD', 22250.0000, 4005.0000, 750.0000, 27005.0000,
 'Infosys Campus, Bengaluru 560100', 'CREDIT', 'PAID',
 'Electronics components for Infosys BPM', 'sales_user_002'),

('j0000000-0000-0000-0000-000000000003', 'SO-2024-0003',
 'k1000000-0000-0000-0000-000000000003', 'DELIVERED',
 '2024-03-05', '2024-03-15', '2024-03-14',
 'USD', 11500.0000, 2070.0000, 400.0000, 13970.0000,
 'Chakan Plant, Pune 410501', 'BANK_TRANSFER', 'PAID',
 'Bearings for Mahindra Chakan plant', 'sales_user_001'),

('j0000000-0000-0000-0000-000000000004', 'SO-2024-0004',
 'k1000000-0000-0000-0000-000000000004', 'DELIVERED',
 '2024-03-08', '2024-03-18', '2024-03-17',
 'USD', 28000.0000, 5040.0000, 600.0000, 33640.0000,
 'Andheri Warehouse, Mumbai 400099', 'CREDIT', 'PAID',
 'Polymer resins for Asian Paints', 'sales_user_003'),

('j0000000-0000-0000-0000-000000000005', 'SO-2024-0005',
 'k1000000-0000-0000-0000-000000000001', 'SHIPPED',
 '2024-04-15', '2024-04-25', NULL,
 'USD', 25000.0000, 4500.0000, 500.0000, 30000.0000,
 'L&T Powai Campus, Mumbai 400072', 'BANK_TRANSFER', 'PAID',
 'Q2 steel order L&T', 'sales_user_001'),

('j0000000-0000-0000-0000-000000000006', 'SO-2024-0006',
 'k1000000-0000-0000-0000-000000000002', 'PROCESSING',
 '2024-04-18', '2024-04-30', NULL,
 'USD', 8500.0000, 1530.0000, 350.0000, 10380.0000,
 'Infosys Campus, Bengaluru 560100', 'CREDIT', 'PENDING',
 'Q2 sensor order Infosys', 'sales_user_002'),

('j0000000-0000-0000-0000-000000000007', 'SO-2024-0007',
 'k1000000-0000-0000-0000-000000000007', 'DELIVERED',
 '2024-04-10', '2024-04-20', '2024-04-19',
 'USD', 9600.0000, 1728.0000, 400.0000, 11728.0000,
 'Nasik Plant, Maharashtra 422010', 'BANK_TRANSFER', 'PAID',
 'MCU components for Bosch', 'sales_user_003'),

('j0000000-0000-0000-0000-000000000008', 'SO-2024-0008',
 'k1000000-0000-0000-0000-000000000004', 'DELIVERED',
 '2024-04-12', '2024-04-22', '2024-04-21',
 'USD', 13200.0000, 2376.0000, 500.0000, 16076.0000,
 'Andheri Warehouse, Mumbai 400099', 'CREDIT', 'PAID',
 'PP resin Q2 Asian Paints', 'sales_user_001'),

('j0000000-0000-0000-0000-000000000009', 'SO-2024-0009',
 'k1000000-0000-0000-0000-000000000003', 'DELIVERED',
 '2024-04-20', '2024-04-30', '2024-04-29',
 'USD', 6670.0000, 1200.6000, 300.0000, 8170.6000,
 'Chakan Plant, Pune 410501', 'BANK_TRANSFER', 'PAID',
 'Delhi bearings Mahindra — triggered reorder alert', 'sales_user_002'),

('j0000000-0000-0000-0000-000000000010', 'SO-2024-0010',
 'k1000000-0000-0000-0000-000000000008', 'SHIPPED',
 '2024-04-24', '2024-05-04', NULL,
 'USD', 25000.0000, 4500.0000, 800.0000, 30300.0000,
 'Bilaspur Warehouse, Gurugram 122001', 'CREDIT', 'PAID',
 'Packaging boxes Flipkart', 'sales_user_003'),

('j0000000-0000-0000-0000-000000000011', 'SO-2024-0011',
 'k1000000-0000-0000-0000-000000000005', 'CONFIRMED',
 '2024-05-01', '2024-05-12', NULL,
 'USD', 42000.0000, 7560.0000, 1000.0000, 50560.0000,
 'Halol Plant, Gujarat 389350', 'BANK_TRANSFER', 'PENDING',
 'Pharma packaging materials', 'sales_user_001'),

('j0000000-0000-0000-0000-000000000012', 'SO-2024-0012',
 'k1000000-0000-0000-0000-000000000006', 'DRAFT',
 '2024-05-02', '2024-05-15', NULL,
 'USD', 18000.0000, 3240.0000, 600.0000, 21840.0000,
 'Vikhroli Distribution, Mumbai 400083', 'CREDIT', 'PENDING',
 'Godrej packaging draft order', 'sales_user_002'),

('j0000000-0000-0000-0000-000000000013', 'SO-2024-0013',
 'k1000000-0000-0000-0000-000000000007', 'PROCESSING',
 '2024-05-03', '2024-05-16', NULL,
 'USD', 32000.0000, 5760.0000, 800.0000, 38560.0000,
 'Nasik Plant, Maharashtra 422010', 'BANK_TRANSFER', 'PENDING',
 'Bosch Q2 electronic components', 'sales_user_003'),

('j0000000-0000-0000-0000-000000000014', 'SO-2024-0014',
 'k1000000-0000-0000-0000-000000000001', 'RETURNED',
 '2024-03-20', '2024-03-30', '2024-03-29',
 'USD', 5000.0000, 900.0000, 200.0000, 6100.0000,
 'L&T Powai Campus, Mumbai 400072', 'BANK_TRANSFER', 'REFUNDED',
 'L&T returned defective batch — quality issue', 'sales_user_001'),

('j0000000-0000-0000-0000-000000000015', 'SO-2024-0015',
 'k1000000-0000-0000-0000-000000000003', 'CANCELLED',
 '2024-04-01', '2024-04-12', NULL,
 'USD', 9000.0000, 1620.0000, 300.0000, 10920.0000,
 'Chakan Plant, Pune 410501', 'CREDIT', 'REFUNDED',
 'Cancelled by customer — demand change', 'sales_user_002'),

('j0000000-0000-0000-0000-000000000016', 'SO-2024-0016',
 'k1000000-0000-0000-0000-000000000008', 'DELIVERED',
 '2024-03-15', '2024-03-25', '2024-03-24',
 'USD', 55000.0000, 9900.0000, 1200.0000, 66100.0000,
 'Bilaspur Warehouse, Gurugram 122001', 'CREDIT', 'PAID',
 'Large Flipkart packaging order Q1', 'sales_user_003'),

('j0000000-0000-0000-0000-000000000017', 'SO-2024-0017',
 'k1000000-0000-0000-0000-000000000005', 'DELIVERED',
 '2024-03-18', '2024-03-28', '2024-03-27',
 'USD', 35000.0000, 6300.0000, 800.0000, 42100.0000,
 'Halol Plant, Gujarat 389350', 'BANK_TRANSFER', 'PAID',
 'Sun Pharma polymer raw material', 'sales_user_001'),

('j0000000-0000-0000-0000-000000000018', 'SO-2024-0018',
 'k1000000-0000-0000-0000-000000000006', 'PARTIALLY_SHIPPED',
 '2024-04-28', '2024-05-08', NULL,
 'USD', 20000.0000, 3600.0000, 700.0000, 24300.0000,
 'Vikhroli Distribution, Mumbai 400083', 'CREDIT', 'PARTIALLY_PAID',
 'Godrej partial shipment in progress', 'sales_user_002'),

('j0000000-0000-0000-0000-000000000019', 'SO-2024-0019',
 'k1000000-0000-0000-0000-000000000007', 'CONFIRMED',
 '2024-04-29', '2024-05-10', NULL,
 'USD', 48000.0000, 8640.0000, 1000.0000, 57640.0000,
 'Nasik Plant, Maharashtra 422010', 'BANK_TRANSFER', 'PENDING',
 'Large Bosch Q2 steel order', 'sales_user_001'),

('j0000000-0000-0000-0000-000000000020', 'SO-2024-0020',
 'k1000000-0000-0000-0000-000000000002', 'DELIVERED',
 '2024-05-01', '2024-05-10', '2024-05-09',
 'USD', 12800.0000, 2304.0000, 450.0000, 15554.0000,
 'Infosys Campus, Bengaluru 560100', 'CREDIT', 'PAID',
 'Infosys Q2 MCU order', 'sales_user_003');

-- ─────────────────────────────────────────────────────────────────────────────
-- ORDER LINE ITEMS  (40 lines — ~2 per order)
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO order_line_item (id, sales_order_id, line_number, sku, product_name,
                              quantity_ordered, quantity_shipped,
                              unit_price, discount_pct, notes) VALUES

-- SO-2024-0001
('l2000000-0000-0000-0000-000000000001', 'j0000000-0000-0000-0000-000000000001', 1,
 'STL-HR-6MM', 'Hot-Rolled Steel Sheet 6mm', 300, 300, 62.5000, 0.00, NULL),

-- SO-2024-0002
('l2000000-0000-0000-0000-000000000002', 'j0000000-0000-0000-0000-000000000002', 1,
 'ELEC-CB-001', 'Industrial Circuit Board CB-2024', 20, 20, 950.0000, 5.00, NULL),
('l2000000-0000-0000-0000-000000000003', 'j0000000-0000-0000-0000-000000000002', 2,
 'ELEC-SENS-T01', 'Temperature Sensor NTC 10K', 50, 50, 50.0000, 5.00, NULL),

-- SO-2024-0003
('l2000000-0000-0000-0000-000000000004', 'j0000000-0000-0000-0000-000000000003', 1,
 'MECH-BRNG-6204', 'Deep Groove Ball Bearing 6204', 100, 100, 115.0000, 0.00, NULL),

-- SO-2024-0004
('l2000000-0000-0000-0000-000000000005', 'j0000000-0000-0000-0000-000000000004', 1,
 'POLY-HDPE-001', 'HDPE Resin Granules Natural', 2000, 2000, 14.0000, 0.00, NULL),

-- SO-2024-0005
('l2000000-0000-0000-0000-000000000006', 'j0000000-0000-0000-0000-000000000005', 1,
 'STL-HR-6MM', 'Hot-Rolled Steel Sheet 6mm', 400, 400, 62.5000, 0.00, NULL),

-- SO-2024-0006
('l2000000-0000-0000-0000-000000000007', 'j0000000-0000-0000-0000-000000000006', 1,
 'ELEC-SENS-T01', 'Temperature Sensor NTC 10K', 100, 100, 50.0000, 5.00, NULL),
('l2000000-0000-0000-0000-000000000008', 'j0000000-0000-0000-0000-000000000006', 2,
 'ELEC-SENS-H01', 'Humidity Sensor DHT22', 40, 0, 95.0000, 5.00, 'Pending dispatch'),

-- SO-2024-0007
('l2000000-0000-0000-0000-000000000009', 'j0000000-0000-0000-0000-000000000007', 1,
 'ELEC-MCU-001', 'Microcontroller STM32F103', 30, 30, 320.0000, 0.00, NULL),

-- SO-2024-0008
('l2000000-0000-0000-0000-000000000010', 'j0000000-0000-0000-0000-000000000008', 1,
 'POLY-PP-001', 'Polypropylene Resin Injection Grade', 800, 800, 16.5000, 0.00, NULL),

-- SO-2024-0009
('l2000000-0000-0000-0000-000000000011', 'j0000000-0000-0000-0000-000000000009', 1,
 'MECH-BRNG-6204', 'Deep Groove Ball Bearing 6204', 58, 58, 115.0000, 0.00, 'Delhi WH — triggered reorder'),

-- SO-2024-0010
('l2000000-0000-0000-0000-000000000012', 'j0000000-0000-0000-0000-000000000010', 1,
 'PKG-CORR-A4', 'Corrugated Box A4 Size', 2000, 2000, 12.5000, 0.00, NULL),

-- SO-2024-0011
('l2000000-0000-0000-0000-000000000013', 'j0000000-0000-0000-0000-000000000011', 1,
 'PKG-CORR-A4', 'Corrugated Box A4 Size', 1500, 0, 12.5000, 5.00, NULL),
('l2000000-0000-0000-0000-000000000014', 'j0000000-0000-0000-0000-000000000011', 2,
 'POLY-HDPE-001', 'HDPE Resin Granules Natural', 2000, 0, 14.0000, 5.00, NULL),

-- SO-2024-0012
('l2000000-0000-0000-0000-000000000015', 'j0000000-0000-0000-0000-000000000012', 1,
 'PKG-CORR-A4', 'Corrugated Box A4 Size', 1200, 0, 12.5000, 10.00, 'Draft pricing'),
('l2000000-0000-0000-0000-000000000016', 'j0000000-0000-0000-0000-000000000012', 2,
 'POLY-PP-001', 'Polypropylene Resin Injection Grade', 400, 0, 16.5000, 10.00, NULL),

-- SO-2024-0013
('l2000000-0000-0000-0000-000000000017', 'j0000000-0000-0000-0000-000000000013', 1,
 'ELEC-CB-001', 'Industrial Circuit Board CB-2024', 30, 0, 950.0000, 5.00, NULL),
('l2000000-0000-0000-0000-000000000018', 'j0000000-0000-0000-0000-000000000013', 2,
 'ELEC-MCU-001', 'Microcontroller STM32F103', 20, 0, 320.0000, 5.00, NULL),

-- SO-2024-0014
('l2000000-0000-0000-0000-000000000019', 'j0000000-0000-0000-0000-000000000014', 1,
 'STL-HR-6MM', 'Hot-Rolled Steel Sheet 6mm', 80, 80, 62.5000, 0.00, 'Returned — surface defect'),

-- SO-2024-0015 (cancelled)
('l2000000-0000-0000-0000-000000000020', 'j0000000-0000-0000-0000-000000000015', 1,
 'MECH-BRNG-6204', 'Deep Groove Ball Bearing 6204', 78, 0, 115.0000, 0.00, 'Cancelled'),

-- SO-2024-0016
('l2000000-0000-0000-0000-000000000021', 'j0000000-0000-0000-0000-000000000016', 1,
 'PKG-CORR-A4', 'Corrugated Box A4 Size', 3000, 3000, 12.5000, 8.00, NULL),
('l2000000-0000-0000-0000-000000000022', 'j0000000-0000-0000-0000-000000000016', 2,
 'POLY-HDPE-001', 'HDPE Resin Granules Natural', 1000, 1000, 14.0000, 8.00, NULL),

-- SO-2024-0017
('l2000000-0000-0000-0000-000000000023', 'j0000000-0000-0000-0000-000000000017', 1,
 'POLY-HDPE-001', 'HDPE Resin Granules Natural', 1500, 1500, 14.0000, 5.00, NULL),
('l2000000-0000-0000-0000-000000000024', 'j0000000-0000-0000-0000-000000000017', 2,
 'POLY-PP-001', 'Polypropylene Resin Injection Grade', 700, 700, 16.5000, 5.00, NULL),

-- SO-2024-0018
('l2000000-0000-0000-0000-000000000025', 'j0000000-0000-0000-0000-000000000018', 1,
 'PKG-CORR-A4', 'Corrugated Box A4 Size', 800, 800, 12.5000, 5.00, 'Partial shipped'),
('l2000000-0000-0000-0000-000000000026', 'j0000000-0000-0000-0000-000000000018', 2,
 'ELEC-SENS-T01', 'Temperature Sensor NTC 10K', 100, 0, 50.0000, 5.00, 'Pending'),

-- SO-2024-0019
('l2000000-0000-0000-0000-000000000027', 'j0000000-0000-0000-0000-000000000019', 1,
 'STL-HR-6MM', 'Hot-Rolled Steel Sheet 6mm', 600, 0, 65.0000, 2.00, NULL),
('l2000000-0000-0000-0000-000000000028', 'j0000000-0000-0000-0000-000000000019', 2,
 'STL-HR-10MM', 'Hot-Rolled Steel Plate 10mm', 200, 0, 60.0000, 2.00, NULL),

-- SO-2024-0020
('l2000000-0000-0000-0000-000000000029', 'j0000000-0000-0000-0000-000000000020', 1,
 'ELEC-MCU-001', 'Microcontroller STM32F103', 40, 40, 320.0000, 0.00, NULL);
