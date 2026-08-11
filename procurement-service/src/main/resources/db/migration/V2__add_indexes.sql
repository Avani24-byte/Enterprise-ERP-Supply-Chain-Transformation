-- =============================================================================
-- Procurement Service — V2 Indexes & Performance Tuning
-- Migration Tool : Flyway
-- Author        : Misba (Database Engineer)
-- =============================================================================

-- ─── VENDOR indexes ───────────────────────────────────────────────────────────
-- Lookup by name substring (vendor search box in UI)
CREATE INDEX idx_vendor_name ON vendor USING gin (to_tsvector('english', name));
-- Filter active vendors
CREATE INDEX idx_vendor_is_active ON vendor (is_active) WHERE is_active = TRUE;
-- Country filter for regional analytics
CREATE INDEX idx_vendor_country ON vendor (country);

-- ─── RFQ indexes ──────────────────────────────────────────────────────────────
-- Most common query: all RFQs for a given vendor
CREATE INDEX idx_rfq_vendor_id ON rfq (vendor_id);
-- Status filtering (DRAFT, SENT, etc.)
CREATE INDEX idx_rfq_status ON rfq (status);
-- Date range queries in reporting views
CREATE INDEX idx_rfq_issue_date ON rfq (issue_date DESC);
-- Compound: vendor + status (vendor portal view)
CREATE INDEX idx_rfq_vendor_status ON rfq (vendor_id, status);

-- ─── RFQ_LINE_ITEM indexes ────────────────────────────────────────────────────
CREATE INDEX idx_rfq_line_rfq_id ON rfq_line_item (rfq_id);
-- Product code lookup (cross-reference with Inventory SKU)
CREATE INDEX idx_rfq_line_product_code ON rfq_line_item (product_code);

-- ─── PURCHASE_ORDER indexes ───────────────────────────────────────────────────
CREATE INDEX idx_po_vendor_id ON purchase_order (vendor_id);
CREATE INDEX idx_po_status ON purchase_order (status);
CREATE INDEX idx_po_order_date ON purchase_order (order_date DESC);
CREATE INDEX idx_po_expected_delivery ON purchase_order (expected_delivery_date);
-- Compound: vendor + status (vendor performance dashboard)
CREATE INDEX idx_po_vendor_status ON purchase_order (vendor_id, status);
-- RFQ → PO trace
CREATE INDEX idx_po_rfq_id ON purchase_order (rfq_id) WHERE rfq_id IS NOT NULL;

-- ─── PO_LINE_ITEM indexes ─────────────────────────────────────────────────────
CREATE INDEX idx_po_line_po_id ON po_line_item (po_id);
CREATE INDEX idx_po_line_product_code ON po_line_item (product_code);

-- ─────────────────────────────────────────────────────────────────────────────
-- ANALYTICS VIEW: Vendor Performance
-- Supports vw_vendor_performance in analytics/sql/reporting_views.sql
-- ─────────────────────────────────────────────────────────────────────────────
CREATE VIEW vw_vendor_performance AS
SELECT
    v.id                                                    AS vendor_id,
    v.vendor_code,
    v.name                                                  AS vendor_name,
    v.country,
    COUNT(DISTINCT po.id)                                   AS total_pos,
    COUNT(DISTINCT po.id) FILTER (WHERE po.status = 'RECEIVED')
                                                            AS completed_pos,
    SUM(po.total_amount) FILTER (WHERE po.status IN ('RECEIVED','PARTIALLY_RECEIVED'))
                                                            AS total_spend,
    AVG(
        po.actual_delivery_date - po.order_date
    ) FILTER (WHERE po.actual_delivery_date IS NOT NULL)    AS avg_lead_time_days,
    AVG(v.vendor_rating)                                    AS avg_rating
FROM vendor v
LEFT JOIN purchase_order po ON po.vendor_id = v.id
GROUP BY v.id, v.vendor_code, v.name, v.country;

COMMENT ON VIEW vw_vendor_performance IS 'Aggregated vendor KPIs: PO count, spend, lead time, rating. Used by Analytics service.';

-- ─────────────────────────────────────────────────────────────────────────────
-- ANALYTICS VIEW: Monthly Procurement Spend
-- ─────────────────────────────────────────────────────────────────────────────
CREATE VIEW vw_monthly_spend AS
SELECT
    DATE_TRUNC('month', po.order_date)                      AS month,
    v.name                                                  AS vendor_name,
    pol.product_code,
    SUM(pol.total_price)                                    AS total_spend,
    COUNT(DISTINCT po.id)                                   AS po_count
FROM po_line_item pol
JOIN purchase_order po ON po.id = pol.po_id
JOIN vendor v ON v.id = po.vendor_id
WHERE po.status NOT IN ('CANCELLED')
GROUP BY DATE_TRUNC('month', po.order_date), v.name, pol.product_code;

COMMENT ON VIEW vw_monthly_spend IS 'Monthly spend by vendor and product. Used by Analytics and Finance dashboards.';
