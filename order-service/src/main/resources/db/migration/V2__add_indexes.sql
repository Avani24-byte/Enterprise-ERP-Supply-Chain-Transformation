-- =============================================================================
-- Order Service — V2 Indexes & Performance Tuning
-- Migration Tool : Flyway
-- Author        : Misba (Database Engineer)
-- =============================================================================

-- ─── CUSTOMER indexes ─────────────────────────────────────────────────────────
CREATE INDEX idx_customer_is_active ON customer (is_active) WHERE is_active = TRUE;
CREATE INDEX idx_customer_name ON customer USING gin (to_tsvector('english', name));
CREATE INDEX idx_customer_email ON customer (email);

-- ─── SALES_ORDER indexes ──────────────────────────────────────────────────────
-- Most common: orders by customer
CREATE INDEX idx_so_customer_id ON sales_order (customer_id);
-- Status filtering (pipeline views)
CREATE INDEX idx_so_status ON sales_order (status);
-- Date range queries
CREATE INDEX idx_so_order_date ON sales_order (order_date DESC);
CREATE INDEX idx_so_required_delivery ON sales_order (required_delivery_date);
-- Payment status (finance view)
CREATE INDEX idx_so_payment_status ON sales_order (payment_status);
-- Compound: customer + status (customer account view)
CREATE INDEX idx_so_customer_status ON sales_order (customer_id, status);
-- Overdue orders (required_delivery_date < NOW() and not delivered)
CREATE INDEX idx_so_overdue ON sales_order (required_delivery_date)
    WHERE status NOT IN ('DELIVERED','CANCELLED','RETURNED')
    AND required_delivery_date IS NOT NULL;

-- ─── ORDER_LINE_ITEM indexes ──────────────────────────────────────────────────
CREATE INDEX idx_order_line_so_id ON order_line_item (sales_order_id);
-- SKU lookup: which orders contain this product?
CREATE INDEX idx_order_line_sku ON order_line_item (sku);

-- ─────────────────────────────────────────────────────────────────────────────
-- ANALYTICS VIEW: Order Fulfillment Rate (OTIF %)
-- On-Time In-Full: delivered on or before required_delivery_date with all lines shipped
-- ─────────────────────────────────────────────────────────────────────────────
CREATE VIEW vw_order_fulfillment_rate AS
WITH order_metrics AS (
    SELECT
        so.id,
        so.order_number,
        so.customer_id,
        so.order_date,
        so.required_delivery_date,
        so.actual_delivery_date,
        so.status,
        -- In-Full: all quantity_ordered shipped
        CASE WHEN NOT EXISTS (
            SELECT 1 FROM order_line_item oli
            WHERE oli.sales_order_id = so.id
              AND oli.quantity_shipped < oli.quantity_ordered
        ) THEN TRUE ELSE FALSE END AS is_full,
        -- On-Time: delivered on or before required date
        CASE WHEN so.actual_delivery_date IS NOT NULL
             AND so.required_delivery_date IS NOT NULL
             AND so.actual_delivery_date <= so.required_delivery_date
        THEN TRUE ELSE FALSE END AS is_on_time
    FROM sales_order so
    WHERE so.status IN ('DELIVERED')
)
SELECT
    DATE_TRUNC('month', order_date)                         AS month,
    COUNT(*)                                                AS total_delivered,
    SUM(CASE WHEN is_full AND is_on_time THEN 1 ELSE 0 END) AS otif_count,
    ROUND(
        SUM(CASE WHEN is_full AND is_on_time THEN 1 ELSE 0 END)::NUMERIC
        / NULLIF(COUNT(*), 0) * 100, 2
    )                                                       AS otif_pct
FROM order_metrics
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY month DESC;

COMMENT ON VIEW vw_order_fulfillment_rate IS 'Monthly OTIF % (On-Time In-Full). Used by Analytics and KPI dashboard.';

-- ─────────────────────────────────────────────────────────────────────────────
-- ANALYTICS VIEW: Top Customers by Revenue
-- ─────────────────────────────────────────────────────────────────────────────
CREATE VIEW vw_customer_revenue AS
SELECT
    c.id            AS customer_id,
    c.customer_code,
    c.name          AS customer_name,
    COUNT(so.id)    AS total_orders,
    SUM(so.total_amount) FILTER (WHERE so.status NOT IN ('CANCELLED','RETURNED'))
                    AS total_revenue,
    AVG(so.total_amount) FILTER (WHERE so.status NOT IN ('CANCELLED','RETURNED'))
                    AS avg_order_value,
    MAX(so.order_date) AS last_order_date
FROM customer c
LEFT JOIN sales_order so ON so.customer_id = c.id
GROUP BY c.id, c.customer_code, c.name;

COMMENT ON VIEW vw_customer_revenue IS 'Revenue aggregated per customer. Used by Analytics and CRM dashboards.';
