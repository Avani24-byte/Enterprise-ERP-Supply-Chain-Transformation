-- Draft for Avani � Notification Service, not part of Misba's DB scope

-- =============================================================================
-- Notification Service — V1 Initial Schema
-- Migration Tool : Flyway
-- Naming        : snake_case
-- PK Type       : UUID (gen_random_uuid())
-- Author        : Misba (Database Engineer)
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ─────────────────────────────────────────────────────────────────────────────
-- NOTIFICATION_EVENT
-- Raw Kafka events received by the Notification service.
-- Stored for deduplication, replay, and audit — append-only.
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE notification_event (
    id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    kafka_topic     VARCHAR(100) NOT NULL,                  -- e.g. order.placed
    kafka_offset    BIGINT,
    kafka_partition SMALLINT,
    event_type      VARCHAR(100) NOT NULL,                  -- e.g. OrderPlaced, StockLow
    event_source    VARCHAR(100) NOT NULL,                  -- originating service name
    event_payload   JSONB       NOT NULL,                   -- full event body
    is_processed    BOOLEAN     NOT NULL DEFAULT FALSE,
    processed_at    TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE  notification_event IS 'Inbound Kafka events. Used for deduplication and idempotency. Append-only.';
COMMENT ON COLUMN notification_event.event_payload IS 'Full JSON event body as received from Kafka.';

-- ─────────────────────────────────────────────────────────────────────────────
-- NOTIFICATION
-- A notification generated from an event and sent to a user.
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE notification (
    id                   UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    notification_event_id UUID       REFERENCES notification_event(id) ON DELETE SET NULL,
    notification_type    VARCHAR(50) NOT NULL
                             CHECK (notification_type IN (
                                 'LOW_STOCK',
                                 'REORDER_TRIGGERED',
                                 'ORDER_PLACED',
                                 'ORDER_CONFIRMED',
                                 'ORDER_SHIPPED',
                                 'ORDER_DELIVERED',
                                 'SHIPMENT_DISPATCHED',
                                 'SHIPMENT_DELAYED',
                                 'PO_APPROVED',
                                 'PO_RECEIVED',
                                 'SYSTEM_ALERT'
                             )),
    recipient_id         VARCHAR(100) NOT NULL,             -- user UUID from Auth service
    recipient_email      VARCHAR(255),
    subject              VARCHAR(500) NOT NULL,
    body                 TEXT        NOT NULL,
    channel              VARCHAR(20) NOT NULL DEFAULT 'IN_APP'
                             CHECK (channel IN ('IN_APP','EMAIL','SMS','PUSH')),
    priority             VARCHAR(10) NOT NULL DEFAULT 'MEDIUM'
                             CHECK (priority IN ('LOW','MEDIUM','HIGH','CRITICAL')),
    status               VARCHAR(20) NOT NULL DEFAULT 'PENDING'
                             CHECK (status IN ('PENDING','SENT','FAILED','READ','ARCHIVED')),
    retry_count          SMALLINT    NOT NULL DEFAULT 0 CHECK (retry_count >= 0),
    created_at           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    sent_at              TIMESTAMPTZ,
    read_at              TIMESTAMPTZ,
    updated_at           TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE  notification IS 'Outbound notifications generated from Kafka events and sent to users.';
COMMENT ON COLUMN notification.recipient_id IS 'User UUID from the Auth service — cross-service reference, not a FK.';
COMMENT ON COLUMN notification.channel IS 'Delivery channel. IN_APP = stored here; EMAIL/SMS requires external dispatch.';

