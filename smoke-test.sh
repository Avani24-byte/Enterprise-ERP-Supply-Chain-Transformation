#!/bin/bash

SERVICES=(
  "http://localhost:8761/actuator/health"
  "http://localhost:8080/actuator/health"
  "http://localhost:8081/actuator/health"
  "http://localhost:8082/actuator/health"
  "http://localhost:8083/actuator/health"
  "http://localhost:8084/actuator/health"
  "http://localhost:8085/actuator/health"
  "http://localhost:8086/actuator/health"
  "http://localhost:8087/actuator/health"
  "http://localhost:8000/actuator/health"
)

echo "Starting Smoke Tests..."
for url in "${SERVICES[@]}"; do
  # Run curl silently, outputting only the HTTP status code
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$url")
  if [ "$STATUS" -eq 200 ]; then
    echo "[PASS] $url"
  else
    echo "[FAIL] $url (HTTP $STATUS)"
  fi
done
