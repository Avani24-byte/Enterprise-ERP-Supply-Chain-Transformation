// =============================================================================
// Logistics Service — MongoDB Seed Data
// Collection : shipments (db: logistics_db)
// Records    : 15 shipment documents with realistic tracking event arrays
// Author     : Misba (Database Engineer)
//
// Run via:
//   mongosh logistics_db seed_data.js
// =============================================================================

// Clear existing seed data (safe — only used in dev/demo environments)
db.shipments.deleteMany({ shipment_number: /^SHP-2024-/ });
print("Cleared existing SHP-2024- seed shipments.");

// ─────────────────────────────────────────────────────────────────────────────
// Helper: build a tracking event entry
// ─────────────────────────────────────────────────────────────────────────────
function trackingEvent(status, location, city, country, description, updatedBy, isoDateStr, lat, lng) {
  return {
    event_id: new ObjectId(),
    timestamp: new Date(isoDateStr),
    status: status,
    location: location,
    city: city,
    country: country,
    description: description,
    updated_by: updatedBy,
    latitude: lat || null,
    longitude: lng || null
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// SEED DOCUMENTS
// order_id references SO UUIDs from Order service seed (j0000000-... prefix)
// warehouse_id references WH UUIDs from Inventory seed (f6000000-... prefix)
// ─────────────────────────────────────────────────────────────────────────────
const shipments = [

  // ── SHP-2024-0001 ── SO-2024-0001 (L&T, Mumbai, DELIVERED) ────────────────
  {
    shipment_number: "SHP-2024-0001",
    order_id: "j0000000-0000-0000-0000-000000000001",
    order_number: "SO-2024-0001",
    customer_id: "k1000000-0000-0000-0000-000000000001",
    customer_name: "Larsen & Toubro Engineering Ltd.",
    status: "DELIVERED",
    carrier: {
      carrier_id: "carrier-001",
      name: "FedEx India",
      code: "FEDEX",
      tracking_number: "FX789456123001",
      service_type: "EXPRESS",
      contact_phone: "+91-1800-419-4343",
      contact_email: "support@fedex.in"
    },
    route: {
      origin: {
        warehouse_id: "f6000000-0000-0000-0000-000000000001",
        warehouse_code: "WH-MUM-01",
        warehouse_name: "Mumbai Central Warehouse",
        address: "Plot 12-A, MIDC Taloja, Navi Mumbai",
        city: "Navi Mumbai", state: "Maharashtra", country: "IN",
        departed_at: new Date("2024-02-15T08:30:00Z")
      },
      destination: {
        address: "L&T Powai Campus, Mumbai 400072",
        city: "Mumbai", state: "Maharashtra", country: "IN",
        contact_name: "Vikram Joshi", contact_phone: "+91-22-6752-5656",
        estimated_arrival: new Date("2024-02-18T18:00:00Z"),
        actual_arrival: new Date("2024-02-18T14:30:00Z")
      },
      waypoints: [
        { location: "FedEx Mumbai Hub, Andheri", city: "Mumbai", country: "IN",
          arrived_at: new Date("2024-02-15T11:00:00Z"),
          departed_at: new Date("2024-02-15T14:00:00Z") }
      ]
    },
    line_items: [
      { sku: "STL-HR-6MM", product_name: "Hot-Rolled Steel Sheet 6mm",
        quantity: 300, unit_of_measure: "KG", weight_kg: 300.0, volume_m3: 0.15 }
    ],
    tracking_events: [
      trackingEvent("PICKED_UP", "WH-MUM-01, Navi Mumbai", "Navi Mumbai", "IN",
        "Shipment picked up from origin warehouse", "WAREHOUSE_STAFF",
        "2024-02-15T08:30:00Z", 19.0596, 73.0631),
      trackingEvent("IN_TRANSIT", "FedEx Hub, Andheri", "Mumbai", "IN",
        "Package arrived at transit hub", "CARRIER_API",
        "2024-02-15T11:00:00Z", 19.1136, 72.8697),
      trackingEvent("OUT_FOR_DELIVERY", "FedEx Powai Delivery, Mumbai", "Mumbai", "IN",
        "Out for delivery to recipient", "CARRIER_API",
        "2024-02-18T09:00:00Z", 19.1176, 72.9060),
      trackingEvent("DELIVERED", "L&T Powai Campus", "Mumbai", "IN",
        "Delivered — signed by Vikram Joshi", "CARRIER_API",
        "2024-02-18T14:30:00Z", 19.1176, 72.9060)
    ],
    dimensions: { total_weight_kg: 300.0, total_volume_m3: 0.15, package_count: 3 },
    special_instructions: null, insurance_value: 18750.00, currency: "USD",
    created_at: new Date("2024-02-14T10:00:00Z"),
    updated_at: new Date("2024-02-18T14:30:00Z"),
    estimated_delivery_date: new Date("2024-02-18"),
    actual_delivery_date: new Date("2024-02-18")
  },

  // ── SHP-2024-0002 ── SO-2024-0002 (Infosys, Bengaluru, DELIVERED) ─────────
  {
    shipment_number: "SHP-2024-0002",
    order_id: "j0000000-0000-0000-0000-000000000002",
    order_number: "SO-2024-0002",
    customer_id: "k1000000-0000-0000-0000-000000000002",
    customer_name: "Infosys BPM Limited",
    status: "DELIVERED",
    carrier: {
      carrier_id: "carrier-002",
      name: "DHL Express India",
      code: "DHL",
      tracking_number: "DHL234567890002",
      service_type: "EXPRESS",
      contact_phone: "+91-124-2313666",
      contact_email: "support@dhl.in"
    },
    route: {
      origin: {
        warehouse_id: "f6000000-0000-0000-0000-000000000002",
        warehouse_code: "WH-BLR-01",
        warehouse_name: "Bengaluru Tech Park Warehouse",
        address: "Unit 7, Electronics City Phase 2, Bengaluru",
        city: "Bengaluru", state: "Karnataka", country: "IN",
        departed_at: new Date("2024-02-20T09:00:00Z")
      },
      destination: {
        address: "Infosys Campus, Hosur Road, Bengaluru 560100",
        city: "Bengaluru", state: "Karnataka", country: "IN",
        contact_name: "Ananya Krishnan", contact_phone: "+91-80-2852-0261",
        estimated_arrival: new Date("2024-02-26T17:00:00Z"),
        actual_arrival: new Date("2024-02-26T13:00:00Z")
      },
      waypoints: []
    },
    line_items: [
      { sku: "ELEC-CB-001", product_name: "Industrial Circuit Board CB-2024",
        quantity: 20, unit_of_measure: "EACH", weight_kg: 4.0, volume_m3: 0.008 },
      { sku: "ELEC-SENS-T01", product_name: "Temperature Sensor NTC 10K",
        quantity: 50, unit_of_measure: "EACH", weight_kg: 0.5, volume_m3: 0.001 }
    ],
    tracking_events: [
      trackingEvent("PICKED_UP", "WH-BLR-01, Electronics City", "Bengaluru", "IN",
        "Picked up from warehouse", "WAREHOUSE_STAFF", "2024-02-20T09:00:00Z", 12.8456, 77.6603),
      trackingEvent("IN_TRANSIT", "DHL Bengaluru Sort Center", "Bengaluru", "IN",
        "At DHL sort center", "CARRIER_API", "2024-02-20T11:30:00Z", 12.9716, 77.5946),
      trackingEvent("OUT_FOR_DELIVERY", "DHL Delivery, Koramangala", "Bengaluru", "IN",
        "Out for delivery", "CARRIER_API", "2024-02-26T08:00:00Z", 12.9352, 77.6245),
      trackingEvent("DELIVERED", "Infosys Campus, Hosur Road", "Bengaluru", "IN",
        "Delivered — received by security", "CARRIER_API", "2024-02-26T13:00:00Z", 12.8399, 77.6770)
    ],
    dimensions: { total_weight_kg: 4.5, total_volume_m3: 0.009, package_count: 2 },
    special_instructions: "Fragile electronics — handle with care",
    insurance_value: 17500.00, currency: "USD",
    created_at: new Date("2024-02-19T11:00:00Z"),
    updated_at: new Date("2024-02-26T13:00:00Z"),
    estimated_delivery_date: new Date("2024-02-26"),
    actual_delivery_date: new Date("2024-02-26")
  },

  // ── SHP-2024-0003 ── SO-2024-0003 (Mahindra, Pune, DELIVERED) ────────────
  {
    shipment_number: "SHP-2024-0003",
    order_id: "j0000000-0000-0000-0000-000000000003",
    order_number: "SO-2024-0003",
    customer_id: "k1000000-0000-0000-0000-000000000003",
    customer_name: "Mahindra Auto Components",
    status: "DELIVERED",
    carrier: {
      carrier_id: "carrier-003", name: "Blue Dart", code: "BLUEDART",
      tracking_number: "BD123456789003", service_type: "STANDARD",
      contact_phone: "+91-1860-233-1234", contact_email: "care@bluedart.com"
    },
    route: {
      origin: {
        warehouse_id: "f6000000-0000-0000-0000-000000000001",
        warehouse_code: "WH-MUM-01", warehouse_name: "Mumbai Central Warehouse",
        address: "Plot 12-A, MIDC Taloja, Navi Mumbai",
        city: "Navi Mumbai", state: "Maharashtra", country: "IN",
        departed_at: new Date("2024-03-10T07:00:00Z")
      },
      destination: {
        address: "Mahindra Chakan Plant, Pune 410501",
        city: "Pune", state: "Maharashtra", country: "IN",
        contact_name: "Sunil Pawar", contact_phone: "+91-20-6600-1000",
        estimated_arrival: new Date("2024-03-14T18:00:00Z"),
        actual_arrival: new Date("2024-03-14T15:00:00Z")
      },
      waypoints: [
        { location: "Blue Dart Pune Hub", city: "Pune", country: "IN",
          arrived_at: new Date("2024-03-12T10:00:00Z"),
          departed_at: new Date("2024-03-12T14:00:00Z") }
      ]
    },
    line_items: [
      { sku: "MECH-BRNG-6204", product_name: "Deep Groove Ball Bearing 6204",
        quantity: 100, unit_of_measure: "EACH", weight_kg: 8.0, volume_m3: 0.01 }
    ],
    tracking_events: [
      trackingEvent("PICKED_UP", "WH-MUM-01", "Navi Mumbai", "IN",
        "Bearings picked up", "WAREHOUSE_STAFF", "2024-03-10T07:00:00Z", 19.0596, 73.0631),
      trackingEvent("IN_TRANSIT", "Blue Dart Pune Hub", "Pune", "IN",
        "In transit to Pune", "CARRIER_API", "2024-03-12T10:00:00Z", 18.5204, 73.8567),
      trackingEvent("DELIVERED", "Mahindra Chakan Plant", "Pune", "IN",
        "Delivered to plant gate", "CARRIER_API", "2024-03-14T15:00:00Z", 18.7604, 73.8647)
    ],
    dimensions: { total_weight_kg: 8.0, total_volume_m3: 0.01, package_count: 2 },
    special_instructions: null, insurance_value: 11500.00, currency: "USD",
    created_at: new Date("2024-03-09T09:00:00Z"),
    updated_at: new Date("2024-03-14T15:00:00Z"),
    estimated_delivery_date: new Date("2024-03-14"),
    actual_delivery_date: new Date("2024-03-14")
  },

  // ── SHP-2024-0004 ── SO-2024-0004 (Asian Paints, Mumbai, DELIVERED) ───────
  {
    shipment_number: "SHP-2024-0004",
    order_id: "j0000000-0000-0000-0000-000000000004",
    order_number: "SO-2024-0004",
    customer_id: "k1000000-0000-0000-0000-000000000004",
    customer_name: "Asian Paints Distribution Hub",
    status: "DELIVERED",
    carrier: {
      carrier_id: "carrier-002", name: "DHL Express India", code: "DHL",
      tracking_number: "DHL234567890004", service_type: "FREIGHT",
      contact_phone: "+91-124-2313666", contact_email: "support@dhl.in"
    },
    route: {
      origin: {
        warehouse_id: "f6000000-0000-0000-0000-000000000002",
        warehouse_code: "WH-BLR-01", warehouse_name: "Bengaluru Tech Park Warehouse",
        address: "Unit 7, Electronics City Phase 2, Bengaluru",
        city: "Bengaluru", state: "Karnataka", country: "IN",
        departed_at: new Date("2024-03-12T06:00:00Z")
      },
      destination: {
        address: "Asian Paints Andheri Warehouse, Mumbai 400099",
        city: "Mumbai", state: "Maharashtra", country: "IN",
        contact_name: "Pooja Agarwal", contact_phone: "+91-22-6218-1000",
        estimated_arrival: new Date("2024-03-17T18:00:00Z"),
        actual_arrival: new Date("2024-03-17T16:00:00Z")
      },
      waypoints: [
        { location: "DHL Mumbai Freight Terminal", city: "Mumbai", country: "IN",
          arrived_at: new Date("2024-03-15T08:00:00Z"),
          departed_at: new Date("2024-03-15T16:00:00Z") }
      ]
    },
    line_items: [
      { sku: "POLY-HDPE-001", product_name: "HDPE Resin Granules Natural",
        quantity: 2000, unit_of_measure: "KG", weight_kg: 2000.0, volume_m3: 2.0 }
    ],
    tracking_events: [
      trackingEvent("PICKED_UP", "WH-BLR-01", "Bengaluru", "IN",
        "Freight pickup — 2000kg HDPE resin", "WAREHOUSE_STAFF", "2024-03-12T06:00:00Z"),
      trackingEvent("IN_TRANSIT", "DHL Mumbai Freight Terminal", "Mumbai", "IN",
        "Arrived at Mumbai freight terminal", "CARRIER_API", "2024-03-15T08:00:00Z"),
      trackingEvent("DELIVERED", "Asian Paints Andheri Warehouse", "Mumbai", "IN",
        "Freight delivered — 2000kg confirmed", "CARRIER_API", "2024-03-17T16:00:00Z")
    ],
    dimensions: { total_weight_kg: 2000.0, total_volume_m3: 2.0, package_count: 20 },
    special_instructions: "Store in cool dry place, max 35°C",
    insurance_value: 28000.00, currency: "USD",
    created_at: new Date("2024-03-11T10:00:00Z"),
    updated_at: new Date("2024-03-17T16:00:00Z"),
    estimated_delivery_date: new Date("2024-03-17"),
    actual_delivery_date: new Date("2024-03-17")
  },

  // ── SHP-2024-0005 ── SO-2024-0005 (L&T, Mumbai, IN_TRANSIT) ──────────────
  {
    shipment_number: "SHP-2024-0005",
    order_id: "j0000000-0000-0000-0000-000000000005",
    order_number: "SO-2024-0005",
    customer_id: "k1000000-0000-0000-0000-000000000001",
    customer_name: "Larsen & Toubro Engineering Ltd.",
    status: "IN_TRANSIT",
    carrier: {
      carrier_id: "carrier-001", name: "FedEx India", code: "FEDEX",
      tracking_number: "FX789456123005", service_type: "EXPRESS",
      contact_phone: "+91-1800-419-4343", contact_email: "support@fedex.in"
    },
    route: {
      origin: {
        warehouse_id: "f6000000-0000-0000-0000-000000000001",
        warehouse_code: "WH-MUM-01", warehouse_name: "Mumbai Central Warehouse",
        address: "Plot 12-A, MIDC Taloja, Navi Mumbai",
        city: "Navi Mumbai", state: "Maharashtra", country: "IN",
        departed_at: new Date("2024-04-18T07:00:00Z")
      },
      destination: {
        address: "L&T Powai Campus, Mumbai 400072",
        city: "Mumbai", state: "Maharashtra", country: "IN",
        contact_name: "Vikram Joshi", contact_phone: "+91-22-6752-5656",
        estimated_arrival: new Date("2024-04-25T18:00:00Z"),
        actual_arrival: null
      },
      waypoints: []
    },
    line_items: [
      { sku: "STL-HR-6MM", product_name: "Hot-Rolled Steel Sheet 6mm",
        quantity: 400, unit_of_measure: "KG", weight_kg: 400.0, volume_m3: 0.2 }
    ],
    tracking_events: [
      trackingEvent("PICKED_UP", "WH-MUM-01", "Navi Mumbai", "IN",
        "400kg steel picked up", "WAREHOUSE_STAFF", "2024-04-18T07:00:00Z"),
      trackingEvent("IN_TRANSIT", "FedEx Mumbai Hub", "Mumbai", "IN",
        "In transit — on schedule", "CARRIER_API", "2024-04-18T11:00:00Z")
    ],
    dimensions: { total_weight_kg: 400.0, total_volume_m3: 0.2, package_count: 4 },
    special_instructions: null, insurance_value: 25000.00, currency: "USD",
    created_at: new Date("2024-04-17T09:00:00Z"),
    updated_at: new Date("2024-04-18T11:00:00Z"),
    estimated_delivery_date: new Date("2024-04-25"),
    actual_delivery_date: null
  },

  // ── SHP-2024-0006 ── SO-2024-0007 (Bosch, Nasik, DELIVERED) ─────────────
  {
    shipment_number: "SHP-2024-0006",
    order_id: "j0000000-0000-0000-0000-000000000007",
    order_number: "SO-2024-0007",
    customer_id: "k1000000-0000-0000-0000-000000000007",
    customer_name: "Bosch India Automotive",
    status: "DELIVERED",
    carrier: {
      carrier_id: "carrier-003", name: "Blue Dart", code: "BLUEDART",
      tracking_number: "BD123456789006", service_type: "STANDARD",
      contact_phone: "+91-1860-233-1234", contact_email: "care@bluedart.com"
    },
    route: {
      origin: {
        warehouse_id: "f6000000-0000-0000-0000-000000000002",
        warehouse_code: "WH-BLR-01", warehouse_name: "Bengaluru Tech Park Warehouse",
        address: "Unit 7, Electronics City Phase 2", city: "Bengaluru",
        state: "Karnataka", country: "IN",
        departed_at: new Date("2024-04-15T08:00:00Z")
      },
      destination: {
        address: "Bosch Nasik Plant, Maharashtra 422010",
        city: "Nasik", state: "Maharashtra", country: "IN",
        contact_name: "Peter Maier", contact_phone: "+91-80-2299-2752",
        estimated_arrival: new Date("2024-04-20T18:00:00Z"),
        actual_arrival: new Date("2024-04-19T14:00:00Z")
      },
      waypoints: [
        { location: "Blue Dart Pune Hub", city: "Pune", country: "IN",
          arrived_at: new Date("2024-04-17T09:00:00Z"),
          departed_at: new Date("2024-04-17T14:00:00Z") }
      ]
    },
    line_items: [
      { sku: "ELEC-MCU-001", product_name: "Microcontroller STM32F103",
        quantity: 30, unit_of_measure: "EACH", weight_kg: 0.3, volume_m3: 0.001 }
    ],
    tracking_events: [
      trackingEvent("PICKED_UP", "WH-BLR-01", "Bengaluru", "IN",
        "30 MCUs picked up", "WAREHOUSE_STAFF", "2024-04-15T08:00:00Z"),
      trackingEvent("IN_TRANSIT", "Blue Dart Pune Hub", "Pune", "IN",
        "At Pune transit hub", "CARRIER_API", "2024-04-17T09:00:00Z"),
      trackingEvent("OUT_FOR_DELIVERY", "Blue Dart Nasik", "Nasik", "IN",
        "Out for delivery to Bosch plant", "CARRIER_API", "2024-04-19T09:00:00Z"),
      trackingEvent("DELIVERED", "Bosch Nasik Plant", "Nasik", "IN",
        "Delivered — received by plant security", "CARRIER_API", "2024-04-19T14:00:00Z")
    ],
    dimensions: { total_weight_kg: 0.3, total_volume_m3: 0.001, package_count: 1 },
    special_instructions: "Electrostatic sensitive — ESD packaging required",
    insurance_value: 9600.00, currency: "USD",
    created_at: new Date("2024-04-14T11:00:00Z"),
    updated_at: new Date("2024-04-19T14:00:00Z"),
    estimated_delivery_date: new Date("2024-04-20"),
    actual_delivery_date: new Date("2024-04-19")
  },

  // ── SHP-2024-0007 ── SO-2024-0008 (Asian Paints, Mumbai, DELIVERED) ───────
  {
    shipment_number: "SHP-2024-0007",
    order_id: "j0000000-0000-0000-0000-000000000008",
    order_number: "SO-2024-0008",
    customer_id: "k1000000-0000-0000-0000-000000000004",
    customer_name: "Asian Paints Distribution Hub",
    status: "DELIVERED",
    carrier: {
      carrier_id: "carrier-002", name: "DHL Express India", code: "DHL",
      tracking_number: "DHL234567890007", service_type: "FREIGHT",
      contact_phone: "+91-124-2313666", contact_email: "support@dhl.in"
    },
    route: {
      origin: {
        warehouse_id: "f6000000-0000-0000-0000-000000000002",
        warehouse_code: "WH-BLR-01", warehouse_name: "Bengaluru Tech Park Warehouse",
        address: "Unit 7, Electronics City Phase 2", city: "Bengaluru",
        state: "Karnataka", country: "IN", departed_at: new Date("2024-04-16T06:00:00Z")
      },
      destination: {
        address: "Asian Paints Andheri Warehouse, Mumbai 400099",
        city: "Mumbai", state: "Maharashtra", country: "IN",
        contact_name: "Pooja Agarwal", contact_phone: "+91-22-6218-1000",
        estimated_arrival: new Date("2024-04-22T18:00:00Z"),
        actual_arrival: new Date("2024-04-21T15:00:00Z")
      },
      waypoints: []
    },
    line_items: [
      { sku: "POLY-PP-001", product_name: "Polypropylene Resin Injection Grade",
        quantity: 800, unit_of_measure: "KG", weight_kg: 800.0, volume_m3: 0.9 }
    ],
    tracking_events: [
      trackingEvent("PICKED_UP", "WH-BLR-01", "Bengaluru", "IN",
        "800kg PP resin picked up", "WAREHOUSE_STAFF", "2024-04-16T06:00:00Z"),
      trackingEvent("IN_TRANSIT", "DHL Pune Hub", "Pune", "IN",
        "In transit via Pune", "CARRIER_API", "2024-04-18T10:00:00Z"),
      trackingEvent("DELIVERED", "Asian Paints Andheri Warehouse", "Mumbai", "IN",
        "PP resin delivered", "CARRIER_API", "2024-04-21T15:00:00Z")
    ],
    dimensions: { total_weight_kg: 800.0, total_volume_m3: 0.9, package_count: 8 },
    special_instructions: "Store away from heat sources",
    insurance_value: 13200.00, currency: "USD",
    created_at: new Date("2024-04-15T09:00:00Z"),
    updated_at: new Date("2024-04-21T15:00:00Z"),
    estimated_delivery_date: new Date("2024-04-22"),
    actual_delivery_date: new Date("2024-04-21")
  },

  // ── SHP-2024-0008 ── SO-2024-0009 (Mahindra, Pune, DELIVERED — low stock trigger) ──
  {
    shipment_number: "SHP-2024-0008",
    order_id: "j0000000-0000-0000-0000-000000000009",
    order_number: "SO-2024-0009",
    customer_id: "k1000000-0000-0000-0000-000000000003",
    customer_name: "Mahindra Auto Components",
    status: "DELIVERED",
    carrier: {
      carrier_id: "carrier-003", name: "Blue Dart", code: "BLUEDART",
      tracking_number: "BD123456789008", service_type: "EXPRESS",
      contact_phone: "+91-1860-233-1234", contact_email: "care@bluedart.com"
    },
    route: {
      origin: {
        warehouse_id: "f6000000-0000-0000-0000-000000000003",
        warehouse_code: "WH-DEL-01", warehouse_name: "Delhi NCR Distribution Centre",
        address: "45, Udyog Vihar Phase 4, Gurugram",
        city: "Gurugram", state: "Haryana", country: "IN",
        departed_at: new Date("2024-04-25T09:00:00Z")
      },
      destination: {
        address: "Mahindra Chakan Plant, Pune 410501",
        city: "Pune", state: "Maharashtra", country: "IN",
        contact_name: "Sunil Pawar", contact_phone: "+91-20-6600-1000",
        estimated_arrival: new Date("2024-04-30T18:00:00Z"),
        actual_arrival: new Date("2024-04-29T13:00:00Z")
      },
      waypoints: [
        { location: "Blue Dart Mumbai Hub", city: "Mumbai", country: "IN",
          arrived_at: new Date("2024-04-27T08:00:00Z"),
          departed_at: new Date("2024-04-27T16:00:00Z") }
      ]
    },
    line_items: [
      { sku: "MECH-BRNG-6204", product_name: "Deep Groove Ball Bearing 6204",
        quantity: 58, unit_of_measure: "EACH", weight_kg: 4.64, volume_m3: 0.006 }
    ],
    tracking_events: [
      trackingEvent("PICKED_UP", "WH-DEL-01, Gurugram", "Gurugram", "IN",
        "58 bearings picked up — stock now below reorder point", "WAREHOUSE_STAFF",
        "2024-04-25T09:00:00Z"),
      trackingEvent("IN_TRANSIT", "Blue Dart Mumbai Hub", "Mumbai", "IN",
        "Passing through Mumbai hub", "CARRIER_API", "2024-04-27T08:00:00Z"),
      trackingEvent("OUT_FOR_DELIVERY", "Blue Dart Pune", "Pune", "IN",
        "Out for delivery", "CARRIER_API", "2024-04-29T08:00:00Z"),
      trackingEvent("DELIVERED", "Mahindra Chakan Plant", "Pune", "IN",
        "Delivered and signed", "CARRIER_API", "2024-04-29T13:00:00Z")
    ],
    dimensions: { total_weight_kg: 4.64, total_volume_m3: 0.006, package_count: 1 },
    special_instructions: null, insurance_value: 6670.00, currency: "USD",
    created_at: new Date("2024-04-24T14:00:00Z"),
    updated_at: new Date("2024-04-29T13:00:00Z"),
    estimated_delivery_date: new Date("2024-04-30"),
    actual_delivery_date: new Date("2024-04-29")
  },

  // ── SHP-2024-0009 ── SO-2024-0010 (Flipkart, Gurugram, IN_TRANSIT) ────────
  {
    shipment_number: "SHP-2024-0009",
    order_id: "j0000000-0000-0000-0000-000000000010",
    order_number: "SO-2024-0010",
    customer_id: "k1000000-0000-0000-0000-000000000008",
    customer_name: "Flipkart Logistics Pvt. Ltd.",
    status: "OUT_FOR_DELIVERY",
    carrier: {
      carrier_id: "carrier-001", name: "FedEx India", code: "FEDEX",
      tracking_number: "FX789456123009", service_type: "EXPRESS",
      contact_phone: "+91-1800-419-4343", contact_email: "support@fedex.in"
    },
    route: {
      origin: {
        warehouse_id: "f6000000-0000-0000-0000-000000000001",
        warehouse_code: "WH-MUM-01", warehouse_name: "Mumbai Central Warehouse",
        address: "Plot 12-A, MIDC Taloja", city: "Navi Mumbai",
        state: "Maharashtra", country: "IN",
        departed_at: new Date("2024-04-26T06:00:00Z")
      },
      destination: {
        address: "Flipkart Bilaspur Warehouse, Gurugram 122001",
        city: "Gurugram", state: "Haryana", country: "IN",
        contact_name: "Rahul Sharma", contact_phone: "+91-80-4908-3910",
        estimated_arrival: new Date("2024-05-04T18:00:00Z"),
        actual_arrival: null
      },
      waypoints: [
        { location: "FedEx Delhi Hub", city: "Delhi", country: "IN",
          arrived_at: new Date("2024-04-28T06:00:00Z"),
          departed_at: new Date("2024-04-28T18:00:00Z") }
      ]
    },
    line_items: [
      { sku: "PKG-CORR-A4", product_name: "Corrugated Box A4 Size",
        quantity: 2000, unit_of_measure: "EACH", weight_kg: 120.0, volume_m3: 4.0 }
    ],
    tracking_events: [
      trackingEvent("PICKED_UP", "WH-MUM-01", "Navi Mumbai", "IN",
        "2000 corrugated boxes picked up", "WAREHOUSE_STAFF", "2024-04-26T06:00:00Z"),
      trackingEvent("IN_TRANSIT", "FedEx Delhi Hub", "Delhi", "IN",
        "Cleared Delhi hub", "CARRIER_API", "2024-04-28T06:00:00Z"),
      trackingEvent("OUT_FOR_DELIVERY", "FedEx Gurugram", "Gurugram", "IN",
        "Out for delivery to Flipkart warehouse", "CARRIER_API", "2024-05-03T09:00:00Z")
    ],
    dimensions: { total_weight_kg: 120.0, total_volume_m3: 4.0, package_count: 10 },
    special_instructions: null, insurance_value: 25000.00, currency: "USD",
    created_at: new Date("2024-04-25T10:00:00Z"),
    updated_at: new Date("2024-05-03T09:00:00Z"),
    estimated_delivery_date: new Date("2024-05-04"),
    actual_delivery_date: null
  },

  // ── SHP-2024-0010 ── SO-2024-0016 (Flipkart, DELIVERED, Q1 large) ─────────
  {
    shipment_number: "SHP-2024-0010",
    order_id: "j0000000-0000-0000-0000-000000000016",
    order_number: "SO-2024-0016",
    customer_id: "k1000000-0000-0000-0000-000000000008",
    customer_name: "Flipkart Logistics Pvt. Ltd.",
    status: "DELIVERED",
    carrier: {
      carrier_id: "carrier-002", name: "DHL Express India", code: "DHL",
      tracking_number: "DHL234567890010", service_type: "FREIGHT",
      contact_phone: "+91-124-2313666", contact_email: "support@dhl.in"
    },
    route: {
      origin: {
        warehouse_id: "f6000000-0000-0000-0000-000000000001",
        warehouse_code: "WH-MUM-01", warehouse_name: "Mumbai Central Warehouse",
        address: "Plot 12-A, MIDC Taloja", city: "Navi Mumbai",
        state: "Maharashtra", country: "IN",
        departed_at: new Date("2024-03-16T05:00:00Z")
      },
      destination: {
        address: "Flipkart Bilaspur Warehouse, Gurugram 122001",
        city: "Gurugram", state: "Haryana", country: "IN",
        contact_name: "Rahul Sharma", contact_phone: "+91-80-4908-3910",
        estimated_arrival: new Date("2024-03-25T18:00:00Z"),
        actual_arrival: new Date("2024-03-24T14:00:00Z")
      },
      waypoints: [
        { location: "DHL Delhi Freight Terminal", city: "Delhi", country: "IN",
          arrived_at: new Date("2024-03-19T08:00:00Z"),
          departed_at: new Date("2024-03-20T06:00:00Z") }
      ]
    },
    line_items: [
      { sku: "PKG-CORR-A4", product_name: "Corrugated Box A4 Size",
        quantity: 3000, unit_of_measure: "EACH", weight_kg: 180.0, volume_m3: 6.0 },
      { sku: "POLY-HDPE-001", product_name: "HDPE Resin Granules Natural",
        quantity: 1000, unit_of_measure: "KG", weight_kg: 1000.0, volume_m3: 1.0 }
    ],
    tracking_events: [
      trackingEvent("PICKED_UP", "WH-MUM-01", "Navi Mumbai", "IN",
        "Large freight pickup — 3000 boxes + 1000kg HDPE", "WAREHOUSE_STAFF",
        "2024-03-16T05:00:00Z"),
      trackingEvent("IN_TRANSIT", "DHL Delhi Freight Terminal", "Delhi", "IN",
        "At Delhi freight terminal", "CARRIER_API", "2024-03-19T08:00:00Z"),
      trackingEvent("DELIVERED", "Flipkart Bilaspur Warehouse", "Gurugram", "IN",
        "Full shipment delivered — POD received", "CARRIER_API", "2024-03-24T14:00:00Z")
    ],
    dimensions: { total_weight_kg: 1180.0, total_volume_m3: 7.0, package_count: 32 },
    special_instructions: null, insurance_value: 55000.00, currency: "USD",
    created_at: new Date("2024-03-15T08:00:00Z"),
    updated_at: new Date("2024-03-24T14:00:00Z"),
    estimated_delivery_date: new Date("2024-03-25"),
    actual_delivery_date: new Date("2024-03-24")
  },

  // ── SHP-2024-0011 ── SO-2024-0017 (Sun Pharma, Gujarat, DELIVERED) ─────────
  {
    shipment_number: "SHP-2024-0011",
    order_id: "j0000000-0000-0000-0000-000000000017",
    order_number: "SO-2024-0017",
    customer_id: "k1000000-0000-0000-0000-000000000005",
    customer_name: "Sun Pharmaceutical Industries",
    status: "DELIVERED",
    carrier: {
      carrier_id: "carrier-001", name: "FedEx India", code: "FEDEX",
      tracking_number: "FX789456123011", service_type: "FREIGHT",
      contact_phone: "+91-1800-419-4343", contact_email: "support@fedex.in"
    },
    route: {
      origin: {
        warehouse_id: "f6000000-0000-0000-0000-000000000002",
        warehouse_code: "WH-BLR-01", warehouse_name: "Bengaluru Tech Park Warehouse",
        address: "Unit 7, Electronics City Phase 2", city: "Bengaluru",
        state: "Karnataka", country: "IN", departed_at: new Date("2024-03-19T06:00:00Z")
      },
      destination: {
        address: "Sun Pharma Halol Plant, Panchmahal, Gujarat 389350",
        city: "Halol", state: "Gujarat", country: "IN",
        contact_name: "Dr. Rohit Shah", contact_phone: "+91-22-4324-4324",
        estimated_arrival: new Date("2024-03-28T18:00:00Z"),
        actual_arrival: new Date("2024-03-27T12:00:00Z")
      },
      waypoints: [
        { location: "FedEx Surat Hub", city: "Surat", country: "IN",
          arrived_at: new Date("2024-03-22T09:00:00Z"),
          departed_at: new Date("2024-03-22T16:00:00Z") }
      ]
    },
    line_items: [
      { sku: "POLY-HDPE-001", product_name: "HDPE Resin Granules Natural",
        quantity: 1500, unit_of_measure: "KG", weight_kg: 1500.0, volume_m3: 1.5 },
      { sku: "POLY-PP-001", product_name: "Polypropylene Resin Injection Grade",
        quantity: 700, unit_of_measure: "KG", weight_kg: 700.0, volume_m3: 0.8 }
    ],
    tracking_events: [
      trackingEvent("PICKED_UP", "WH-BLR-01", "Bengaluru", "IN",
        "Pharma-grade polymer pickup", "WAREHOUSE_STAFF", "2024-03-19T06:00:00Z"),
      trackingEvent("IN_TRANSIT", "FedEx Surat Hub", "Surat", "IN",
        "Cleared Surat hub", "CARRIER_API", "2024-03-22T09:00:00Z"),
      trackingEvent("DELIVERED", "Sun Pharma Halol Plant", "Halol", "IN",
        "Polymer resins delivered to plant", "CARRIER_API", "2024-03-27T12:00:00Z")
    ],
    dimensions: { total_weight_kg: 2200.0, total_volume_m3: 2.3, package_count: 22 },
    special_instructions: "GMP-compliant handling required. Temperature max 30°C.",
    insurance_value: 35000.00, currency: "USD",
    created_at: new Date("2024-03-18T10:00:00Z"),
    updated_at: new Date("2024-03-27T12:00:00Z"),
    estimated_delivery_date: new Date("2024-03-28"),
    actual_delivery_date: new Date("2024-03-27")
  },

  // ── SHP-2024-0012 ── SO-2024-0018 (Godrej, PARTIALLY_SHIPPED) ─────────────
  {
    shipment_number: "SHP-2024-0012",
    order_id: "j0000000-0000-0000-0000-000000000018",
    order_number: "SO-2024-0018",
    customer_id: "k1000000-0000-0000-0000-000000000006",
    customer_name: "Godrej Consumer Products Ltd.",
    status: "DELIVERED",
    carrier: {
      carrier_id: "carrier-003", name: "Blue Dart", code: "BLUEDART",
      tracking_number: "BD123456789012", service_type: "STANDARD",
      contact_phone: "+91-1860-233-1234", contact_email: "care@bluedart.com"
    },
    route: {
      origin: {
        warehouse_id: "f6000000-0000-0000-0000-000000000001",
        warehouse_code: "WH-MUM-01", warehouse_name: "Mumbai Central Warehouse",
        address: "Plot 12-A, MIDC Taloja", city: "Navi Mumbai",
        state: "Maharashtra", country: "IN", departed_at: new Date("2024-04-30T08:00:00Z")
      },
      destination: {
        address: "Godrej Vikhroli Distribution, Mumbai 400083",
        city: "Mumbai", state: "Maharashtra", country: "IN",
        contact_name: "Meera Thakkar", contact_phone: "+91-22-2518-8010",
        estimated_arrival: new Date("2024-05-05T18:00:00Z"),
        actual_arrival: new Date("2024-05-02T14:00:00Z")
      },
      waypoints: []
    },
    line_items: [
      { sku: "PKG-CORR-A4", product_name: "Corrugated Box A4 Size",
        quantity: 800, unit_of_measure: "EACH", weight_kg: 48.0, volume_m3: 1.6 }
    ],
    tracking_events: [
      trackingEvent("PICKED_UP", "WH-MUM-01", "Navi Mumbai", "IN",
        "Partial shipment — 800 boxes (first batch)", "WAREHOUSE_STAFF", "2024-04-30T08:00:00Z"),
      trackingEvent("DELIVERED", "Godrej Vikhroli Warehouse", "Mumbai", "IN",
        "Partial delivery accepted by Meera Thakkar", "CARRIER_API", "2024-05-02T14:00:00Z")
    ],
    dimensions: { total_weight_kg: 48.0, total_volume_m3: 1.6, package_count: 8 },
    special_instructions: "Partial order — remaining sensors in next shipment",
    insurance_value: 10000.00, currency: "USD",
    created_at: new Date("2024-04-29T11:00:00Z"),
    updated_at: new Date("2024-05-02T14:00:00Z"),
    estimated_delivery_date: new Date("2024-05-05"),
    actual_delivery_date: new Date("2024-05-02")
  },

  // ── SHP-2024-0013 ── FAILED_ATTEMPT demo ─────────────────────────────────
  {
    shipment_number: "SHP-2024-0013",
    order_id: "j0000000-0000-0000-0000-000000000011",
    order_number: "SO-2024-0011",
    customer_id: "k1000000-0000-0000-0000-000000000005",
    customer_name: "Sun Pharmaceutical Industries",
    status: "IN_TRANSIT",
    carrier: {
      carrier_id: "carrier-002", name: "DHL Express India", code: "DHL",
      tracking_number: "DHL234567890013", service_type: "FREIGHT",
      contact_phone: "+91-124-2313666", contact_email: "support@dhl.in"
    },
    route: {
      origin: {
        warehouse_id: "f6000000-0000-0000-0000-000000000001",
        warehouse_code: "WH-MUM-01", warehouse_name: "Mumbai Central Warehouse",
        address: "Plot 12-A, MIDC Taloja", city: "Navi Mumbai",
        state: "Maharashtra", country: "IN", departed_at: new Date("2024-05-03T06:00:00Z")
      },
      destination: {
        address: "Sun Pharma Halol Plant, Gujarat 389350",
        city: "Halol", state: "Gujarat", country: "IN",
        contact_name: "Dr. Rohit Shah", contact_phone: "+91-22-4324-4324",
        estimated_arrival: new Date("2024-05-12T18:00:00Z"),
        actual_arrival: null
      },
      waypoints: []
    },
    line_items: [
      { sku: "PKG-CORR-A4", product_name: "Corrugated Box A4 Size",
        quantity: 1500, unit_of_measure: "EACH", weight_kg: 90.0, volume_m3: 3.0 },
      { sku: "POLY-HDPE-001", product_name: "HDPE Resin Granules Natural",
        quantity: 2000, unit_of_measure: "KG", weight_kg: 2000.0, volume_m3: 2.0 }
    ],
    tracking_events: [
      trackingEvent("PICKED_UP", "WH-MUM-01", "Navi Mumbai", "IN",
        "Sun Pharma confirmed shipment picked up", "WAREHOUSE_STAFF", "2024-05-03T06:00:00Z"),
      trackingEvent("IN_TRANSIT", "DHL Surat Hub", "Surat", "IN",
        "At Surat hub — on schedule", "CARRIER_API", "2024-05-06T08:00:00Z")
    ],
    dimensions: { total_weight_kg: 2090.0, total_volume_m3: 5.0, package_count: 22 },
    special_instructions: "GMP handling. Temperature 20-25°C.",
    insurance_value: 42000.00, currency: "USD",
    created_at: new Date("2024-05-02T10:00:00Z"),
    updated_at: new Date("2024-05-06T08:00:00Z"),
    estimated_delivery_date: new Date("2024-05-12"),
    actual_delivery_date: null
  },

  // ── SHP-2024-0014 ── CANCELLED demo ──────────────────────────────────────
  {
    shipment_number: "SHP-2024-0014",
    order_id: "j0000000-0000-0000-0000-000000000015",
    order_number: "SO-2024-0015",
    customer_id: "k1000000-0000-0000-0000-000000000003",
    customer_name: "Mahindra Auto Components",
    status: "CANCELLED",
    carrier: {
      carrier_id: "carrier-003", name: "Blue Dart", code: "BLUEDART",
      tracking_number: null, service_type: "STANDARD",
      contact_phone: "+91-1860-233-1234", contact_email: "care@bluedart.com"
    },
    route: {
      origin: {
        warehouse_id: "f6000000-0000-0000-0000-000000000001",
        warehouse_code: "WH-MUM-01", warehouse_name: "Mumbai Central Warehouse",
        address: "Plot 12-A, MIDC Taloja", city: "Navi Mumbai",
        state: "Maharashtra", country: "IN", departed_at: null
      },
      destination: {
        address: "Mahindra Chakan Plant, Pune 410501",
        city: "Pune", state: "Maharashtra", country: "IN",
        contact_name: "Sunil Pawar", contact_phone: "+91-20-6600-1000",
        estimated_arrival: null, actual_arrival: null
      },
      waypoints: []
    },
    line_items: [
      { sku: "MECH-BRNG-6204", product_name: "Deep Groove Ball Bearing 6204",
        quantity: 78, unit_of_measure: "EACH", weight_kg: 6.24, volume_m3: 0.008 }
    ],
    tracking_events: [
      trackingEvent("CANCELLED", "WH-MUM-01 — Never dispatched", "Navi Mumbai", "IN",
        "Shipment cancelled — sales order cancelled by customer", "MANUAL",
        "2024-04-03T10:00:00Z")
    ],
    dimensions: { total_weight_kg: 6.24, total_volume_m3: 0.008, package_count: 1 },
    special_instructions: null, insurance_value: 0.00, currency: "USD",
    created_at: new Date("2024-04-02T09:00:00Z"),
    updated_at: new Date("2024-04-03T10:00:00Z"),
    estimated_delivery_date: null,
    actual_delivery_date: null
  },

  // ── SHP-2024-0015 ── SO-2024-0020 (Infosys MCU, DELIVERED) ───────────────
  {
    shipment_number: "SHP-2024-0015",
    order_id: "j0000000-0000-0000-0000-000000000020",
    order_number: "SO-2024-0020",
    customer_id: "k1000000-0000-0000-0000-000000000002",
    customer_name: "Infosys BPM Limited",
    status: "DELIVERED",
    carrier: {
      carrier_id: "carrier-001", name: "FedEx India", code: "FEDEX",
      tracking_number: "FX789456123015", service_type: "EXPRESS",
      contact_phone: "+91-1800-419-4343", contact_email: "support@fedex.in"
    },
    route: {
      origin: {
        warehouse_id: "f6000000-0000-0000-0000-000000000002",
        warehouse_code: "WH-BLR-01", warehouse_name: "Bengaluru Tech Park Warehouse",
        address: "Unit 7, Electronics City Phase 2", city: "Bengaluru",
        state: "Karnataka", country: "IN", departed_at: new Date("2024-05-03T09:00:00Z")
      },
      destination: {
        address: "Infosys Campus, Hosur Road, Bengaluru 560100",
        city: "Bengaluru", state: "Karnataka", country: "IN",
        contact_name: "Ananya Krishnan", contact_phone: "+91-80-2852-0261",
        estimated_arrival: new Date("2024-05-10T17:00:00Z"),
        actual_arrival: new Date("2024-05-09T13:00:00Z")
      },
      waypoints: []
    },
    line_items: [
      { sku: "ELEC-MCU-001", product_name: "Microcontroller STM32F103",
        quantity: 40, unit_of_measure: "EACH", weight_kg: 0.4, volume_m3: 0.001 }
    ],
    tracking_events: [
      trackingEvent("PICKED_UP", "WH-BLR-01", "Bengaluru", "IN",
        "40 MCUs — ESD packaging confirmed", "WAREHOUSE_STAFF", "2024-05-03T09:00:00Z"),
      trackingEvent("OUT_FOR_DELIVERY", "FedEx Bengaluru South", "Bengaluru", "IN",
        "Out for delivery to Infosys campus", "CARRIER_API", "2024-05-09T08:00:00Z"),
      trackingEvent("DELIVERED", "Infosys Campus, Hosur Road", "Bengaluru", "IN",
        "Delivered — received by campus security", "CARRIER_API", "2024-05-09T13:00:00Z")
    ],
    dimensions: { total_weight_kg: 0.4, total_volume_m3: 0.001, package_count: 1 },
    special_instructions: "ESD sensitive — handle with anti-static packaging",
    insurance_value: 12800.00, currency: "USD",
    created_at: new Date("2024-05-02T11:00:00Z"),
    updated_at: new Date("2024-05-09T13:00:00Z"),
    estimated_delivery_date: new Date("2024-05-10"),
    actual_delivery_date: new Date("2024-05-09")
  }

];

// ─────────────────────────────────────────────────────────────────────────────
// INSERT ALL DOCUMENTS
// ─────────────────────────────────────────────────────────────────────────────
const result = db.shipments.insertMany(shipments, { ordered: true });
print("Inserted " + result.insertedIds.length + " shipment documents into logistics_db.shipments");

// ─────────────────────────────────────────────────────────────────────────────
// SUMMARY COUNTS
// ─────────────────────────────────────────────────────────────────────────────
print("\nShipment status summary:");
db.shipments.aggregate([
  { $group: { _id: "$status", count: { $sum: 1 } } },
  { $sort: { count: -1 } }
]).forEach(s => print("  " + s._id + ": " + s.count));

print("\nCarrier distribution:");
db.shipments.aggregate([
  { $group: { _id: "$carrier.name", count: { $sum: 1 } } },
  { $sort: { count: -1 } }
]).forEach(s => print("  " + s._id + ": " + s.count));
