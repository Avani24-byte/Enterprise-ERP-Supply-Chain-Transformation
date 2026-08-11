-- =============================================================================
-- Inventory Service — V1 Initial Schema
-- Migration Tool : Flyway
-- Naming        : snake_case
-- PK Type       : UUID (gen_random_uuid())
-- Author        : Misba (Database Engineer)
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ─────────────────────────────────────────────────────────────────────────────
-- WAREHOUSE
-- Physical storage locations. One service can manage multiple warehouses.
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE warehouse (
    id               UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    warehouse_code   VARCHAR(20) NOT NULL UNIQUE,           -- e.g. WH-MUM-01
    name             VARCHAR(255) NOT NULL,
    address_line1    VARCHAR(255),
    address_line2    VARCHAR(255),
    city             VARCHAR(100),
    state            VARCHAR(100),
    country          CHAR(2)     NOT NULL DEFAULT 'IN',
    postal_code      VARCHAR(20),
    manager_name     VARCHAR(150),
    manager_email    VARCHAR(255),
    capacity_sqm     NUMERIC(10,2) CHECK (capacity_sqm IS NULL OR capacity_sqm > 0),
    is_active        BOOLEAN     NOT NULL DEFAULT TRUE,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE warehouse IS 'Physical warehouse locations managed by the Inventory service.';

-- ─────────────────────────────────────────────────────────────────────────────
-- STOCK_ITEM
-- A single SKU held in a specific warehouse. The combination (sku, warehouse_id)
-- is unique — the same product in two warehouses = two rows.
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE stock_item (
    id                  UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    sku                 VARCHAR(50) NOT NULL,
    warehouse_id        UUID        NOT NULL REFERENCES warehouse(id) ON DELETE RESTRICT,
    product_name        VARCHAR(255) NOT NULL,
    description         TEXT,
    category            VARCHAR(100),
    unit_of_measure     VARCHAR(20) NOT NULL DEFAULT 'EACH',
    quantity_on_hand    NUMERIC(12,4) NOT NULL DEFAULT 0
                            CHECK (quantity_on_hand >= 0),
    quantity_reserved   NUMERIC(12,4) NOT NULL DEFAULT 0
                            CHECK (quantity_reserved >= 0),
    reorder_point       NUMERIC(12,4) NOT NULL DEFAULT 10
                            CHECK (reorder_point > 0),      -- triggers ReorderTriggered Kafka event
    reorder_quantity    NUMERIC(12,4) NOT NULL DEFAULT 50
                            CHECK (reorder_quantity > 0),
    unit_cost           NUMERIC(15,4) CHECK (unit_cost IS NULL OR unit_cost >= 0),
    is_active           BOOLEAN     NOT NULL DEFAULT TRUE,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT stock_item_sku_warehouse_unique UNIQUE (sku, warehouse_id),
    CONSTRAINT stock_item_reserved_le_on_hand
        CHECK (quantity_reserved <= quantity_on_hand)
);

COMMENT ON TABLE  stock_item IS 'Per-SKU per-warehouse stock record. Quantity constraints enforced at DB level.';
COMMENT ON COLUMN stock_item.quantity_reserved IS 'Quantity committed to confirmed sales orders but not yet dispatched.';
COMMENT ON COLUMN stock_item.reorder_point IS 'When quantity_on_hand drops to or below this, a StockLow / ReorderTriggered Kafka event fires.';

-- ─────────────────────────────────────────────────────────────────────────────
-- BATCH
-- A received lot/batch of a single SKU. Enables batch/lot tracking and FEFO
-- (First Expired First Out) picking. One batch = one stock_item.
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE batch (
    id                  UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    batch_number        VARCHAR(50) NOT NULL UNIQUE,        -- e.g. BAT-2024-0001
    stock_item_id       UUID        NOT NULL REFERENCES stock_item(id) ON DELETE RESTRICT,
    quantity            NUMERIC(12,4) NOT NULL CHECK (quantity > 0),
    quantity_remaining  NUMERIC(12,4) NOT NULL CHECK (quantity_remaining >= 0),
    manufactured_date   DATE,
    expiry_date         DATE,
    supplier_lot_number VARCHAR(100),                       -- lot # from vendor's documentation
    received_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    is_active           BOOLEAN     NOT NULL DEFAULT TRUE,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT batch_expiry_after_manufacture
        CHECK (expiry_date IS NULL OR manufactured_date IS NULL OR expiry_date >= manufactured_date),
    CONSTRAINT batch_remaining_le_quantity
        CHECK (quantity_remaining <= quantity)
);

COMMENT ON TABLE  batch IS 'Lot/batch tracking per stock_item. Supports FEFO picking via expiry_date.';
COMMENT ON COLUMN batch.quantity_remaining IS 'Decremented as items are dispatched from this batch.';

-- ─────────────────────────────────────────────────────────────────────────────
-- STOCK_MOVEMENT
-- Immutable audit log of every quantity change for a stock_item.
-- Never updated — only INSERT. Application logic derives current qty from this log
-- OR from the denormalized quantity_on_hand column in stock_item (source of truth).
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE stock_movement (
    id               UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    stock_item_id    UUID        NOT NULL REFERENCES stock_item(id) ON DELETE RESTRICT,
    movement_type    VARCHAR(20) NOT NULL
                         CHECK (movement_type IN (
                             'RECEIPT',      -- goods received from PO
                             'DISPATCH',     -- goods sent on a sales order
                             'ADJUSTMENT',   -- manual inventory adjustment
                             'TRANSFER_OUT', -- moved to another warehouse
                             'TRANSFER_IN',  -- received from another warehouse
                             'RETURN'        -- customer return
                         )),
    quantity_delta   NUMERIC(12,4) NOT NULL,  -- positive = increase, negative = decrease
    quantity_after   NUMERIC(12,4) NOT NULL CHECK (quantity_after >= 0),
    reference_type   VARCHAR(30),             -- 'PURCHASE_ORDER' | 'SALES_ORDER' | 'MANUAL' | 'TRANSFER'
    reference_id     UUID,                    -- ID in the originating service
    batch_id         UUID        REFERENCES batch(id) ON DELETE SET NULL,
    warehouse_from_id UUID       REFERENCES warehouse(id) ON DELETE SET NULL,
    warehouse_to_id  UUID        REFERENCES warehouse(id) ON DELETE SET NULL,
    performed_by     VARCHAR(100),
    notes            TEXT,
    moved_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE  stock_movement IS 'Append-only audit log of every inventory quantity change.';
COMMENT ON COLUMN stock_movement.quantity_delta IS 'Positive for increases (receipt/return), negative for decreases (dispatch).';
COMMENT ON COLUMN stock_movement.reference_id IS 'UUID of the triggering PO or SO in its respective service.';
