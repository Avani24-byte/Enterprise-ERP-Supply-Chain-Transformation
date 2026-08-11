# Schema Diagrams
## Enterprise ERP Supply Chain Transformation
**Author:** Misba — Database Engineer
**Scope:** Procurement, Inventory, Order, Logistics (Notification Service removed per Avani's ownership)

---

## 1. Procurement Service (PostgreSQL — `procurement_db`)

```mermaid
erDiagram
    VENDOR {
        uuid id PK
        varchar vendor_code UK
        varchar name
        varchar contact_name
        varchar email
        varchar payment_terms
        numeric vendor_rating
        boolean is_active
        timestamptz created_at
        timestamptz updated_at
    }

    RFQ {
        uuid id PK
        varchar rfq_number UK
        uuid vendor_id FK
        varchar status
        date issue_date
        date due_date
        text notes
        varchar created_by
        timestamptz created_at
        timestamptz updated_at
    }

    RFQ_LINE_ITEM {
        uuid id PK
        uuid rfq_id FK
        smallint line_number
        varchar product_code
        numeric quantity
        varchar unit_of_measure
        numeric estimated_unit_price
        numeric vendor_quoted_price
        timestamptz created_at
    }

    PURCHASE_ORDER {
        uuid id PK
        varchar po_number UK
        uuid vendor_id FK
        uuid rfq_id FK
        varchar status
        date order_date
        date expected_delivery_date
        date actual_delivery_date
        char currency
        numeric total_amount
        varchar payment_terms
        varchar approved_by
        timestamptz created_at
        timestamptz updated_at
    }

    PO_LINE_ITEM {
        uuid id PK
        uuid po_id FK
        smallint line_number
        varchar product_code
        numeric quantity_ordered
        numeric quantity_received
        varchar unit_of_measure
        numeric unit_price
        numeric total_price
        timestamptz created_at
        timestamptz updated_at
    }

    VENDOR ||--o{ RFQ : "receives"
    RFQ ||--o{ RFQ_LINE_ITEM : "contains"
    VENDOR ||--o{ PURCHASE_ORDER : "fulfils"
    RFQ ||--o| PURCHASE_ORDER : "originates"
    PURCHASE_ORDER ||--o{ PO_LINE_ITEM : "contains"
```

---

## 2. Inventory Service (PostgreSQL — `inventory_db`)

```mermaid
erDiagram
    WAREHOUSE {
        uuid id PK
        varchar warehouse_code UK
        varchar name
        varchar city
        char country
        varchar manager_name
        varchar manager_email
        numeric capacity_sqm
        boolean is_active
        timestamptz created_at
        timestamptz updated_at
    }

    STOCK_ITEM {
        uuid id PK
        varchar sku
        uuid warehouse_id FK
        varchar product_name
        varchar category
        varchar unit_of_measure
        numeric quantity_on_hand
        numeric quantity_reserved
        numeric reorder_point
        numeric reorder_quantity
        numeric unit_cost
        boolean is_active
        timestamptz created_at
        timestamptz updated_at
    }

    BATCH {
        uuid id PK
        varchar batch_number UK
        uuid stock_item_id FK
        numeric quantity
        numeric quantity_remaining
        date manufactured_date
        date expiry_date
        varchar supplier_lot_number
        timestamptz received_at
        boolean is_active
    }

    STOCK_MOVEMENT {
        uuid id PK
        uuid stock_item_id FK
        varchar movement_type
        numeric quantity_delta
        numeric quantity_after
        varchar reference_type
        uuid reference_id
        uuid batch_id FK
        uuid warehouse_from_id FK
        uuid warehouse_to_id FK
        varchar performed_by
        text notes
        timestamptz moved_at
        timestamptz created_at
    }

    WAREHOUSE ||--o{ STOCK_ITEM : "holds"
    STOCK_ITEM ||--o{ BATCH : "tracked-in"
    STOCK_ITEM ||--o{ STOCK_MOVEMENT : "logs"
    BATCH ||--o{ STOCK_MOVEMENT : "references"
    WAREHOUSE ||--o{ STOCK_MOVEMENT : "transfer-from"
    WAREHOUSE ||--o{ STOCK_MOVEMENT : "transfer-to"
```

---

## 3. Order Service (PostgreSQL — `order_db`)

```mermaid
erDiagram
    CUSTOMER {
        uuid id PK
        varchar customer_code UK
        varchar name
        varchar contact_name
        varchar email
        varchar billing_address
        varchar shipping_address
        numeric credit_limit
        numeric credit_used
        boolean is_active
        timestamptz created_at
        timestamptz updated_at
    }

    SALES_ORDER {
        uuid id PK
        varchar order_number UK
        uuid customer_id FK
        varchar status
        date order_date
        date required_delivery_date
        date actual_delivery_date
        char currency
        numeric subtotal_amount
        numeric tax_amount
        numeric shipping_amount
        numeric total_amount
        varchar payment_method
        varchar payment_status
        text notes
        varchar created_by
        timestamptz created_at
        timestamptz updated_at
    }

    ORDER_LINE_ITEM {
        uuid id PK
        uuid sales_order_id FK
        smallint line_number
        varchar sku
        varchar product_name
        integer quantity_ordered
        integer quantity_shipped
        numeric unit_price
        numeric discount_pct
        numeric total_price
        text notes
        timestamptz created_at
        timestamptz updated_at
    }

    CUSTOMER ||--o{ SALES_ORDER : "places"
    SALES_ORDER ||--o{ ORDER_LINE_ITEM : "contains"
```

---

## 4. Logistics Service (MongoDB — `logistics_db.shipments`)

```mermaid
erDiagram
    SHIPMENT {
        ObjectId _id PK
        string shipment_number UK
        string order_id
        string order_number
        string customer_id
        string customer_name
        string status
        date estimated_delivery_date
        date actual_delivery_date
        number insurance_value
        string currency
        date created_at
        date updated_at
    }

    CARRIER_EMBED {
        string carrier_id
        string name
        string code
        string tracking_number
        string service_type
        string contact_phone
    }

    ROUTE_ORIGIN {
        string warehouse_id
        string warehouse_code
        string warehouse_name
        string address
        string city
        string country
        date departed_at
    }

    ROUTE_DESTINATION {
        string address
        string city
        string country
        string contact_name
        date estimated_arrival
        date actual_arrival
    }

    WAYPOINT {
        string location
        string city
        string country
        date arrived_at
        date departed_at
    }

    LINE_ITEM_EMBED {
        string sku
        string product_name
        number quantity
        string unit_of_measure
        number weight_kg
        number volume_m3
    }

    TRACKING_EVENT {
        ObjectId event_id
        date timestamp
        string status
        string location
        string city
        string country
        string description
        string updated_by
        number latitude
        number longitude
    }

    SHIPMENT ||--|| CARRIER_EMBED : "embedded"
    SHIPMENT ||--|| ROUTE_ORIGIN : "embedded"
    SHIPMENT ||--|| ROUTE_DESTINATION : "embedded"
    SHIPMENT ||--o{ WAYPOINT : "embedded-array"
    SHIPMENT ||--o{ LINE_ITEM_EMBED : "embedded-array"
    SHIPMENT ||--o{ TRACKING_EVENT : "embedded-array"
```

---

## 5. System-Wide Cross-Service Data Flow

```mermaid
graph LR
    subgraph procurement_db
        PO[purchase_order]
        VND[vendor]
    end

    subgraph inventory_db
        SI[stock_item]
        SM[stock_movement]
        WH[warehouse]
    end

    subgraph order_db
        SO[sales_order]
        OLI[order_line_item]
        CUST[customer]
    end

    subgraph logistics_db
        SHP[shipments]
    end

    subgraph redis
        CACHE["stock:sku:{sku}:wh:{code}"]
    end

    PO -->|"product_code → sku"| SI
    SO -->|"sku → sku"| SI
    SO -->|"OrderPlaced → Kafka"| SM
    SM -->|"StockLow → Kafka"| PO
    SO -->|"order_id (UUID)"| SHP
    WH -->|"warehouse_id (UUID)"| SHP
    SI -->|"Cache-Aside"| CACHE
    SM -->|"Invalidates"| CACHE
```

---

## 6. Flyway Migration File Map

```
procurement-service/src/main/resources/db/migration/
├── V1__init_schema.sql      ← vendor, rfq, rfq_line_item, purchase_order, po_line_item
├── V2__add_indexes.sql      ← All indexes + vw_vendor_performance + vw_monthly_spend
└── V3__seed_data.sql        ← 5 vendors, 8 RFQs, 10 POs, 20 PO lines

inventory-service/src/main/resources/db/migration/
├── V1__init_schema.sql      ← warehouse, stock_item, batch, stock_movement
├── V2__add_indexes.sql      ← All indexes + vw_inventory_turnover + vw_stock_snapshot
└── V3__seed_data.sql        ← 3 warehouses, 15 SKUs, 30 batches, 25 movements

order-service/src/main/resources/db/migration/
├── V1__init_schema.sql      ← customer, sales_order, order_line_item
├── V2__add_indexes.sql      ← All indexes + vw_order_fulfillment_rate + vw_customer_revenue
└── V3__seed_data.sql        ← 8 customers, 20 sales orders, 29 order lines

logistics-service/mongodb/
├── schema_design.md         ← Full document structure + design decisions
├── indexes.js               ← createIndex() calls for all 10 indexes
└── seed_data.js             ← 15 shipment documents with tracking events

analytics/sql/
└── reporting_views.sql      ← 7 cross-service views: OTIF, turnover, vendor KPIs, etc.

inventory-service/src/main/resources/
└── redis-cache-strategy.md  ← Key patterns, TTLs, cache-aside, invalidation logic
```
