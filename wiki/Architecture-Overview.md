# Architecture Overview

This document provides a comprehensive overview of the Container Apps Store API Microservice architecture.

## System Architecture

![Architecture Diagram](../assets/arch.png)

The application consists of three microservices that communicate via Dapr service invocation and use Dapr state management for data persistence.

## Architecture Components

### 1. Store API (Node.js)
- **Technology**: Express.js (Node.js)
- **Port**: 3000
- **Dapr Port**: 3501
- **App ID**: `node-app`

**Responsibilities:**
- Serves as the primary entry point for the application
- Provides web UI for user interaction
- Acts as a gateway to other microservices
- Handles HTTP requests and routes them to appropriate services

**Key Endpoints:**
- `GET /` - Main application page
- `GET /orders?id={id}` - Retrieve order information
- `GET /inventory?id={id}` - Retrieve inventory information

### 2. Order Service (Python)
- **Technology**: Flask (Python)
- **Port**: 5000
- **Dapr Port**: 3500
- **App ID**: `python-app`

**Responsibilities:**
- Manages order creation and retrieval
- Persists order state using Dapr state management
- Provides REST API for order operations

**State Management:**
- Uses Dapr State Store API
- Local development: Redis
- Production: Azure Cosmos DB

### 3. Inventory Service (Go)
- **Technology**: Go with Mux router
- **Port**: 8050
- **Dapr Port**: 3502
- **App ID**: `go-app`

**Responsibilities:**
- Manages inventory information
- Returns product availability status
- Provides REST API for inventory operations

## Communication Patterns

### Service-to-Service Communication

The Store API communicates with the Order and Inventory services using Dapr service invocation:

```javascript
// Example: Store API calling Order Service
const response = await fetch(
  `http://localhost:${daprPort}/v1.0/invoke/python-app/method/orders`,
  {
    headers: {
      'dapr-app-id': 'python-app'
    }
  }
);
```

**Benefits of Dapr Service Invocation:**
- Service discovery
- Automatic retries
- Distributed tracing
- mTLS encryption
- Load balancing

### State Management

The Order Service uses Dapr State Management API for persisting order data:

```python
# Saving state
response = requests.post(
    f"http://localhost:{dapr_port}/v1.0/state/statestore",
    json=[{"key": order_id, "value": order_data}]
)

# Retrieving state
response = requests.get(
    f"http://localhost:{dapr_port}/v1.0/state/statestore/{order_id}"
)
```

## Distributed Application Runtime (Dapr)

### Dapr Sidecars

Each microservice runs with a Dapr sidecar container:

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Store API     │     │  Order Service  │     │ Inventory Svc   │
│   (Node.js)     │     │    (Python)     │     │      (Go)       │
│                 │     │                 │     │                 │
│   Port: 3000    │     │   Port: 5000    │     │   Port: 8050    │
└────────┬────────┘     └────────┬────────┘     └────────┬────────┘
         │                       │                       │
         │ HTTP                  │ HTTP                  │ HTTP
         │                       │                       │
┌────────▼────────┐     ┌────────▼────────┐     ┌────────▼────────┐
│  Dapr Sidecar   │◄────┤  Dapr Sidecar   │◄────┤  Dapr Sidecar   │
│   Port: 3501    │────►│   Port: 3500    │────►│   Port: 3502    │
└─────────────────┘     └─────────────────┘     └─────────────────┘
         │                       │                       │
         │                       │                       │
         └───────────────────────┴───────────────────────┘
                                 │
                                 ▼
                        ┌─────────────────┐
                        │   State Store   │
                        │ (Redis/Cosmos)  │
                        └─────────────────┘
```

### Dapr Components

#### State Store Component
```yaml
apiVersion: dapr.io/v1alpha1
kind: Component
metadata:
  name: statestore
spec:
  type: state.azure.cosmosdb  # or state.redis for local
  version: v1
  metadata:
  - name: url
    value: <cosmos-db-url>
  - name: masterKey
    value: <cosmos-db-key>
  - name: database
    value: <database-name>
  - name: collection
    value: <collection-name>
```

## Azure Container Apps Environment

When deployed to Azure, the architecture leverages several Azure services:

### Container Apps Environment
- Managed Kubernetes-based environment
- Integrated Dapr runtime
- Built-in observability with Azure Monitor
- Automatic HTTPS ingress
- Scale-to-zero capabilities

### Supporting Azure Resources

1. **Azure Cosmos DB**
   - NoSQL database for state persistence
   - Configured as Dapr state store
   - Provides global distribution and high availability

2. **Log Analytics Workspace**
   - Centralized logging for all container apps
   - Query logs using Kusto Query Language (KQL)
   - Integrated with Azure Monitor

3. **Application Insights**
   - Distributed tracing with Dapr
   - Performance monitoring
   - Application Map visualization
   - Custom metrics and dashboards

4. **Azure API Management** (Optional)
   - API gateway for the Store API
   - Rate limiting and throttling
   - API versioning
   - OAuth authentication
   - Developer portal

## Scalability

### KEDA Autoscaling

The application can scale based on various metrics:

- **HTTP Traffic**: Scale based on incoming requests
- **Queue Length**: Scale based on message queue depth
- **Custom Metrics**: Scale based on application-specific metrics

Example scaling configuration:
```yaml
resources:
  scale:
    minReplicas: 1
    maxReplicas: 10
    rules:
    - name: http-rule
      http:
        metadata:
          concurrentRequests: 50
```

### Scale-to-Zero

- Container Apps can scale down to zero instances when idle
- Automatically scale up when requests arrive
- Reduces costs for development/test environments

## Security

### Network Security
- Services communicate within a virtual network
- Ingress can be restricted to internal only
- Optional integration with Azure Virtual Network

### Authentication & Authorization
- Azure Active Directory integration
- Managed identities for Azure resource access
- API Management for API key management

### Secrets Management
- Secrets stored in Azure Key Vault
- Dapr secret store integration
- No secrets in configuration files

## Observability

### Distributed Tracing
- Dapr automatically instruments HTTP calls
- Traces exported to Application Insights
- End-to-end request tracking across services

### Logging
- Stdout/stderr captured by Container Apps
- Logs aggregated in Log Analytics
- Structured logging recommended

### Metrics
- Built-in metrics from Container Apps
- Dapr metrics for service invocation
- Custom application metrics

## Design Patterns

### Microservices Patterns Used

1. **API Gateway Pattern**
   - Store API acts as a gateway
   - Single entry point for clients
   - Routes requests to appropriate services

2. **Sidecar Pattern**
   - Dapr runs as a sidecar to each service
   - Separates infrastructure concerns from application logic

3. **Service Discovery**
   - Dapr provides automatic service discovery
   - Services referenced by app-id

4. **External Configuration**
   - Dapr components configured externally
   - No code changes needed for environment changes

5. **Health Check Pattern**
   - Container Apps perform health checks
   - Automatic restart of unhealthy containers

## Technology Stack Summary

| Component | Technology | Purpose |
|-----------|-----------|---------|
| Store API | Node.js + Express | Web frontend and API gateway |
| Order Service | Python + Flask | Order management |
| Inventory Service | Go + Mux | Inventory management |
| Service Mesh | Dapr | Service communication and state |
| Container Platform | Azure Container Apps | Serverless containers |
| State Store | Azure Cosmos DB | Persistent state storage |
| Monitoring | Application Insights | Observability and tracing |
| Infrastructure | Bicep | Infrastructure as Code |
| CI/CD | GitHub Actions | Automated deployment |

## Next Steps

- Learn about [Microservices](Microservices) implementation details
- Understand [Dapr Integration](Dapr-Integration) in depth
- Review [Deployment Guide](Deployment-Guide) for production setup
- Explore [Monitoring](Monitoring) capabilities
