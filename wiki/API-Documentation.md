# API Documentation

This document provides comprehensive documentation for all REST API endpoints exposed by the Container Apps Store API Microservice.

## Base URLs

### Local Development
- **Store API**: `http://localhost:3000`
- **Order Service**: `http://localhost:5000`
- **Inventory Service**: `http://localhost:8050`

### Azure Container Apps
- **Store API**: `https://<your-node-app-url>.azurecontainerapps.io`
- **Order Service**: Internal only (accessed via Dapr)
- **Inventory Service**: Internal only (accessed via Dapr)

## Store API (Node.js)

The Store API serves as the primary entry point and gateway to other microservices.

### GET /

**Description:** Returns the main application page (HTML)

**Request:**
```http
GET / HTTP/1.1
Host: localhost:3000
```

**Response:**
```http
HTTP/1.1 200 OK
Content-Type: text/html

<!DOCTYPE html>
<html>
  <!-- HTML content -->
</html>
```

**cURL Example:**
```bash
curl http://localhost:3000/
```

---

### GET /orders

**Description:** Retrieves order information from the Order Service

**Parameters:**
| Name | Type | Required | Description |
|------|------|----------|-------------|
| id | string | Yes | The order ID to retrieve |

**Request:**
```http
GET /orders?id=foo HTTP/1.1
Host: localhost:3000
```

**Response (Success):**
```json
{
  "orderId": "foo",
  "items": [
    {
      "productId": "product-1",
      "quantity": 2,
      "price": 29.99
    }
  ],
  "total": 59.98,
  "status": "pending",
  "timestamp": "2025-10-17T15:30:00Z"
}
```

**Response Codes:**
- `200 OK` - Order found and returned
- `404 Not Found` - Order ID does not exist
- `500 Internal Server Error` - Service communication error

**cURL Example:**
```bash
curl "http://localhost:3000/orders?id=foo"
```

---

### GET /inventory

**Description:** Retrieves inventory information from the Inventory Service

**Parameters:**
| Name | Type | Required | Description |
|------|------|----------|-------------|
| id | string | Yes | The product ID to check |

**Request:**
```http
GET /inventory?id=widget HTTP/1.1
Host: localhost:3000
```

**Response:**
```json
{
  "productId": "widget",
  "quantity": 100,
  "available": true,
  "location": "warehouse-1",
  "lastUpdated": "2025-10-17T15:30:00Z"
}
```

**Response Codes:**
- `200 OK` - Inventory information returned
- `404 Not Found` - Product ID does not exist
- `500 Internal Server Error` - Service communication error

**cURL Example:**
```bash
curl "http://localhost:3000/inventory?id=widget"
```

---

## Order Service API (Python)

The Order Service manages order state using Dapr state management. It's accessed internally via Dapr service invocation or directly during local development.

### POST /orders

**Description:** Creates a new order

**Request Body:**
```json
{
  "orderId": "order-123",
  "items": [
    {
      "productId": "product-1",
      "quantity": 2,
      "price": 29.99
    }
  ],
  "customerId": "customer-456"
}
```

**Response:**
```json
{
  "success": true,
  "orderId": "order-123",
  "message": "Order created successfully"
}
```

**Response Codes:**
- `201 Created` - Order successfully created
- `400 Bad Request` - Invalid request body
- `500 Internal Server Error` - Failed to save order

**cURL Example:**
```bash
curl -X POST http://localhost:5000/orders \
  -H "Content-Type: application/json" \
  -d '{
    "orderId": "order-123",
    "items": [{"productId": "product-1", "quantity": 2, "price": 29.99}],
    "customerId": "customer-456"
  }'
```

---

### GET /orders/:id

**Description:** Retrieves an order by ID

**Parameters:**
| Name | Type | Required | Description |
|------|------|----------|-------------|
| id | string | Yes | The order ID (path parameter) |

**Request:**
```http
GET /orders/order-123 HTTP/1.1
Host: localhost:5000
```

**Response:**
```json
{
  "orderId": "order-123",
  "items": [
    {
      "productId": "product-1",
      "quantity": 2,
      "price": 29.99
    }
  ],
  "customerId": "customer-456",
  "status": "pending",
  "createdAt": "2025-10-17T15:30:00Z"
}
```

**Response Codes:**
- `200 OK` - Order found and returned
- `404 Not Found` - Order not found
- `500 Internal Server Error` - Failed to retrieve order

**cURL Example:**
```bash
curl http://localhost:5000/orders/order-123
```

---

### PUT /orders/:id

**Description:** Updates an existing order

**Parameters:**
| Name | Type | Required | Description |
|------|------|----------|-------------|
| id | string | Yes | The order ID (path parameter) |

**Request Body:**
```json
{
  "status": "shipped",
  "trackingNumber": "TRACK123"
}
```

**Response:**
```json
{
  "success": true,
  "orderId": "order-123",
  "message": "Order updated successfully"
}
```

**Response Codes:**
- `200 OK` - Order successfully updated
- `404 Not Found` - Order not found
- `500 Internal Server Error` - Failed to update order

**cURL Example:**
```bash
curl -X PUT http://localhost:5000/orders/order-123 \
  -H "Content-Type: application/json" \
  -d '{
    "status": "shipped",
    "trackingNumber": "TRACK123"
  }'
```

---

### DELETE /orders/:id

**Description:** Deletes an order

**Parameters:**
| Name | Type | Required | Description |
|------|------|----------|-------------|
| id | string | Yes | The order ID (path parameter) |

**Request:**
```http
DELETE /orders/order-123 HTTP/1.1
Host: localhost:5000
```

**Response:**
```json
{
  "success": true,
  "orderId": "order-123",
  "message": "Order deleted successfully"
}
```

**Response Codes:**
- `200 OK` - Order successfully deleted
- `404 Not Found` - Order not found
- `500 Internal Server Error` - Failed to delete order

**cURL Example:**
```bash
curl -X DELETE http://localhost:5000/orders/order-123
```

---

## Inventory Service API (Go)

The Inventory Service provides product inventory information. It's accessed internally via Dapr service invocation or directly during local development.

### GET /inventory/:id

**Description:** Retrieves inventory status for a product

**Parameters:**
| Name | Type | Required | Description |
|------|------|----------|-------------|
| id | string | Yes | The product ID (path parameter) |

**Request:**
```http
GET /inventory/widget HTTP/1.1
Host: localhost:8050
```

**Response:**
```json
{
  "productId": "widget",
  "quantity": 100,
  "available": true,
  "price": 29.99,
  "location": "warehouse-1",
  "sku": "WDG-001",
  "lastRestocked": "2025-10-15T10:00:00Z"
}
```

**Response Codes:**
- `200 OK` - Inventory information returned
- `404 Not Found` - Product not found
- `500 Internal Server Error` - Service error

**cURL Example:**
```bash
curl http://localhost:8050/inventory/widget
```

---

### GET /health

**Description:** Health check endpoint for all services

**Request:**
```http
GET /health HTTP/1.1
Host: localhost:3000
```

**Response:**
```json
{
  "status": "healthy",
  "service": "store-api",
  "timestamp": "2025-10-17T15:30:00Z",
  "dependencies": {
    "orderService": "healthy",
    "inventoryService": "healthy",
    "dapr": "healthy"
  }
}
```

**Response Codes:**
- `200 OK` - Service is healthy
- `503 Service Unavailable` - Service or dependencies are unhealthy

---

## Dapr Service Invocation

When deployed to Azure Container Apps, services communicate via Dapr service invocation. Here's how to call services using Dapr:

### Invoking Order Service from Store API

```javascript
const daprPort = process.env.DAPR_HTTP_PORT || 3501;
const orderServiceAppId = 'python-app';

const response = await fetch(
  `http://localhost:${daprPort}/v1.0/invoke/${orderServiceAppId}/method/orders/order-123`,
  {
    method: 'GET',
    headers: {
      'Content-Type': 'application/json'
    }
  }
);
```

### Invoking Inventory Service from Store API

```javascript
const daprPort = process.env.DAPR_HTTP_PORT || 3501;
const inventoryServiceAppId = 'go-app';

const response = await fetch(
  `http://localhost:${daprPort}/v1.0/invoke/${inventoryServiceAppId}/method/inventory/widget`,
  {
    method: 'GET',
    headers: {
      'Content-Type': 'application/json'
    }
  }
);
```

## Error Responses

All services follow a consistent error response format:

```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable error message",
    "details": "Additional error details if available"
  }
}
```

### Common Error Codes

| Code | Description |
|------|-------------|
| `INVALID_REQUEST` | Request validation failed |
| `NOT_FOUND` | Resource not found |
| `SERVICE_UNAVAILABLE` | Dependent service unavailable |
| `INTERNAL_ERROR` | Internal server error |
| `DAPR_ERROR` | Dapr communication error |

## Rate Limiting

When deployed with API Management:

- **Default Limit**: 1000 requests per minute per IP
- **Response Header**: `X-RateLimit-Remaining` indicates remaining requests
- **Status Code**: `429 Too Many Requests` when limit exceeded

## Authentication

Currently, the sample application does not implement authentication. For production use, consider:

- Azure Active Directory integration
- OAuth 2.0 / OpenID Connect
- API keys via Azure API Management
- Managed identities for service-to-service calls

## CORS (Cross-Origin Resource Sharing)

The Store API enables CORS for all origins in development. For production:

```javascript
app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(',') || '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));
```

## API Versioning

Consider implementing API versioning for production:

### URL-based versioning
```
GET /api/v1/orders
GET /api/v2/orders
```

### Header-based versioning
```
GET /orders
API-Version: 2.0
```

## Postman Collection

A Postman collection is available for testing all endpoints:

1. Import the collection from `/docs/postman/store-api-collection.json`
2. Configure environment variables:
   - `BASE_URL`: Your application URL
   - `ORDER_ID`: Test order ID
   - `PRODUCT_ID`: Test product ID

## OpenAPI/Swagger Specification

The Store API includes an OpenAPI specification at:
- Development: `http://localhost:3000/api-docs`
- Production: `https://<your-app-url>/api-docs`

## Testing the APIs

### Integration Test Example

```bash
#!/bin/bash

# Store API base URL
BASE_URL="http://localhost:3000"

# Test 1: Get home page
echo "Test 1: Get home page"
curl -s "${BASE_URL}/" | grep -q "Store API" && echo "✓ PASS" || echo "✗ FAIL"

# Test 2: Create and retrieve order
echo "Test 2: Create and retrieve order"
ORDER_ID="test-$(date +%s)"
curl -s -X POST http://localhost:5000/orders \
  -H "Content-Type: application/json" \
  -d "{\"orderId\":\"${ORDER_ID}\",\"items\":[{\"productId\":\"test\",\"quantity\":1}]}"

curl -s "${BASE_URL}/orders?id=${ORDER_ID}" | grep -q "${ORDER_ID}" && echo "✓ PASS" || echo "✗ FAIL"

# Test 3: Get inventory
echo "Test 3: Get inventory"
curl -s "${BASE_URL}/inventory?id=widget" | grep -q "quantity" && echo "✓ PASS" || echo "✗ FAIL"
```

## Next Steps

- Review [Architecture Overview](Architecture-Overview) for system design
- Check [Troubleshooting](Troubleshooting) for common API issues
- Learn about [Monitoring](Monitoring) API performance
- Read [Local Development](Local-Development) for testing APIs locally

## Additional Resources

- [OpenAPI Specification](https://swagger.io/specification/)
- [Dapr Service Invocation](https://docs.dapr.io/developing-applications/building-blocks/service-invocation/)
- [REST API Best Practices](https://restfulapi.net/)
