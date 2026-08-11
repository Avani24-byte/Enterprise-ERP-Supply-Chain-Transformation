-- =============================================================================
-- Inventory Service — V2 Indexes & Performance Tuning
-- Migration Tool : Flyway
-- Author        : Misba (Database Engineer)
-- =============================================================================

-- ─── WAREHOUSE indexes ────────────────────────────────────────────────────────
CREATE INDEX idx_warehouse_is_active ON warehouse (is_active) WHERE is_active = TRUE;
CREATE INDEX idx_warehouse_country ON warehouse (country);

-- ─── STOCK_ITEM indexes ───────────────────────────────────────────────────────
-- Primary lookup: find all stock rows for a given warehouse
CREATE INDEX idx_stock_item_warehouse_id ON stock_item (warehouse_id);
-- SKU lookup (global search across warehouses)
CREATE INDEX idx_stock_item_sku ON stock_item (sku);
-- Compound (sku, warehouse_id) already covered by the UNIQUE constraint index.
-- Category browse/filter
CREATE INDEX idx_stock_item_category ON stock_item (category);
-- LOW STOCK ALERT QUERY: items below reorder point (partial index for performance)
CREATE INDEX idx_stock_item_below_reorder ON stock_item (warehouse_id, sku)
    WHERE quantity_on_hand <= reorder_point AND is_active = TRUE;
-- Active items only
CREATE INDEX idx_stock_item_is_active ON stock_item (is_active) WHERE is_active = TRUE;

-- ─── BATCH indexes ────────────────────────────────────────────────────────────
-- FEFO picking: find earliest-expiring active batches for a stock_item
CREATE INDEX idx_batch_stock_item_expiry ON batch (stock_item_id, expiry_date ASC)
    WHERE is_active = TRUE AND quantity_remaining > 0;
-- Lookup batch by supplier lot number
CREATE INDEX idx_batch_supplier_lot ON batch (supplier_lot_number);
-- Expiry date range queries (expired stock reports)
CREATE INDEX idx_batch_expiry_date ON batch (expiry_date);

-- ─── STOCK_MOVEMENT indexes ───────────────────────────────────────────────────
-- Timeline for a specific stock_item
CREATE INDEX idx_movement_stock_item_id ON stock_movement (stock_item_id, moved_at DESC);
-- Filter by movement type
CREATE INDEX idx_movement_type ON stock_movement (movement_type);
-- Cross-service reference lookup (find movement by PO or SO id)
CREATE INDEX idx_movement_reference ON stock_movement (reference_type, reference_id)
    WHERE reference_id IS NOT NULL;
-- Batch movement history
CREATE INDEX idx_movement_batch_id ON stock_movement (batch_id) WHERE batch_id IS NOT NULL;

-- ─────────────────────────────────────────────────────────────────────────────
-- ANALYTICS VIEW: Inventory Turnover
-- Turnover = Total dispatched / Average on-hand quantity
-- ─────────────────────────────────────────────────────────────────────────────
CREATE VIEW vw_inventory_turnover AS
WITH dispatched AS (
    SELECT
        sm.stock_item_id,
        DATE_TRUNC('month', sm.moved_at)    AS month,
        SUM(ABS(sm.quantity_delta))         AS total_dispatched
    FROM stock_movement sm
    WHERE sm.movement_type IN ('DISPATCH', 'TRANSFER_OUT')
    GROUP BY sm.stock_item_id, DATE_TRUNC('month', sm.moved_at)
)
SELECT
    si.sku,
    si.product_name,
    w.warehouse_code,
    d.month,
    d.total_dispatched,
    si.quantity_on_hand                     AS current_qty_on_hand,
    CASE
        WHEN si.quantity_on_hand = 0 THEN NULL
        ELSE ROUND(d.total_dispatched / si.quantity_on_hand, 4)
    END                                     AS turnover_ratio
FROM dispatched d
JOIN stock_item si ON si.id = d.stock_item_id
JOIN warehouse w   ON w.id  = si.warehouse_id;

COMMENT ON VIEW vw_inventory_turnover IS 'Monthly inventory turnover ratio per SKU/warehouse. Used by Analytics service.';

-- ─────────────────────────────────────────────────────────────────────────────
-- ANALYTICS VIEW: Current Stock Levels (snapshot for dashboard)
-- ─────────────────────────────────────────────────────────────────────────────
CREATE VIEW vw_stock_snapshot AS
SELECT
    si.id               AS stock_item_id,
    si.sku,
    si.product_name,
    si.category,
    w.warehouse_code,
    w.name              AS warehouse_name,
    si.quantity_on_hand,
    si.quantity_reserved,
    (si.quantity_on_hand - si.quantity_reserved) AS quantity_available,
    si.reorder_point,
    si.unit_cost,
    (si.quantity_on_hand * si.unit_cost) AS stock_value,
    CASE
        WHEN si.quantity_on_hand <= si.reorder_point THEN 'LOW'
        WHEN si.quantity_on_hand <= si.reorder_point * 1.5 THEN 'MEDIUM'
        ELSE 'OK'
    END                 AS stock_status,
    si.updated_at       AS last_updated
FROM stock_item si
JOIN warehouse w ON w.id = si.warehouse_id
WHERE si.is_active = TRUE;

COMMENT ON VIEW vw_stock_snapshot IS 'Current inventory snapshot with stock_status labels. Used by Analytics and Inventory dashboard.';
