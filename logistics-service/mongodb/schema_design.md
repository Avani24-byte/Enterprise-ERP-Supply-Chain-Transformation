// =============================================================================
// Logistics Service — MongoDB Schema Design
// Collection : shipments
// DB Version : MongoDB 7
// Pattern    : Embedded documents (route + tracking events)
//              Carrier is fully embedded (denormalized) for read performance.
// Author     : Misba (Database Engineer)
// =============================================================================

// ─────────────────────────────────────────────────────────────────────────────
// COLLECTION: shipments
// Represents a physical shipment from a warehouse to a customer destination.
// One shipment is linked to one sales_order (from Order service).
// ─────────────────────────────────────────────────────────────────────────────

// Document Shape:
/*
{
  "_id": ObjectId,                          // MongoDB auto-generated
  "shipment_number": "SHP-2024-0001",       // UNIQUE — human-readable
  "order_id": "uuid-string",                // Sales Order UUID (cross-service reference)
  "order_number": "SO-2024-0001",           // Denormalized for display without join
  "customer_id": "uuid-string",             // Customer UUID (cross-service reference)
  "customer_name": "Larsen & Toubro",       // Denormalized for display
  "status": "IN_TRANSIT",
    // Enum: PENDING | PICKED_UP | IN_TRANSIT | OUT_FOR_DELIVERY |
    //       DELIVERED | FAILED_ATTEMPT | RETURNED | CANCELLED

  "carrier": {
    "carrier_id": "uuid-string",            // Carrier master UUID
    "name": "FedEx India",
    "code": "FEDEX",
    "tracking_number": "9876543210987",     // Carrier's own waybill/tracking number
    "service_type": "EXPRESS",              // STANDARD | EXPRESS | OVERNIGHT | FREIGHT
    "contact_phone": "+91-1800-419-4343",
    "contact_email": "support@fedex.in"
  },

  "route": {
    "origin": {
      "warehouse_id": "uuid-string",        // Warehouse UUID from Inventory service
      "warehouse_code": "WH-MUM-01",
      "warehouse_name": "Mumbai Central Warehouse",
      "address": "Plot 12-A, MIDC Taloja, Navi Mumbai",
      "city": "Navi Mumbai",
      "state": "Maharashtra",
      "country": "IN",
      "departed_at": ISODate("2024-02-15T08:30:00Z")
    },
    "destination": {
      "address": "L&T Powai Campus, Mumbai 400072",
      "city": "Mumbai",
      "state": "Maharashtra",
      "country": "IN",
      "contact_name": "Vikram Joshi",
      "contact_phone": "+91-22-6752-5656",
      "estimated_arrival": ISODate("2024-02-18T18:00:00Z"),
      "actual_arrival": ISODate("2024-02-18T14:30:00Z")   // null until delivered
    },
    "waypoints": [                          // Intermediate transit hubs
      {
        "location": "FedEx Mumbai Hub, Andheri",
        "city": "Mumbai",
        "country": "IN",
        "arrived_at": ISODate("2024-02-15T11:00:00Z"),
        "departed_at": ISODate("2024-02-15T14:00:00Z")
      }
    ]
  },

  "line_items": [                           // What's in the shipment
    {
      "sku": "STL-HR-6MM",
      "product_name": "Hot-Rolled Steel Sheet 6mm",
      "quantity": 300,
      "unit_of_measure": "KG",
      "weight_kg": 300.0,
      "volume_m3": 0.15
    }
  ],

  "tracking_events": [                      // Append-only event log
    {
      "event_id": ObjectId,
      "timestamp": ISODate("2024-02-15T08:30:00Z"),
      "status": "PICKED_UP",
      "location": "WH-MUM-01, Navi Mumbai",
      "city": "Navi Mumbai",
      "country": "IN",
      "description": "Shipment picked up from origin warehouse",
      "updated_by": "WAREHOUSE_STAFF",     // CARRIER_API | WAREHOUSE_STAFF | MANUAL
      "latitude": 19.0596,
      "longitude": 73.0631
    },
    {
      "event_id": ObjectId,
      "timestamp": ISODate("2024-02-15T11:00:00Z"),
      "status": "IN_TRANSIT",
      "location": "FedEx Hub Andheri, Mumbai",
      "city": "Mumbai",
      "country": "IN",
      "description": "Package arrived at transit hub",
      "updated_by": "CARRIER_API",
      "latitude": 19.1136,
      "longitude": 72.8697
    }
  ],

  "dimensions": {
    "total_weight_kg": 300.0,
    "total_volume_m3": 0.15,
    "package_count": 3
  },

  "special_instructions": "Handle with care. Do not stack more than 2 layers.",
  "insurance_value": 18750.00,
  "currency": "USD",

  "created_at": ISODate("2024-02-14T10:00:00Z"),
  "updated_at": ISODate("2024-02-18T14:30:00Z"),
  "estimated_delivery_date": ISODate("2024-02-18T00:00:00Z"),
  "actual_delivery_date": ISODate("2024-02-18T14:30:00Z")  // null until delivered
}
*/

// ─────────────────────────────────────────────────────────────────────────────
// DESIGN DECISIONS
// ─────────────────────────────────────────────────────────────────────────────
/*
1.  CARRIER IS EMBEDDED (not a reference):
    - Carrier data changes rarely; denormalization avoids a second collection lookup
      on every shipment read (most frequent operation in tracking UIs).
    - If carrier details change, the application updates both the carrier master
      and the embedded copy on relevant active shipments (acceptable tradeoff).

2.  TRACKING_EVENTS IS AN ARRAY WITHIN THE DOCUMENT:
    - Typical shipment has 5–15 events (well within MongoDB's 16MB document limit).
    - Append-only: events are only added, never modified.
    - Alternative considered: separate `tracking_events` collection — rejected
      because it requires two reads for the most common query pattern
      (fetch shipment + its events together).

3.  ROUTE.ORIGIN / ROUTE.DESTINATION ARE EMBEDDED:
    - Snapshot of warehouse/address at time of shipment creation.
    - Decoupled from live warehouse data — shipment history stays accurate even
      if warehouse address changes later.

4.  LINE_ITEMS IS EMBEDDED:
    - Snapshot of what was physically shipped. Decoupled from live order lines.
    - Quantity in shipment may differ from order quantity (partial shipments).

5.  CROSS-SERVICE REFERENCES (order_id, customer_id, warehouse_id):
    - Stored as plain UUID strings (no $ref or DBRef).
    - No cascading FK enforcement — microservice boundary is respected.
    - order_number and customer_name are denormalized to support UI display
      without cross-service API calls on the read path.
*/
