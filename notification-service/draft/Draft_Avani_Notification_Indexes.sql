-- Draft for Avani � Notification Service, not part of Misba's DB scope

-- =============================================================================
-- Notification Service — V2 Indexes
-- Migration Tool : Flyway
-- Author        : Misba (Database Engineer)
-- =============================================================================

-- ─── NOTIFICATION_EVENT indexes ───────────────────────────────────────────────
-- Deduplication lookup: find event by kafka topic + offset + partition
CREATE INDEX idx_notif_event_kafka ON notification_event (kafka_topic, kafka_partition, kafka_offset);
-- Find unprocessed events (consumer retry loop)
CREATE INDEX idx_notif_event_unprocessed ON notification_event (created_at ASC)
    WHERE is_processed = FALSE;
-- Event type filter (debugging, admin UI)
CREATE INDEX idx_notif_event_type ON notification_event (event_type);

-- ─── NOTIFICATION indexes ─────────────────────────────────────────────────────
-- Most common query: notifications for a specific user
CREATE INDEX idx_notification_recipient_id ON notification (recipient_id);
-- Unread notifications for a user (bell icon badge count)
CREATE INDEX idx_notification_unread ON notification (recipient_id, created_at DESC)
    WHERE status IN ('PENDING','SENT');
-- Status-based queues (retry FAILED, deliver PENDING)
CREATE INDEX idx_notification_status ON notification (status, created_at ASC)
    WHERE status IN ('PENDING','FAILED');
-- Notification type filter
CREATE INDEX idx_notification_type ON notification (notification_type);
-- Priority queue ordering
CREATE INDEX idx_notification_priority ON notification (priority, created_at ASC)
    WHERE status = 'PENDING';

