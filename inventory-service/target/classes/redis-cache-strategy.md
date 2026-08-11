# Redis Caching Strategy
## Inventory Service — Live Stock Levels
**Author:** Misba (Database Engineer)
**Last Updated:** Sprint Day 1

---

## Overview

The Inventory service uses a **Cache-Aside (Lazy Loading)** pattern backed by Redis 7
for live stock level data. This is the hottest read path in the system:
every order confirmation, every reorder check, and every dashboard refresh
reads current stock levels. Without caching, these queries hit PostgreSQL on
every request.

---

## Eviction Policy

```
maxmemory-policy allkeys-lru
```

Redis evicts the least-recently-used keys when memory is full.
All inventory cache keys are equally eligible — no explicit LRU prioritisation needed.

---

## Key Patterns

| Data | Key Pattern | Value | TTL |
|---|---|---|---|
| Single SKU in one warehouse | `stock:sku:{sku}:wh:{warehouse_code}` | JSON (StockItem) | 300s |
| All SKUs in a warehouse | `stock:wh:{warehouse_code}:all` | JSON array | 120s |
| Low stock SKUs (global) | `stock:low_stock:all` | JSON array (sku + warehouse) | 60s |
| Warehouse master record | `warehouse:{warehouse_id}` | JSON (Warehouse) | 3600s |
| Stock snapshot (dashboard) | `stock:snapshot:{warehouse_code}` | JSON array | 120s |

### Key Examples
```
stock:sku:STL-HR-6MM:wh:WH-MUM-01
stock:sku:ELEC-CB-001:wh:WH-BLR-01
stock:wh:WH-MUM-01:all
stock:low_stock:all
warehouse:f6000000-0000-0000-0000-000000000001
```

---

## TTL Policy

| Key Type | TTL (seconds) | Rationale |
|---|---|---|
| Single SKU stock | **300** (5 min) | Balance between freshness and DB load. Stock changes via stock_movement events; Kafka consumer invalidates immediately. |
| Warehouse all-SKUs | **120** (2 min) | Shorter because it's a list — more likely to be stale after any movement. |
| Low stock list | **60** (1 min) | Critical path — dashboard alerts must be near-real-time. |
| Warehouse master | **3600** (1 hour) | Warehouses change rarely; long TTL acceptable. |
| Stock snapshot | **120** (2 min) | Same as warehouse all-SKUs. |

> **Default assumption: 300 seconds** — confirm with team if different SLA needed.

---

## Cache-Aside Pattern (Read Path)

```
1. Application requests stock for SKU X at warehouse W
2. Check Redis key: stock:sku:{X}:wh:{W}
   → Cache HIT  → return cached JSON → done
   → Cache MISS → query PostgreSQL stock_item table
                → serialize result to JSON
                → SET key with TTL 300
                → return result
```

---

## Write-Through / Cache Invalidation (Write Path)

On every stock_movement INSERT, the application must:

```
1. INSERT into stock_movement (always — audit log)
2. UPDATE stock_item.quantity_on_hand
3. DELETE Redis keys:
   - stock:sku:{sku}:wh:{warehouse_code}         (force re-read on next request)
   - stock:wh:{warehouse_code}:all               (list is now stale)
   - stock:low_stock:all                         (may have crossed reorder_point)
   - stock:snapshot:{warehouse_code}
```

> **Rationale for DELETE over WRITE-THROUGH on updates:**
> The stock_movement event comes from Kafka (async), meaning the DB write
> and cache update are in different transactions. A DELETE is safer than
> a WRITE-THROUGH here — it forces the next read to get a consistent value
> from the DB rather than potentially writing a stale snapshot to cache.

---

## Kafka Consumer Integration

The Inventory service Kafka consumer (listening to `stock.movement.created` topic)
is responsible for cache invalidation:

```java
// Pseudocode — implemented by Avani (Backend Developer)
@KafkaListener(topics = "stock.movement.created")
public void handleStockMovement(StockMovementEvent event) {
    inventoryService.applyMovement(event);         // DB write
    redisTemplate.delete("stock:sku:" + event.getSku() + ":wh:" + event.getWarehouseCode());
    redisTemplate.delete("stock:wh:" + event.getWarehouseCode() + ":all");
    redisTemplate.delete("stock:low_stock:all");
    redisTemplate.delete("stock:snapshot:" + event.getWarehouseCode());
}
```

---

## Bloom Filter (Optional Optimisation)

To prevent cache stampede on non-existent SKU lookups (malformed API requests):

```
Key : bloom:stock:sku
Type: Redis Bloom Filter (RedisBloom module)
Action: On stock_item INSERT → BF.ADD bloom:stock:sku {sku}
        On stock lookup    → BF.EXISTS bloom:stock:sku {sku}
                             → FALSE → return 404 immediately (no DB hit)
                             → TRUE  → proceed with cache-aside lookup
```

> This is **optional** — only implement if the team observes significant invalid SKU
> query traffic in monitoring. Do not block backend development on this.

---

## Spring Boot Integration Reference

Avani should configure the following in each service's `application.yml`:

```yaml
spring:
  data:
    redis:
      host: ${REDIS_HOST:localhost}
      port: ${REDIS_PORT:6379}
      password: ${REDIS_PASSWORD:}
      timeout: 2000ms
  cache:
    type: redis
    redis:
      time-to-live: 300000   # 300 seconds in milliseconds (default TTL)
      cache-null-values: false
```

Cache bean configuration:

```java
@Bean
public RedisCacheConfiguration stockCacheConfig() {
    return RedisCacheConfiguration.defaultCacheConfig()
        .entryTtl(Duration.ofSeconds(300))
        .disableCachingNullValues()
        .serializeValuesWith(RedisSerializationContext.SerializationPair
            .fromSerializer(new GenericJackson2JsonRedisSerializer()));
}
```

---

## Redis Docker Configuration

See `docker-compose.yml` for the Redis service definition. Key settings:

```yaml
redis:
  image: redis:7-alpine
  command: >
    redis-server
    --maxmemory 256mb
    --maxmemory-policy allkeys-lru
    --save ""          # Disable RDB persistence (cache only — no persistence needed)
    --appendonly no    # Disable AOF persistence
  ports:
    - "6379:6379"
```

> RDB and AOF are both disabled because Redis is used purely as a **cache**, not
> as a primary data store. On restart, the cache simply warms up from PostgreSQL.
