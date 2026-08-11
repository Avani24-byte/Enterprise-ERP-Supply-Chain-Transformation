-- =============================================================================
-- Order Service — V1 Initial Schema
-- Migration Tool : Flyway
-- Naming        : snake_case
-- PK Type       : UUID (gen_random_uuid())
-- Author        : Misba (Database Engineer)
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ─────────────────────────────────────────────────────────────────────────────
-- CUSTOMER
-- Buyer master record. A customer places sales orders.
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE customer (
    id                UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_code     VARCHAR(30) NOT NULL UNIQUE,          -- e.g. CUST-001
    name              VARCHAR(255) NOT NULL,
    contact_name      VARCHAR(150),
    email             VARCHAR(255),
    phone             VARCHAR(50),
    billing_address   VARCHAR(500),
    shipping_address  VARCHAR(500),
    credit_limit      NUMERIC(15,4) NOT NULL DEFAULT 0
                          CHECK (credit_limit >= 0),
    credit_used       NUMERIC(15,4) NOT NULL DEFAULT 0
                          CHECK (credit_used >= 0),
    is_active         BOOLEAN     NOT NULL DEFAULT TRUE,
    created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT customer_credit_used_le_limit
        CHECK (credit_used <= credit_limit)
);

COMMENT ON TABLE  customer IS 'Buyer master. Sales orders reference this table.';
COMMENT ON COLUMN customer.credit_limit IS 'Maximum outstanding balance allowed for this customer.';

-- ─────────────────────────────────────────────────────────────────────────────
-- SALES_ORDER
-- A customer's purchase request. Triggers OrderPlaced Kafka event on CONFIRMED.
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE sales_order (
    id                       UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    order_number             VARCHAR(30) NOT NULL UNIQUE,   -- e.g. SO-2024-0001
    customer_id              UUID        NOT NULL REFERENCES customer(id) ON DELETE RESTRICT,
    status                   VARCHAR(25) NOT NULL DEFAULT 'DRAFT'
                                 CHECK (status IN (
                                     'DRAFT',
                                     'CONFIRMED',           -- → fires OrderPlaced Kafka event
                                     'PROCESSING',
                                     'PARTIALLY_SHIPPED',
                                     'SHIPPED',             -- → fires ShipmentDispatched Kafka event
                                     'DELIVERED',
                                     'CANCELLED',
                                     'RETURNED'
                                 )),
    order_date               DATE        NOT NULL DEFAULT CURRENT_DATE,
    required_delivery_date   DATE,
    actual_delivery_date     DATE,
    currency                 CHAR(3)     NOT NULL DEFAULT 'USD',
    subtotal_amount          NUMERIC(15,4) NOT NULL DEFAULT 0 CHECK (subtotal_amount >= 0),
    tax_amount               NUMERIC(15,4) NOT NULL DEFAULT 0 CHECK (tax_amount >= 0),
    shipping_amount          NUMERIC(15,4) NOT NULL DEFAULT 0 CHECK (shipping_amount >= 0),
    total_amount             NUMERIC(15,4) NOT NULL DEFAULT 0 CHECK (total_amount >= 0),
    shipping_address         VARCHAR(500),
    billing_address          VARCHAR(500),
    payment_method           VARCHAR(30),
    payment_status           VARCHAR(20) NOT NULL DEFAULT 'PENDING'
                                 CHECK (payment_status IN ('PENDING','PAID','PARTIALLY_PAID','REFUNDED')),
    notes                    TEXT,
    created_by               VARCHAR(100),
    created_at               TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at               TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT so_delivery_after_order
        CHECK (required_delivery_date IS NULL OR required_delivery_date >= order_date),
    CONSTRAINT so_actual_after_order
        CHECK (actual_delivery_date IS NULL OR actual_delivery_date >= order_date)
);

COMMENT ON TABLE  sales_order IS 'Customer sales order. Status transitions fire Kafka events consumed by Inventory and Logistics.';
COMMENT ON COLUMN sales_order.status IS 'DRAFT→CONFIRMED→PROCESSING→PARTIALLY_SHIPPED/SHIPPED→DELIVERED. CANCELLED/RETURNED are terminal.';

-- ─────────────────────────────────────────────────────────────────────────────
-- ORDER_LINE_ITEM
-- Individual product lines within a sales order.
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE order_line_item (
    id                UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    sales_order_id    UUID        NOT NULL REFERENCES sales_order(id) ON DELETE CASCADE,
    line_number       SMALLINT    NOT NULL,
    sku               VARCHAR(50) NOT NULL,                 -- matches Inventory service SKU
    product_name      VARCHAR(255) NOT NULL,
    quantity_ordered  INTEGER     NOT NULL CHECK (quantity_ordered > 0),
    quantity_shipped  INTEGER     NOT NULL DEFAULT 0 CHECK (quantity_shipped >= 0),
    unit_price        NUMERIC(15,4) NOT NULL CHECK (unit_price >= 0),
    discount_pct      NUMERIC(5,2) NOT NULL DEFAULT 0
                          CHECK (discount_pct >= 0 AND discount_pct <= 100),
    total_price       NUMERIC(15,4) GENERATED ALWAYS AS (
                          quantity_ordered * unit_price * (1 - discount_pct / 100)
                      ) STORED,
    notes             TEXT,
    created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT order_line_unique UNIQUE (sales_order_id, line_number),
    CONSTRAINT order_line_shipped_le_ordered
        CHECK (quantity_shipped <= quantity_ordered)
);

COMMENT ON TABLE  order_line_item IS 'Line items of a sales order. total_price is a generated (stored) column.';
COMMENT ON COLUMN order_line_item.sku IS 'Must match a sku in the Inventory service — enforced at application layer (cross-service FK).';
COMMENT ON COLUMN order_line_item.quantity_shipped IS 'Updated by Logistics service events via Kafka.';
