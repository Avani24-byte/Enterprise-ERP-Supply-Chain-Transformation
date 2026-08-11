# Integration Testing Support Checklist (3:30 PM)

## 1. Pre-Flight Checklist
Before beginning end-to-end integration testing, confirm the baseline infrastructure is healthy:
- [ ] `docker-compose up -d` succeeds and all containers are `Up`.
- [ ] Infrastructure logs are clean: `docker-compose logs -f postgres mongodb redis kafka` show no crash loops.
- [ ] Kafka topics exist: 
  ```bash
  docker exec kafka kafka-topics --bootstrap-server localhost:9092 --list
  ```
  *(Expect to see topics like `OrderPlaced`, `StockLow`, etc. depending on your application config)*
- [ ] Eureka Server UI is accessible at `http://localhost:8761` and all Java microservices are registered as `UP`.

## 2. Smoke-Test Script
Run this quick script from your terminal to verify that every service's health endpoint is responding with 200 OK.
*(Save this as `smoke-test.sh` and run it)*

```bash
#!/bin/bash
SERVICES=(
  "api-gateway:8080"
  "auth-service:8081"
  "procurement-service:8082"
  "inventory-service:8083"
  "order-service:8084"
  "logistics-service:8085"
  "notification-service:8086"
  "analytics-service:8087"
)

echo "Starting smoke tests..."
for svc in "${SERVICES[@]}"; do
  # Adjust /actuator/health if your gateway strips prefixes
  HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:${svc#*:}/actuator/health)
  if [ "$HTTP_STATUS" -eq 200 ]; then
    echo "✅ ${svc%%:*} is UP"
  else
    echo "❌ ${svc%%:*} is DOWN (HTTP $HTTP_STATUS)"
  fi
done
```

## 3. End-to-End Event Flow Check
To manually verify that Kafka asynchronous events are flowing across microservices, use a simple `curl` + log tail approach.

1. **Open a terminal and tail the logs of the downstream service (e.g., Notification or Inventory):**
   ```bash
   docker-compose logs -f notification-service inventory-service
   ```
2. **Open another terminal and place a test order via the API Gateway:**
   ```bash
   curl -X POST http://localhost:8080/api/orders \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer <test_jwt_token>" \
     -d '{"productId": "123", "quantity": 10, "customerId": "456"}'
   ```
3. **Verify:** You should see a log in the first terminal outputting something like `Received OrderPlaced event...` and subsequently `Sent order confirmation email to customer`.

## 4. Likely Integration Failure Points
If things are broken, check these classic 1-day sprint race conditions first:

1. **Service Discovery Timing Race**: The API Gateway boots up, but Eureka hasn't finished registering `order-service` yet. 
   - *Fix*: Restart the Gateway `docker-compose restart api-gateway`, or just wait 30 seconds for the Eureka cache to sync.
2. **Kafka Topic Auto-Creation Disabled**: Services crash on startup because they try to consume a topic that doesn't exist yet, and auto-create is off.
   - *Fix*: Pre-create topics using a startup script, or ensure Avani's Spring Kafka config has `spring.kafka.admin.auto-create=true`.
3. **DB Connection Refused**: A Spring Boot service tries to connect to PostgreSQL before PostgreSQL has finished running its internal init scripts.
   - *Fix*: We largely mitigated this with our `depends_on: service_healthy` check, but if it happens, check `docker-compose logs postgres` to ensure it's actually ready to accept connections.
4. **CORS on the API Gateway**: The React frontend (Keerthana) will hit `localhost:3000`, making requests to the Gateway on `localhost:8080`. The browser will block this unless the Gateway has a global CORS configuration allowing `http://localhost:3000`.
