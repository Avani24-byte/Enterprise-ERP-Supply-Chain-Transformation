-- =============================================================================
-- Procurement Service — V1 Initial Schema
-- Migration Tool : Flyway
-- Naming        : snake_case
-- PK Type       : UUID (gen_random_uuid())
-- Currency      : NUMERIC(15,4) — safe for computation, display-round on API
-- Author        : Misba (Database Engineer)
-- =============================================================================

-- Enable pgcrypto extension for gen_random_uuid() on PostgreSQL < 14
-- (PostgreSQL 15+ has gen_random_uuid() built-in; this is a safe no-op there)
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ─────────────────────────────────────────────────────────────────────────────
-- VENDOR
-- Core supplier master. One vendor can be linked to many RFQs and POs.
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE vendor (
    id                UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    vendor_code       VARCHAR(30) NOT NULL UNIQUE,          -- e.g. VND-001
    name              VARCHAR(255) NOT NULL,
    contact_name      VARCHAR(150),
    email             VARCHAR(255),
    phone             VARCHAR(50),
    address_line1     VARCHAR(255),
    address_line2     VARCHAR(255),
    city              VARCHAR(100),
    state             VARCHAR(100),
    country           CHAR(2)     NOT NULL DEFAULT 'IN',    -- ISO 3166-1 alpha-2
    postal_code       VARCHAR(20),
    payment_terms     VARCHAR(30) NOT NULL DEFAULT 'NET_30'
                          CHECK (payment_terms IN ('IMMEDIATE','NET_15','NET_30','NET_45','NET_60')),
    vendor_rating     NUMERIC(3,2)                          -- 0.00 – 5.00
                          CHECK (vendor_rating IS NULL OR (vendor_rating >= 0 AND vendor_rating <= 5)),
    is_active         BOOLEAN     NOT NULL DEFAULT TRUE,
    created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE  vendor IS 'Supplier master — one vendor per row, owned by Procurement service.';
COMMENT ON COLUMN vendor.vendor_code IS 'Human-readable unique code, e.g. VND-001.';
COMMENT ON COLUMN vendor.payment_terms IS 'Agreed payment window with this vendor.';

-- ─────────────────────────────────────────────────────────────────────────────
-- RFQ (Request For Quotation)
-- Issued to a vendor to solicit pricing before creating a PO.
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE rfq (
    id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    rfq_number    VARCHAR(30) NOT NULL UNIQUE,              -- e.g. RFQ-2024-0001
    vendor_id     UUID        NOT NULL REFERENCES vendor(id) ON DELETE RESTRICT,
    status        VARCHAR(20) NOT NULL DEFAULT 'DRAFT'
                      CHECK (status IN ('DRAFT','SENT','RECEIVED','ACCEPTED','REJECTED','EXPIRED')),
    issue_date    DATE        NOT NULL DEFAULT CURRENT_DATE,
    due_date      DATE,
    notes         TEXT,
    created_by    VARCHAR(100),                             -- user ID / username from Auth service
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT rfq_due_after_issue CHECK (due_date IS NULL OR due_date >= issue_date)
);

COMMENT ON TABLE  rfq IS 'Request For Quotation sent to a vendor. Can be ACCEPTED (→ PO) or REJECTED/EXPIRED.';
COMMENT ON COLUMN rfq.status IS 'DRAFT→SENT→RECEIVED→ACCEPTED/REJECTED/EXPIRED';

-- ─────────────────────────────────────────────────────────────────────────────
-- RFQ_LINE_ITEM
-- Individual product lines within an RFQ.
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE rfq_line_item (
    id                    UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    rfq_id                UUID        NOT NULL REFERENCES rfq(id) ON DELETE CASCADE,
    line_number           SMALLINT    NOT NULL,             -- display order within the RFQ
    product_code          VARCHAR(50) NOT NULL,             -- SKU / part number
    description           VARCHAR(500),
    quantity              NUMERIC(12,4) NOT NULL CHECK (quantity > 0),
    unit_of_measure       VARCHAR(20) NOT NULL DEFAULT 'EACH',
    estimated_unit_price  NUMERIC(15,4) CHECK (estimated_unit_price IS NULL OR estimated_unit_price >= 0),
    vendor_quoted_price   NUMERIC(15,4) CHECK (vendor_quoted_price IS NULL OR vendor_quoted_price >= 0),
    created_at            TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT rfq_line_unique UNIQUE (rfq_id, line_number)
);

COMMENT ON TABLE rfq_line_item IS 'Individual line items of an RFQ, one row per product requested.';

-- ─────────────────────────────────────────────────────────────────────────────
-- PURCHASE_ORDER
-- Formal commitment to buy goods from a vendor.
-- Optionally sourced from an accepted RFQ.
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE purchase_order (
    id                      UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    po_number               VARCHAR(30) NOT NULL UNIQUE,    -- e.g. PO-2024-0001
    vendor_id               UUID        NOT NULL REFERENCES vendor(id) ON DELETE RESTRICT,
    rfq_id                  UUID        REFERENCES rfq(id) ON DELETE SET NULL,  -- nullable: PO can exist without RFQ
    status                  VARCHAR(25) NOT NULL DEFAULT 'DRAFT'
                                CHECK (status IN (
                                    'DRAFT','APPROVED','SENT',
                                    'PARTIALLY_RECEIVED','RECEIVED','CANCELLED'
                                )),
    order_date              DATE        NOT NULL DEFAULT CURRENT_DATE,
    expected_delivery_date  DATE,
    actual_delivery_date    DATE,
    currency                CHAR(3)     NOT NULL DEFAULT 'USD',
    total_amount            NUMERIC(15,4) NOT NULL DEFAULT 0 CHECK (total_amount >= 0),
    shipping_address        VARCHAR(500),
    payment_terms           VARCHAR(30) NOT NULL DEFAULT 'NET_30'
                                CHECK (payment_terms IN ('IMMEDIATE','NET_15','NET_30','NET_45','NET_60')),
    notes                   TEXT,
    approved_by             VARCHAR(100),
    approved_at             TIMESTAMPTZ,
    created_by              VARCHAR(100),
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT po_delivery_after_order
        CHECK (expected_delivery_date IS NULL OR expected_delivery_date >= order_date),
    CONSTRAINT po_actual_after_order
        CHECK (actual_delivery_date IS NULL OR actual_delivery_date >= order_date)
);

COMMENT ON TABLE  purchase_order IS 'Formal purchase commitment to a vendor. Optionally derived from an RFQ.';
COMMENT ON COLUMN purchase_order.rfq_id IS 'NULL if PO was raised directly without an RFQ.';
COMMENT ON COLUMN purchase_order.total_amount IS 'Stored total; kept in sync by application layer when lines change.';

-- ─────────────────────────────────────────────────────────────────────────────
-- PO_LINE_ITEM
-- Individual product lines within a Purchase Order.
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE po_line_item (
    id                 UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    po_id              UUID        NOT NULL REFERENCES purchase_order(id) ON DELETE CASCADE,
    line_number        SMALLINT    NOT NULL,
    product_code       VARCHAR(50) NOT NULL,                -- matches SKU in Inventory service
    description        VARCHAR(500),
    quantity_ordered   NUMERIC(12,4) NOT NULL CHECK (quantity_ordered > 0),
    quantity_received  NUMERIC(12,4) NOT NULL DEFAULT 0 CHECK (quantity_received >= 0),
    unit_of_measure    VARCHAR(20) NOT NULL DEFAULT 'EACH',
    unit_price         NUMERIC(15,4) NOT NULL CHECK (unit_price >= 0),
    total_price        NUMERIC(15,4) GENERATED ALWAYS AS (quantity_ordered * unit_price) STORED,
    created_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT po_line_unique UNIQUE (po_id, line_number),
    CONSTRAINT po_line_received_le_ordered
        CHECK (quantity_received <= quantity_ordered)
);

COMMENT ON TABLE  po_line_item IS 'Line items of a PO. total_price is a generated (stored) column.';
COMMENT ON COLUMN po_line_item.quantity_received IS 'Updated on GRN (Goods Receipt Note) events from Inventory.';
