// =============================================================================
// Logistics Service — MongoDB Index Definitions
// Collection : shipments (db: logistics_db)
// Author     : Misba (Database Engineer)
//
// Run this script via:
//   mongosh logistics_db indexes.js
//   OR paste into MongoDB Compass > Shell
// =============================================================================

// ─────────────────────────────────────────────────────────────────────────────
// UNIQUE INDEXES
// ─────────────────────────────────────────────────────────────────────────────

// Shipment number must be globally unique (human-readable ID for UI and carrier comms)
db.shipments.createIndex(
  { "shipment_number": 1 },
  { unique: true, name: "idx_shipment_number_unique" }
);

// Carrier tracking number (unique per carrier — partial unique index)
db.shipments.createIndex(
  { "carrier.code": 1, "carrier.tracking_number": 1 },
  {
    unique: true,
    sparse: true,                    // allow documents with missing tracking_number
    name: "idx_carrier_tracking_number"
  }
);

// ─────────────────────────────────────────────────────────────────────────────
// QUERY INDEXES
// ─────────────────────────────────────────────────────────────────────────────

// Most common query: find all shipments for a given sales order
// (called by Order service when user views order details)
db.shipments.createIndex(
  { "order_id": 1 },
  { name: "idx_order_id" }
);

// Customer shipment history view
db.shipments.createIndex(
  { "customer_id": 1, "created_at": -1 },
  { name: "idx_customer_history" }
);

// Status-based filtering (active shipments dashboard, failed deliveries, etc.)
db.shipments.createIndex(
  { "status": 1, "created_at": -1 },
  { name: "idx_status_date" }
);

// Delivery date queries — overdue shipments report
db.shipments.createIndex(
  { "estimated_delivery_date": 1, "status": 1 },
  { name: "idx_estimated_delivery_status" }
);

// Warehouse dispatch history (origin warehouse)
db.shipments.createIndex(
  { "route.origin.warehouse_id": 1, "created_at": -1 },
  { name: "idx_origin_warehouse" }
);

// ─────────────────────────────────────────────────────────────────────────────
// ANALYTICS / REPORTING INDEXES
// ─────────────────────────────────────────────────────────────────────────────

// Carrier performance analysis: group shipments by carrier and month
db.shipments.createIndex(
  { "carrier.code": 1, "created_at": -1 },
  { name: "idx_carrier_analytics" }
);

// Destination country / city analytics
db.shipments.createIndex(
  { "route.destination.country": 1, "route.destination.city": 1 },
  { name: "idx_destination_location" }
);

// ─────────────────────────────────────────────────────────────────────────────
// TRACKING EVENTS SUB-DOCUMENT INDEXES
// ─────────────────────────────────────────────────────────────────────────────

// Find shipments with a specific tracking event status (e.g., all FAILED_ATTEMPT)
db.shipments.createIndex(
  { "tracking_events.status": 1, "tracking_events.timestamp": -1 },
  { name: "idx_tracking_event_status" }
);

// ─────────────────────────────────────────────────────────────────────────────
// VERIFY INDEX CREATION
// ─────────────────────────────────────────────────────────────────────────────
print("Indexes created on shipments collection:");
db.shipments.getIndexes().forEach(function(idx) {
  print("  - " + idx.name + ": " + JSON.stringify(idx.key));
});
