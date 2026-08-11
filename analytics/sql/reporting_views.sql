-- =============================================================================
-- Analytics Service — Cross-Service Reporting Views
-- These views are intended to be materialized or queried by the Analytics
-- service. They AGGREGATE data from across the three PostgreSQL databases.
--
-- NOTE: In a true microservices deployment, each service owns its own DB and
-- these cross-DB views cannot run natively in PostgreSQL without postgres_fdw
-- (Foreign Data Wrapper). Options:
--   (a) Run this via postgres_fdw — see comments below.
--   (b) The Analytics service calls each service's REST API and aggregates in-memory.
--   (c) Use an ETL/CDC pipeline (Debezium + Kafka) to a dedicated analytics DB.
--
-- For the demo/academic scope, these are provided as SQL reference queries
-- that can be run against a combined analytics DB (option c) or adapted for
-- postgres_fdw (option a).
--
-- Author : Misba (Database Engineer)
-- =============================================================================

-- ─────────────────────────────────────────────────────────────────────────────
-- VIEW 1: Vendor Performance Dashboard
-- Source: procurement_db — vendor, purchase_order
-- Used by: Analytics KPI dashboard, Procurement Manager view
-- ─────────────────────────────────────────────────────────────────────────────
-- (Materialized version — refresh on schedule or after PO updates)
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_vendor_performance AS
SELECT
    v.id                                                            AS vendor_id,
    v.vendor_code,
    v.name                                                          AS vendor_name,
    v.country,
    v.vendor_rating,
    COUNT(DISTINCT po.id)                                           AS total_pos,
    COUNT(DISTINCT po.id) FILTER (WHERE po.status = 'RECEIVED')    AS completed_pos,
    COUNT(DISTINCT po.id) FILTER (WHERE po.status = 'CANCELLED')   AS cancelled_pos,
    ROUND(
        COUNT(DISTINCT po.id) FILTER (WHERE po.status = 'RECEIVED')::NUMERIC
        / NULLIF(COUNT(DISTINCT po.id), 0) * 100, 2
    )                                                               AS completion_rate_pct,
    COALESCE(SUM(po.total_amount) FILTER (
        WHERE po.status IN ('RECEIVED','PARTIALLY_RECEIVED')
    ), 0)                                                           AS total_spend,
    COALESCE(AVG(
        po.actual_delivery_date - po.order_date
    ) FILTER (WHERE po.actual_delivery_date IS NOT NULL), NULL)     AS avg_lead_time_days,
    MAX(po.order_date)                                              AS last_po_date
FROM vendor v
LEFT JOIN purchase_order po ON po.vendor_id = v.id
WHERE v.is_active = TRUE
GROUP BY v.id, v.vendor_code, v.name, v.country, v.vendor_rating;

CREATE UNIQUE INDEX ON mv_vendor_performance (vendor_id);

COMMENT ON MATERIALIZED VIEW mv_vendor_performance
IS 'Vendor KPIs: spend, PO completion rate, average lead time. Refresh after PO status changes.';

-- Refresh command (run via scheduled job or triggered after bulk PO updates):
-- REFRESH MATERIALIZED VIEW CONCURRENTLY mv_vendor_performance;

-- ─────────────────────────────────────────────────────────────────────────────
-- VIEW 2: Monthly Procurement Spend by Category
-- Source: procurement_db — purchase_order, po_line_item
-- ─────────────────────────────────────────────────────────────────────────────
CREATE VIEW vw_monthly_procurement_spend AS
SELECT
    DATE_TRUNC('month', po.order_date)              AS month,
    v.name                                          AS vendor_name,
    pol.product_code,
    SUM(pol.total_price)                            AS total_spend,
    SUM(pol.quantity_ordered)                       AS total_qty_ordered,
    COUNT(DISTINCT po.id)                           AS po_count,
    AVG(pol.unit_price)                             AS avg_unit_price
FROM po_line_item pol
JOIN purchase_order po ON po.id = pol.po_id
JOIN vendor v           ON v.id  = po.vendor_id
WHERE po.status NOT IN ('CANCELLED', 'DRAFT')
GROUP BY DATE_TRUNC('month', po.order_date), v.name, pol.product_code
ORDER BY month DESC, total_spend DESC;

COMMENT ON VIEW vw_monthly_procurement_spend
IS 'Monthly procurement spend by vendor and product code. Used by Finance dashboard.';

-- ─────────────────────────────────────────────────────────────────────────────
-- VIEW 3: Inventory Health Dashboard
-- Source: inventory_db — stock_item, warehouse
-- ─────────────────────────────────────────────────────────────────────────────
CREATE VIEW vw_inventory_health AS
SELECT
    w.warehouse_code,
    w.name                                                      AS warehouse_name,
    si.category,
    COUNT(si.id)                                                AS total_skus,
    COUNT(si.id) FILTER (WHERE si.quantity_on_hand = 0)        AS out_of_stock_skus,
    COUNT(si.id) FILTER (WHERE si.quantity_on_hand <= si.reorder_point
                           AND si.quantity_on_hand > 0)        AS low_stock_skus,
    COUNT(si.id) FILTER (WHERE si.quantity_on_hand > si.reorder_point) AS healthy_skus,
    SUM(si.quantity_on_hand * si.unit_cost)                    AS total_stock_value,
    SUM(si.quantity_on_hand)                                   AS total_units_on_hand
FROM stock_item si
JOIN warehouse w ON w.id = si.warehouse_id
WHERE si.is_active = TRUE AND w.is_active = TRUE
GROUP BY w.warehouse_code, w.name, si.category;

COMMENT ON VIEW vw_inventory_health
IS 'Inventory health by warehouse and category: OOS count, low stock count, stock value.';

-- ─────────────────────────────────────────────────────────────────────────────
-- VIEW 4: SKUs Below Reorder Point (Low Stock Alert Feed)
-- Source: inventory_db — stock_item, warehouse
-- This is the data feed for the StockLow Kafka event trigger
-- ─────────────────────────────────────────────────────────────────────────────
CREATE VIEW vw_low_stock_alerts AS
SELECT
    si.id               AS stock_item_id,
    si.sku,
    si.product_name,
    si.category,
    w.warehouse_code,
    w.name              AS warehouse_name,
    w.manager_email,
    si.quantity_on_hand,
    si.reorder_point,
    si.reorder_quantity,
    (si.reorder_point - si.quantity_on_hand) AS units_below_reorder,
    si.unit_cost,
    (si.reorder_quantity * si.unit_cost)     AS estimated_reorder_cost,
    si.updated_at       AS last_movement_at
FROM stock_item si
JOIN warehouse w ON w.id = si.warehouse_id
WHERE si.is_active = TRUE
  AND w.is_active = TRUE
  AND si.quantity_on_hand <= si.reorder_point
ORDER BY (si.quantity_on_hand::NUMERIC / si.reorder_point) ASC;  -- most critical first

COMMENT ON VIEW vw_low_stock_alerts
IS 'All SKUs at or below reorder_point, ranked by severity. Used by Notification and Analytics services.';

-- ─────────────────────────────────────────────────────────────────────────────
-- VIEW 5: Order Fulfillment KPIs (OTIF)
-- Source: order_db — sales_order, order_line_item
-- ─────────────────────────────────────────────────────────────────────────────
CREATE VIEW vw_otif_monthly AS
WITH delivered_orders AS (
    SELECT
        so.id,
        so.order_date,
        so.required_delivery_date,
        so.actual_delivery_date,
        so.total_amount,
        -- In-Full check: all lines fully shipped
        NOT EXISTS (
            SELECT 1 FROM order_line_item oli
            WHERE oli.sales_order_id = so.id
              AND oli.quantity_shipped < oli.quantity_ordered
        )                                                   AS is_full,
        -- On-Time check
        so.actual_delivery_date IS NOT NULL
        AND so.required_delivery_date IS NOT NULL
        AND so.actual_delivery_date <= so.required_delivery_date AS is_on_time
    FROM sales_order so
    WHERE so.status = 'DELIVERED'
      AND so.required_delivery_date IS NOT NULL
)
SELECT
    DATE_TRUNC('month', order_date)                             AS month,
    COUNT(*)                                                    AS total_delivered,
    SUM(CASE WHEN is_full THEN 1 ELSE 0 END)                   AS in_full_count,
    SUM(CASE WHEN is_on_time THEN 1 ELSE 0 END)                AS on_time_count,
    SUM(CASE WHEN is_full AND is_on_time THEN 1 ELSE 0 END)    AS otif_count,
    ROUND(SUM(CASE WHEN is_full AND is_on_time THEN 1 ELSE 0 END)::NUMERIC
          / NULLIF(COUNT(*), 0) * 100, 2)                      AS otif_pct,
    ROUND(SUM(CASE WHEN is_full THEN 1 ELSE 0 END)::NUMERIC
          / NULLIF(COUNT(*), 0) * 100, 2)                      AS in_full_pct,
    ROUND(SUM(CASE WHEN is_on_time THEN 1 ELSE 0 END)::NUMERIC
          / NULLIF(COUNT(*), 0) * 100, 2)                      AS on_time_pct,
    SUM(total_amount)                                          AS total_revenue_delivered
FROM delivered_orders
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY month DESC;

COMMENT ON VIEW vw_otif_monthly
IS 'Monthly OTIF %, In-Full %, On-Time % KPIs. Core supply chain performance metric.';

-- ─────────────────────────────────────────────────────────────────────────────
-- VIEW 6: Top Customers by Revenue (CRM / Sales Analytics)
-- Source: order_db — customer, sales_order
-- ─────────────────────────────────────────────────────────────────────────────
CREATE VIEW vw_top_customers AS
SELECT
    c.id                                                        AS customer_id,
    c.customer_code,
    c.name                                                      AS customer_name,
    COUNT(so.id)                                                AS total_orders,
    COUNT(so.id) FILTER (WHERE so.status = 'DELIVERED')        AS delivered_orders,
    COUNT(so.id) FILTER (WHERE so.status = 'CANCELLED')        AS cancelled_orders,
    COALESCE(SUM(so.total_amount) FILTER (
        WHERE so.status NOT IN ('CANCELLED','RETURNED')
    ), 0)                                                       AS total_revenue,
    COALESCE(AVG(so.total_amount) FILTER (
        WHERE so.status NOT IN ('CANCELLED','RETURNED')
    ), 0)                                                       AS avg_order_value,
    MAX(so.order_date)                                          AS last_order_date,
    c.credit_limit,
    c.credit_used,
    ROUND((c.credit_used / NULLIF(c.credit_limit, 0) * 100), 2) AS credit_utilisation_pct
FROM customer c
LEFT JOIN sales_order so ON so.customer_id = c.id
WHERE c.is_active = TRUE
GROUP BY c.id, c.customer_code, c.name, c.credit_limit, c.credit_used
ORDER BY total_revenue DESC;

COMMENT ON VIEW vw_top_customers
IS 'Customer revenue ranking with credit utilisation. Used by Sales analytics dashboard.';

-- ─────────────────────────────────────────────────────────────────────────────
-- VIEW 7: SKU Demand Summary (Feeds Forecasting Service)
-- Source: order_db — order_line_item, sales_order
-- The Python Forecasting service calls this via the Order service REST API
-- to retrieve historical demand for Prophet/scikit-learn models.
-- ─────────────────────────────────────────────────────────────────────────────
CREATE VIEW vw_sku_monthly_demand AS
SELECT
    oli.sku,
    DATE_TRUNC('month', so.order_date)                          AS month,
    SUM(oli.quantity_ordered)                                   AS total_ordered,
    SUM(oli.quantity_shipped)                                   AS total_shipped,
    COUNT(DISTINCT so.id)                                       AS order_count,
    AVG(oli.unit_price)                                         AS avg_unit_price,
    SUM(oli.total_price)                                        AS total_revenue
FROM order_line_item oli
JOIN sales_order so ON so.id = oli.sales_order_id
WHERE so.status NOT IN ('CANCELLED', 'RETURNED', 'DRAFT')
GROUP BY oli.sku, DATE_TRUNC('month', so.order_date)
ORDER BY oli.sku, month;

COMMENT ON VIEW vw_sku_monthly_demand
IS 'Monthly demand per SKU from confirmed/delivered orders. Primary input for the Forecasting service (Prophet/scikit-learn).';
