# Data Dictionary
## Enterprise ERP Supply Chain Transformation
**Author:** Misba — Database Engineer
**Scope:** Procurement, Inventory, Order, Logistics
**Migration Tool:** Flyway | **Convention:** snake_case | **PK Type:** UUID

---

## Table of Contents
- [Procurement Service (PostgreSQL)](#procurement-service)
- [Inventory Service (PostgreSQL)](#inventory-service)
- [Order Service (PostgreSQL)](#order-service)
- [Logistics Service (MongoDB)](#logistics-service)
- [Redis Cache Keys](#redis-cache-keys)
- [Cross-Service References](#cross-service-references)

---

## Procurement Service

**Database:** `procurement_db` | **Port:** 5432

### `vendor`

| Column | Type | Nullable | Default | Constraint | Description |
|---|---|---|---|---|---|
| `id` | UUID | NO | `gen_random_uuid()` | PK | Surrogate primary key |
| `vendor_code` | VARCHAR(30) | NO | — | UNIQUE | Human-readable code e.g. VND-001 |
| `name` | VARCHAR(255) | NO | — | — | Company name |
| `contact_name` | VARCHAR(150) | YES | — | — | Primary contact person |
| `email` | VARCHAR(255) | YES | — | — | Contact email address |
| `phone` | VARCHAR(50) | YES | — | — | Contact phone number |
| `address_line1` | VARCHAR(255) | YES | — | — | Street address line 1 |
| `city` | VARCHAR(100) | YES | — | — | City |
| `country` | CHAR(2) | NO | `'IN'` | — | ISO 3166-1 alpha-2 country code |
| `payment_terms` | VARCHAR(30) | NO | `'NET_30'` | CHECK enum | Agreed payment window |
| `vendor_rating` | NUMERIC(3,2) | YES | — | CHECK 0.00–5.00 | Supplier quality rating |
| `is_active` | BOOLEAN | NO | `TRUE` | — | Soft-delete flag |
| `created_at` | TIMESTAMPTZ | NO | `NOW()` | — | Record creation timestamp |
| `updated_at` | TIMESTAMPTZ | NO | `NOW()` | — | Last update timestamp |

### `rfq`

| Column | Type | Nullable | Default | Constraint | Description |
|---|---|---|---|---|---|
| `id` | UUID | NO | `gen_random_uuid()` | PK | — |
| `rfq_number` | VARCHAR(30) | NO | — | UNIQUE | e.g. RFQ-2024-0001 |
| `vendor_id` | UUID | NO | — | FK vendor.id RESTRICT | Vendor receiving this RFQ |
| `status` | VARCHAR(20) | NO | `'DRAFT'` | CHECK enum | DRAFT,SENT,RECEIVED,ACCEPTED,REJECTED,EXPIRED |
| `issue_date` | DATE | NO | `CURRENT_DATE` | — | Date RFQ was issued |
| `due_date` | DATE | YES | — | CHECK >= issue_date | Vendor response deadline |
| `notes` | TEXT | YES | — | — | Free-text |
| `created_by` | VARCHAR(100) | YES | — | — | User ID from Auth service |
| `created_at` | TIMESTAMPTZ | NO | `NOW()` | — | — |
| `updated_at` | TIMESTAMPTZ | NO | `NOW()` | — | — |

**Status Flow:** DRAFT → SENT → RECEIVED → ACCEPTED _(becomes PO)_ / REJECTED / EXPIRED

### `rfq_line_item`

| Column | Type | Nullable | Constraint | Description |
|---|---|---|---|---|
| `id` | UUID | NO | PK | — |
| `rfq_id` | UUID | NO | FK rfq.id CASCADE | Parent RFQ |
| `line_number` | SMALLINT | NO | UNIQUE(rfq_id, line_number) | Display order |
| `product_code` | VARCHAR(50) | NO | — | SKU matches Inventory sku |
| `quantity` | NUMERIC(12,4) | NO | CHECK > 0 | Quantity requested |
| `unit_of_measure` | VARCHAR(20) | NO | `'EACH'` | — |
| `estimated_unit_price` | NUMERIC(15,4) | YES | CHECK >= 0 | Buyer estimate |
| `vendor_quoted_price` | NUMERIC(15,4) | YES | CHECK >= 0 | Vendor response price |
| `created_at` | TIMESTAMPTZ | NO | `NOW()` | — |

### `purchase_order`

| Column | Type | Nullable | Default | Constraint | Description |
|---|---|---|---|---|---|
| `id` | UUID | NO | `gen_random_uuid()` | PK | — |
| `po_number` | VARCHAR(30) | NO | — | UNIQUE | e.g. PO-2024-0001 |
| `vendor_id` | UUID | NO | — | FK vendor.id RESTRICT | Supplier |
| `rfq_id` | UUID | YES | — | FK rfq.id SET NULL | Source RFQ (nullable) |
| `status` | VARCHAR(25) | NO | `'DRAFT'` | CHECK enum | DRAFT,APPROVED,SENT,PARTIALLY_RECEIVED,RECEIVED,CANCELLED |
| `order_date` | DATE | NO | `CURRENT_DATE` | — | — |
| `expected_delivery_date` | DATE | YES | — | CHECK >= order_date | — |
| `actual_delivery_date` | DATE | YES | — | CHECK >= order_date | Set on GRN |
| `currency` | CHAR(3) | NO | `'USD'` | — | ISO 4217 |
| `total_amount` | NUMERIC(15,4) | NO | `0` | CHECK >= 0 | Sum of line totals |
| `payment_terms` | VARCHAR(30) | NO | `'NET_30'` | CHECK enum | — |
| `approved_by` | VARCHAR(100) | YES | — | — | Approver user ID |
| `created_by` | VARCHAR(100) | YES | — | — | Creator user ID |
| `created_at` | TIMESTAMPTZ | NO | `NOW()` | — | — |
| `updated_at` | TIMESTAMPTZ | NO | `NOW()` | — | — |

### `po_line_item`

| Column | Type | Nullable | Constraint | Description |
|---|---|---|---|---|
| `id` | UUID | NO | PK | — |
| `po_id` | UUID | NO | FK purchase_order.id CASCADE | Parent PO |
| `line_number` | SMALLINT | NO | UNIQUE(po_id, line_number) | — |
| `product_code` | VARCHAR(50) | NO | — | SKU matches Inventory |
| `quantity_ordered` | NUMERIC(12,4) | NO | CHECK > 0 | — |
| `quantity_received` | NUMERIC(12,4) | NO | CHECK >= 0, <= quantity_ordered | Updated on GRN |
| `unit_price` | NUMERIC(15,4) | NO | CHECK >= 0 | — |
| `total_price` | NUMERIC(15,4) | GENERATED | qty * price STORED | Computed column |
| `created_at` | TIMESTAMPTZ | NO | `NOW()` | — |
| `updated_at` | TIMESTAMPTZ | NO | `NOW()` | — |

---

## Inventory Service

**Database:** `inventory_db` | **Port:** 5433

### `warehouse`

| Column | Type | Nullable | Default | Description |
|---|---|---|---|---|
| `id` | UUID | NO | `gen_random_uuid()` | PK |
| `warehouse_code` | VARCHAR(20) | NO | — | UNIQUE. e.g. WH-MUM-01 |
| `name` | VARCHAR(255) | NO | — | Display name |
| `address_line1` | VARCHAR(255) | YES | — | Street address |
| `city` | VARCHAR(100) | YES | — | City |
| `country` | CHAR(2) | NO | `'IN'` | ISO 3166-1 alpha-2 |
| `manager_name` | VARCHAR(150) | YES | — | Warehouse manager |
| `manager_email` | VARCHAR(255) | YES | — | Manager email |
| `capacity_sqm` | NUMERIC(10,2) | YES | — | Floor area sq. metres |
| `is_active` | BOOLEAN | NO | `TRUE` | Soft-delete |
| `created_at` | TIMESTAMPTZ | NO | `NOW()` | — |
| `updated_at` | TIMESTAMPTZ | NO | `NOW()` | — |

### `stock_item`

| Column | Type | Nullable | Default | Constraint | Description |
|---|---|---|---|---|---|
| `id` | UUID | NO | `gen_random_uuid()` | PK | — |
| `sku` | VARCHAR(50) | NO | — | UNIQUE(sku, warehouse_id) | Stock-Keeping Unit code |
| `warehouse_id` | UUID | NO | — | FK warehouse.id RESTRICT | Storage location |
| `product_name` | VARCHAR(255) | NO | — | — | Display name |
| `category` | VARCHAR(100) | YES | — | — | e.g. Steel, Electronics |
| `unit_of_measure` | VARCHAR(20) | NO | `'EACH'` | — | — |
| `quantity_on_hand` | NUMERIC(12,4) | NO | `0` | CHECK >= 0 | Current stock |
| `quantity_reserved` | NUMERIC(12,4) | NO | `0` | CHECK >= 0, <= qty_on_hand | Reserved for confirmed SOs |
| `reorder_point` | NUMERIC(12,4) | NO | `10` | CHECK > 0 | Triggers StockLow Kafka event |
| `reorder_quantity` | NUMERIC(12,4) | NO | `50` | CHECK > 0 | Suggested reorder qty |
| `unit_cost` | NUMERIC(15,4) | YES | — | CHECK >= 0 | Last known cost |
| `is_active` | BOOLEAN | NO | `TRUE` | — | Soft-delete |
| `created_at` | TIMESTAMPTZ | NO | `NOW()` | — | — |
| `updated_at` | TIMESTAMPTZ | NO | `NOW()` | — | — |

> **Critical:** `quantity_reserved <= quantity_on_hand` enforced at DB level via CHECK constraint.

### `batch`

| Column | Type | Nullable | Constraint | Description |
|---|---|---|---|---|
| `id` | UUID | NO | PK | — |
| `batch_number` | VARCHAR(50) | NO | UNIQUE | e.g. BAT-2024-0001 |
| `stock_item_id` | UUID | NO | FK stock_item.id RESTRICT | Parent SKU |
| `quantity` | NUMERIC(12,4) | NO | CHECK > 0 | Original batch quantity |
| `quantity_remaining` | NUMERIC(12,4) | NO | CHECK >= 0, <= quantity | Remaining |
| `manufactured_date` | DATE | YES | — | Manufacturing date |
| `expiry_date` | DATE | YES | CHECK >= manufactured_date | For FEFO picking |
| `supplier_lot_number` | VARCHAR(100) | YES | — | Vendor's lot reference |
| `received_at` | TIMESTAMPTZ | NO | `NOW()` | When received into warehouse |
| `is_active` | BOOLEAN | NO | `TRUE` | FALSE = depleted/expired |

### `stock_movement` (Append-only)

| Column | Type | Nullable | Description |
|---|---|---|---|
| `id` | UUID | NO | PK |
| `stock_item_id` | UUID | NO | FK stock_item.id |
| `movement_type` | VARCHAR(20) | NO | RECEIPT, DISPATCH, ADJUSTMENT, TRANSFER_OUT, TRANSFER_IN, RETURN |
| `quantity_delta` | NUMERIC(12,4) | NO | Positive = increase, negative = decrease |
| `quantity_after` | NUMERIC(12,4) | NO | Stock level after movement (CHECK >= 0) |
| `reference_type` | VARCHAR(30) | YES | PURCHASE_ORDER, SALES_ORDER, MANUAL, TRANSFER |
| `reference_id` | UUID | YES | UUID in the originating service |
| `batch_id` | UUID | YES | FK batch.id |
| `warehouse_from_id` | UUID | YES | FK warehouse.id (TRANSFER_OUT) |
| `warehouse_to_id` | UUID | YES | FK warehouse.id (TRANSFER_IN) |
| `performed_by` | VARCHAR(100) | YES | User ID |
| `notes` | TEXT | YES | Free-text |
| `moved_at` | TIMESTAMPTZ | NO | Effective movement timestamp |
| `created_at` | TIMESTAMPTZ | NO | Record creation timestamp |

> **Never UPDATE or DELETE rows in stock_movement. It is an immutable audit log.**

---

## Order Service

**Database:** `order_db` | **Port:** 5434

### `customer`

| Column | Type | Nullable | Constraint | Description |
|---|---|---|---|---|
| `id` | UUID | NO | PK | — |
| `customer_code` | VARCHAR(30) | NO | UNIQUE | e.g. CUST-001 |
| `name` | VARCHAR(255) | NO | — | Company name |
| `email` | VARCHAR(255) | YES | — | — |
| `billing_address` | VARCHAR(500) | YES | — | — |
| `shipping_address` | VARCHAR(500) | YES | — | Default shipping address |
| `credit_limit` | NUMERIC(15,4) | NO | CHECK >= 0 | Max outstanding balance |
| `credit_used` | NUMERIC(15,4) | NO | CHECK >= 0, <= credit_limit | Current balance |
| `is_active` | BOOLEAN | NO | `TRUE` | Soft-delete |

### `sales_order`

| Column | Type | Nullable | Constraint | Description |
|---|---|---|---|---|
| `id` | UUID | NO | PK | — |
| `order_number` | VARCHAR(30) | NO | UNIQUE | e.g. SO-2024-0001 |
| `customer_id` | UUID | NO | FK customer.id RESTRICT | — |
| `status` | VARCHAR(25) | NO | CHECK enum | DRAFT, CONFIRMED, PROCESSING, PARTIALLY_SHIPPED, SHIPPED, DELIVERED, CANCELLED, RETURNED |
| `order_date` | DATE | NO | `CURRENT_DATE` | — |
| `required_delivery_date` | DATE | YES | CHECK >= order_date | Customer deadline |
| `actual_delivery_date` | DATE | YES | CHECK >= order_date | Set by Logistics events |
| `currency` | CHAR(3) | NO | `'USD'` | — |
| `subtotal_amount` | NUMERIC(15,4) | NO | CHECK >= 0 | Pre-tax subtotal |
| `tax_amount` | NUMERIC(15,4) | NO | CHECK >= 0 | Tax |
| `shipping_amount` | NUMERIC(15,4) | NO | CHECK >= 0 | Shipping charges |
| `total_amount` | NUMERIC(15,4) | NO | CHECK >= 0 | Grand total |
| `payment_status` | VARCHAR(20) | NO | `'PENDING'` | PENDING, PAID, PARTIALLY_PAID, REFUNDED |
| `created_by` | VARCHAR(100) | YES | — | User ID |

**Kafka Events on Status Change:**
- `CONFIRMED` → fires `OrderPlaced` topic
- `SHIPPED` → fires `ShipmentDispatched` topic

### `order_line_item`

| Column | Type | Nullable | Constraint | Description |
|---|---|---|---|---|
| `id` | UUID | NO | PK | — |
| `sales_order_id` | UUID | NO | FK sales_order.id CASCADE | — |
| `line_number` | SMALLINT | NO | UNIQUE(sales_order_id, line_number) | — |
| `sku` | VARCHAR(50) | NO | — | Matches Inventory stock_item.sku |
| `product_name` | VARCHAR(255) | NO | — | Snapshot at order time |
| `quantity_ordered` | INTEGER | NO | CHECK > 0 | — |
| `quantity_shipped` | INTEGER | NO | CHECK >= 0, <= quantity_ordered | Kafka-updated |
| `unit_price` | NUMERIC(15,4) | NO | CHECK >= 0 | — |
| `discount_pct` | NUMERIC(5,2) | NO | `0` CHECK 0–100 | Line discount |
| `total_price` | NUMERIC(15,4) | GENERATED | qty * price * (1 - discount/100) STORED | — |

---

## Logistics Service

**Database:** `logistics_db` (MongoDB 7) | **Port:** 27017 | **Collection:** `shipments`

### Embedded Document Fields

| Field | Type | Description |
|---|---|---|
| `_id` | ObjectId | MongoDB auto-generated |
| `shipment_number` | String (UNIQUE) | e.g. SHP-2024-0001 |
| `order_id` | String (UUID) | Cross-ref to order_db.sales_order.id |
| `order_number` | String | Denormalized for display |
| `customer_id` | String (UUID) | Cross-ref to order_db.customer.id |
| `customer_name` | String | Denormalized for display |
| `status` | String | PENDING, PICKED_UP, IN_TRANSIT, OUT_FOR_DELIVERY, DELIVERED, FAILED_ATTEMPT, RETURNED, CANCELLED |
| `carrier` | Object | Embedded carrier snapshot |
| `carrier.name` | String | e.g. FedEx India |
| `carrier.code` | String | e.g. FEDEX, DHL |
| `carrier.tracking_number` | String (unique/sparse) | Carrier waybill number |
| `carrier.service_type` | String | STANDARD, EXPRESS, OVERNIGHT, FREIGHT |
| `route.origin` | Object | Warehouse snapshot at dispatch |
| `route.destination` | Object | Delivery address + estimated/actual arrival |
| `route.waypoints` | Array | Transit hubs (append-only) |
| `line_items` | Array | Shipped items snapshot |
| `tracking_events` | Array | Append-only event log |
| `tracking_events[].status` | String | Status at this event |
| `tracking_events[].timestamp` | Date | Event time |
| `tracking_events[].updated_by` | String | CARRIER_API, WAREHOUSE_STAFF, MANUAL |
| `dimensions` | Object | total_weight_kg, total_volume_m3, package_count |
| `insurance_value` | Number | Declared value for insurance |
| `created_at` | Date | — |
| `updated_at` | Date | — |
| `estimated_delivery_date` | Date | — |
| `actual_delivery_date` | Date | null until delivered |

### MongoDB Indexes

| Index | Fields | Type |
|---|---|---|
| `idx_shipment_number_unique` | shipment_number | Unique |
| `idx_carrier_tracking_number` | carrier.code, carrier.tracking_number | Unique sparse |
| `idx_order_id` | order_id | Standard |
| `idx_customer_history` | customer_id, created_at DESC | Compound |
| `idx_status_date` | status, created_at DESC | Compound |
| `idx_estimated_delivery_status` | estimated_delivery_date, status | Compound |
| `idx_origin_warehouse` | route.origin.warehouse_id, created_at DESC | Compound |
| `idx_carrier_analytics` | carrier.code, created_at DESC | Compound |

---

## Redis Cache Keys

**Instance:** `cache` | **Port:** 6379 | **Policy:** `allkeys-lru` | **Max Memory:** 256 MB

| Key Pattern | Value | TTL | Description |
|---|---|---|---|
| `stock:sku:{sku}:wh:{warehouse_code}` | JSON (StockItem) | 300s | Single SKU stock level |
| `stock:wh:{warehouse_code}:all` | JSON array | 120s | All SKUs in a warehouse |
| `stock:low_stock:all` | JSON array | 60s | All SKUs at or below reorder point |
| `warehouse:{warehouse_id}` | JSON (Warehouse) | 3600s | Warehouse master record |
| `stock:snapshot:{warehouse_code}` | JSON array | 120s | Dashboard stock snapshot |

**Pattern:** Cache-Aside (reads) + Kafka-event-triggered DELETE invalidation (writes).
**Persistence:** Disabled (cache only — re-warms from PostgreSQL on restart).

---

## Cross-Service References

These UUIDs cross microservice boundaries. **No foreign keys exist across databases.**
Integrity is enforced at the **application layer only.**

| Source Service | Column | Points To | Target Service |
|---|---|---|---|
| Procurement | `po_line_item.product_code` (SKU string) | `stock_item.sku` | Inventory |
| Inventory | `stock_movement.reference_id` | `purchase_order.id` or `sales_order.id` | Procurement / Order |
| Order | `order_line_item.sku` | `stock_item.sku` | Inventory |
| Logistics | `shipments.order_id` | `sales_order.id` | Order |
| Logistics | `shipments.customer_id` | `customer.id` | Order |
| Logistics | `route.origin.warehouse_id` | `warehouse.id` | Inventory |
| All services | `created_by`, `approved_by`, `performed_by` | `user.id` | Auth service |
