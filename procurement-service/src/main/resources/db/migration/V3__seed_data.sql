-- =============================================================================
-- Procurement Service — V3 Seed Data
-- Demo-ready sample data for vendors, RFQs, and purchase orders.
-- Migration Tool : Flyway
-- Author        : Misba (Database Engineer)
--
-- UUIDs are fixed (not gen_random_uuid()) so seed data is deterministic and
-- cross-service references (e.g. product_code matching Inventory SKUs) are stable.
-- =============================================================================

-- ─────────────────────────────────────────────────────────────────────────────
-- VENDORS  (5 suppliers across industries)
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO vendor (id, vendor_code, name, contact_name, email, phone,
                    address_line1, city, state, country, postal_code,
                    payment_terms, vendor_rating, is_active) VALUES

('a1000000-0000-0000-0000-000000000001', 'VND-001', 'Tata Steel Supplies Ltd.',
 'Rajan Mehta', 'rajan.mehta@tatasupplies.in', '+91-22-4001-1000',
 '24, Nariman Point', 'Mumbai', 'Maharashtra', 'IN', '400021',
 'NET_30', 4.50, TRUE),

('a1000000-0000-0000-0000-000000000002', 'VND-002', 'Bharat Electronics Corp.',
 'Priya Sharma', 'priya.s@bharatelec.in', '+91-80-2095-2000',
 '18, Electronics City Phase 1', 'Bengaluru', 'Karnataka', 'IN', '560100',
 'NET_45', 4.20, TRUE),

('a1000000-0000-0000-0000-000000000003', 'VND-003', 'Reliance Polymers Pvt. Ltd.',
 'Suresh Patil', 'suresh.patil@reliancepolymers.in', '+91-22-3300-5500',
 '7, Jamnagar Industrial Estate', 'Jamnagar', 'Gujarat', 'IN', '361004',
 'NET_30', 4.10, TRUE),

('a1000000-0000-0000-0000-000000000004', 'VND-004', 'GlobalTech Components GmbH',
 'Klaus Weber', 'k.weber@globaltech.de', '+49-89-1234-5678',
 'Industriestr. 45', 'Munich', 'Bavaria', 'DE', '80939',
 'NET_60', 4.75, TRUE),

('a1000000-0000-0000-0000-000000000005', 'VND-005', 'Apex Packaging Solutions',
 'Anjali Nair', 'anjali.nair@apexpackaging.in', '+91-44-2810-3300',
 '12, SIDCO Industrial Estate', 'Chennai', 'Tamil Nadu', 'IN', '600098',
 'NET_15', 3.90, TRUE);

-- ─────────────────────────────────────────────────────────────────────────────
-- RFQs  (8 requests for quotation)
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO rfq (id, rfq_number, vendor_id, status, issue_date, due_date, notes, created_by) VALUES

('b2000000-0000-0000-0000-000000000001', 'RFQ-2024-0001',
 'a1000000-0000-0000-0000-000000000001', 'ACCEPTED',
 '2024-01-05', '2024-01-20', 'Q1 raw steel procurement', 'proc_user_001'),

('b2000000-0000-0000-0000-000000000002', 'RFQ-2024-0002',
 'a1000000-0000-0000-0000-000000000002', 'ACCEPTED',
 '2024-01-10', '2024-01-25', 'Circuit boards and sensors batch', 'proc_user_001'),

('b2000000-0000-0000-0000-000000000003', 'RFQ-2024-0003',
 'a1000000-0000-0000-0000-000000000003', 'SENT',
 '2024-02-01', '2024-02-15', 'Polymer resins Q1', 'proc_user_002'),

('b2000000-0000-0000-0000-000000000004', 'RFQ-2024-0004',
 'a1000000-0000-0000-0000-000000000004', 'ACCEPTED',
 '2024-02-05', '2024-02-20', 'Precision machined parts — tight tolerances', 'proc_user_001'),

('b2000000-0000-0000-0000-000000000005', 'RFQ-2024-0005',
 'a1000000-0000-0000-0000-000000000005', 'REJECTED',
 '2024-02-10', '2024-02-25', 'Corrugated boxes — rejected due to price', 'proc_user_002'),

('b2000000-0000-0000-0000-000000000006', 'RFQ-2024-0006',
 'a1000000-0000-0000-0000-000000000001', 'EXPIRED',
 '2024-03-01', '2024-03-10', 'Structural steel Q2 advance', 'proc_user_001'),

('b2000000-0000-0000-0000-000000000007', 'RFQ-2024-0007',
 'a1000000-0000-0000-0000-000000000002', 'DRAFT',
 '2024-03-15', '2024-03-30', 'PCB assembly components Q2', 'proc_user_003'),

('b2000000-0000-0000-0000-000000000008', 'RFQ-2024-0008',
 'a1000000-0000-0000-0000-000000000004', 'RECEIVED',
 '2024-03-18', '2024-04-01', 'CNC machined aluminium parts', 'proc_user_002');

-- ─────────────────────────────────────────────────────────────────────────────
-- RFQ LINE ITEMS
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO rfq_line_item (id, rfq_id, line_number, product_code, description,
                            quantity, unit_of_measure, estimated_unit_price, vendor_quoted_price) VALUES

('c3000000-0000-0000-0000-000000000001', 'b2000000-0000-0000-0000-000000000001', 1,
 'STL-HR-6MM', 'Hot-rolled steel sheet 6mm', 1000, 'KG', 65.0000, 62.5000),

('c3000000-0000-0000-0000-000000000002', 'b2000000-0000-0000-0000-000000000001', 2,
 'STL-CR-3MM', 'Cold-rolled steel strip 3mm', 500, 'KG', 78.0000, 75.0000),

('c3000000-0000-0000-0000-000000000003', 'b2000000-0000-0000-0000-000000000002', 1,
 'ELEC-CB-001', 'Industrial circuit board — Model CB-2024', 200, 'EACH', 850.0000, 820.0000),

('c3000000-0000-0000-0000-000000000004', 'b2000000-0000-0000-0000-000000000002', 2,
 'ELEC-SENS-T01', 'Temperature sensor NTC 10K', 500, 'EACH', 45.0000, 42.5000),

('c3000000-0000-0000-0000-000000000005', 'b2000000-0000-0000-0000-000000000004', 1,
 'MECH-BRNG-6204', 'Deep groove ball bearing 6204', 300, 'EACH', 120.0000, 115.0000);

-- ─────────────────────────────────────────────────────────────────────────────
-- PURCHASE ORDERS  (10 POs)
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO purchase_order (id, po_number, vendor_id, rfq_id, status, order_date,
                             expected_delivery_date, actual_delivery_date,
                             currency, total_amount, shipping_address,
                             payment_terms, notes, approved_by, created_by) VALUES

('d4000000-0000-0000-0000-000000000001', 'PO-2024-0001',
 'a1000000-0000-0000-0000-000000000001', 'b2000000-0000-0000-0000-000000000001',
 'RECEIVED', '2024-01-22', '2024-02-05', '2024-02-04',
 'USD', 93250.0000, 'WH-MUM-01, Navi Mumbai',
 'NET_30', 'Q1 steel order — confirmed and received', 'mgr_001', 'proc_user_001'),

('d4000000-0000-0000-0000-000000000002', 'PO-2024-0002',
 'a1000000-0000-0000-0000-000000000002', 'b2000000-0000-0000-0000-000000000002',
 'RECEIVED', '2024-01-27', '2024-02-12', '2024-02-11',
 'USD', 185250.0000, 'WH-BLR-01, Bengaluru',
 'NET_45', 'Electronics components batch Q1', 'mgr_001', 'proc_user_001'),

('d4000000-0000-0000-0000-000000000003', 'PO-2024-0003',
 'a1000000-0000-0000-0000-000000000004', 'b2000000-0000-0000-0000-000000000004',
 'RECEIVED', '2024-02-22', '2024-03-08', '2024-03-07',
 'USD', 34500.0000, 'WH-MUM-01, Navi Mumbai',
 'NET_60', 'Precision bearings import', 'mgr_002', 'proc_user_001'),

('d4000000-0000-0000-0000-000000000004', 'PO-2024-0004',
 'a1000000-0000-0000-0000-000000000001', NULL,
 'SENT', '2024-03-01', '2024-03-20', NULL,
 'USD', 55000.0000, 'WH-MUM-01, Navi Mumbai',
 'NET_30', 'Urgent steel replenishment — no RFQ', 'mgr_001', 'proc_user_002'),

('d4000000-0000-0000-0000-000000000005', 'PO-2024-0005',
 'a1000000-0000-0000-0000-000000000003', NULL,
 'APPROVED', '2024-03-10', '2024-03-28', NULL,
 'USD', 28000.0000, 'WH-BLR-01, Bengaluru',
 'NET_30', 'Polymer resins replenishment', 'mgr_002', 'proc_user_002'),

('d4000000-0000-0000-0000-000000000006', 'PO-2024-0006',
 'a1000000-0000-0000-0000-000000000002', NULL,
 'PARTIALLY_RECEIVED', '2024-03-12', '2024-03-27', NULL,
 'USD', 42000.0000, 'WH-DEL-01, Delhi NCR',
 'NET_45', 'Sensors partial delivery in progress', 'mgr_001', 'proc_user_003'),

('d4000000-0000-0000-0000-000000000007', 'PO-2024-0007',
 'a1000000-0000-0000-0000-000000000005', NULL,
 'CANCELLED', '2024-02-15', '2024-03-01', NULL,
 'USD', 12500.0000, 'WH-CHN-01, Chennai',
 'NET_15', 'Packaging order cancelled — spec change', 'mgr_002', 'proc_user_001'),

('d4000000-0000-0000-0000-000000000008', 'PO-2024-0008',
 'a1000000-0000-0000-0000-000000000004', NULL,
 'DRAFT', '2024-03-20', '2024-04-10', NULL,
 'USD', 67000.0000, 'WH-MUM-01, Navi Mumbai',
 'NET_60', 'Q2 precision parts draft', NULL, 'proc_user_002'),

('d4000000-0000-0000-0000-000000000009', 'PO-2024-0009',
 'a1000000-0000-0000-0000-000000000001', NULL,
 'RECEIVED', '2024-04-02', '2024-04-15', '2024-04-14',
 'USD', 110000.0000, 'WH-MUM-01, Navi Mumbai',
 'NET_30', 'Q2 bulk steel order', 'mgr_001', 'proc_user_001'),

('d4000000-0000-0000-0000-000000000010', 'PO-2024-0010',
 'a1000000-0000-0000-0000-000000000002', NULL,
 'SENT', '2024-04-05', '2024-04-22', NULL,
 'USD', 93500.0000, 'WH-BLR-01, Bengaluru',
 'NET_45', 'Q2 electronics components', 'mgr_001', 'proc_user_003');

-- ─────────────────────────────────────────────────────────────────────────────
-- PO LINE ITEMS  (matching the POs above)
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO po_line_item (id, po_id, line_number, product_code, description,
                           quantity_ordered, quantity_received,
                           unit_of_measure, unit_price) VALUES

-- PO-2024-0001 (Steel)
('e5000000-0000-0000-0000-000000000001', 'd4000000-0000-0000-0000-000000000001', 1,
 'STL-HR-6MM', 'Hot-rolled steel sheet 6mm', 1000, 1000, 'KG', 62.5000),
('e5000000-0000-0000-0000-000000000002', 'd4000000-0000-0000-0000-000000000001', 2,
 'STL-CR-3MM', 'Cold-rolled steel strip 3mm', 500, 500, 'KG', 75.0000),

-- PO-2024-0002 (Electronics)
('e5000000-0000-0000-0000-000000000003', 'd4000000-0000-0000-0000-000000000002', 1,
 'ELEC-CB-001', 'Industrial circuit board CB-2024', 200, 200, 'EACH', 820.0000),
('e5000000-0000-0000-0000-000000000004', 'd4000000-0000-0000-0000-000000000002', 2,
 'ELEC-SENS-T01', 'Temperature sensor NTC 10K', 500, 500, 'EACH', 42.5000),

-- PO-2024-0003 (Bearings)
('e5000000-0000-0000-0000-000000000005', 'd4000000-0000-0000-0000-000000000003', 1,
 'MECH-BRNG-6204', 'Deep groove ball bearing 6204', 300, 300, 'EACH', 115.0000),

-- PO-2024-0004 (Urgent steel)
('e5000000-0000-0000-0000-000000000006', 'd4000000-0000-0000-0000-000000000004', 1,
 'STL-HR-6MM', 'Hot-rolled steel sheet 6mm', 800, 0, 'KG', 68.7500),

-- PO-2024-0005 (Polymers)
('e5000000-0000-0000-0000-000000000007', 'd4000000-0000-0000-0000-000000000005', 1,
 'POLY-HDPE-001', 'HDPE resin granules — natural', 2000, 0, 'KG', 14.0000),

-- PO-2024-0006 (Sensors partial)
('e5000000-0000-0000-0000-000000000008', 'd4000000-0000-0000-0000-000000000006', 1,
 'ELEC-SENS-T01', 'Temperature sensor NTC 10K', 800, 400, 'EACH', 42.5000),
('e5000000-0000-0000-0000-000000000009', 'd4000000-0000-0000-0000-000000000006', 2,
 'ELEC-SENS-H01', 'Humidity sensor DHT22', 200, 100, 'EACH', 85.0000),

-- PO-2024-0009 (Q2 bulk steel)
('e5000000-0000-0000-0000-000000000010', 'd4000000-0000-0000-0000-000000000009', 1,
 'STL-HR-6MM', 'Hot-rolled steel sheet 6mm', 1500, 1500, 'KG', 62.0000),
('e5000000-0000-0000-0000-000000000011', 'd4000000-0000-0000-0000-000000000009', 2,
 'STL-HR-10MM', 'Hot-rolled steel plate 10mm', 500, 500, 'KG', 58.0000);
