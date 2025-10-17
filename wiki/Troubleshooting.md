# Troubleshooting

This guide helps you diagnose and resolve common issues with the Container Apps Store API Microservice.

## Table of Contents

- [Local Development Issues](#local-development-issues)
- [Deployment Issues](#deployment-issues)
- [Runtime Issues](#runtime-issues)
- [Dapr Issues](#dapr-issues)
- [Networking Issues](#networking-issues)
- [Performance Issues](#performance-issues)
- [Monitoring and Debugging](#monitoring-and-debugging)

## Local Development Issues

### Port Already in Use

**Problem:** Cannot start service because port is already in use

**Error Message:**
```
Error: listen EADDRINUSE: address already in use :::3000
```

**Solution:**
```bash
# Find process using the port (Linux/Mac)
lsof -i :3000
# or
netstat -tulpn | grep 3000

# Kill the process
kill -9 <PID>

# Find process using the port (Windows)
netstat -ano | findstr :3000
taskkill /PID <PID> /F
```

---

### Dapr Not Initialized

**Problem:** Dapr commands fail with "dapr is not initialized"

**Error Message:**
```
ERROR: dapr is not initialized. Run 'dapr init' to initialize dapr
```

**Solution:**
```bash
# Initialize Dapr
dapr init

# Verify installation
dapr --version

# Check Dapr status
docker ps | grep dapr
```

---

### Service Cannot Connect to Other Services

**Problem:** Store API cannot reach Order or Inventory services

**Checklist:**
1. Verify all services are running:
   ```bash
   # Check running Dapr apps
   dapr list
   ```

2. Verify Dapr ports:
   - Store API: 3501
   - Order Service: 3500
   - Inventory Service: 3502

3. Check service app-ids match:
   ```bash
   # In Store API code, verify:
   daprAppId: 'python-app'  # For Order Service
   daprAppId: 'go-app'      # For Inventory Service
   ```

4. Test Dapr service invocation manually:
   ```bash
   curl http://localhost:3501/v1.0/invoke/python-app/method/orders/test
   ```

---

### Python Dependencies Not Found

**Problem:** Python service fails to start with import errors

**Solution:**
```bash
cd python-service

# Create virtual environment
python3 -m venv venv
source venv/bin/activate  # Linux/Mac
# or
venv\Scripts\activate  # Windows

# Install dependencies
pip install -r requirements.txt

# Run with Dapr
dapr run --app-id python-app --app-port 5000 --dapr-http-port 3500 \
  --resources-path ../dapr-components/local -- python app.py
```

---

### Go Module Issues

**Problem:** Go service fails to build or run

**Solution:**
```bash
cd go-service

# Download dependencies
go mod download

# Tidy up dependencies
go mod tidy

# Build
go build

# Run with Dapr
dapr run --app-id go-app --app-port 8050 --dapr-http-port 3502 \
  --resources-path ../dapr-components/local -- go run .
```

---

### Node.js Module Not Found

**Problem:** Node.js service fails with "Cannot find module"

**Solution:**
```bash
cd node-service

# Remove existing node_modules
rm -rf node_modules package-lock.json

# Reinstall dependencies
npm install

# Run with Dapr
dapr run --app-id node-app --app-port 3000 --dapr-http-port 3501 \
  --resources-path ../dapr-components/local -- npm start
```

---

## Deployment Issues

### GitHub Actions Workflow Fails

**Problem:** Build and Deploy workflow fails

**Common Causes and Solutions:**

1. **Invalid Azure Credentials**
   ```
   Error: Login failed with Error: Invalid credentials
   ```
   - Verify `AZURE_CREDENTIALS` secret contains valid JSON
   - Ensure service principal has contributor role
   - Check if service principal is expired

2. **GHCR Push Permission Denied**
   ```
   Error: denied: permission_denied
   ```
   - Ensure GHCR is enabled for the repository
   - Verify GITHUB_TOKEN has write permissions
   - Delete old packages from GHCR if pushed with PAT

3. **Resource Already Exists**
   ```
   Error: Resource already exists
   ```
   - Use a different resource group name
   - Delete existing resources: `az group delete --name <rg-name>`

4. **Quota Exceeded**
   ```
   Error: Operation results in exceeding quota limits
   ```
   - Check Azure subscription quotas
   - Request quota increase or use different region

---

### Container Build Fails

**Problem:** Docker image build fails during GitHub Actions

**Solution:**
```yaml
# Check Dockerfile syntax
docker build -t test-image -f node-service/Dockerfile node-service/

# Common Dockerfile issues:
# 1. Invalid base image
# 2. Missing dependencies
# 3. Incorrect file paths
# 4. Permission issues
```

---

### Azure Resource Creation Fails

**Problem:** Bicep deployment fails

**Solution:**
```bash
# Validate Bicep template locally
az bicep build --file deploy/main.bicep

# Test deployment in validation mode
az deployment group create \
  --resource-group <rg-name> \
  --template-file deploy/main.bicep \
  --mode Validate

# Check deployment logs
az deployment group show \
  --resource-group <rg-name> \
  --name <deployment-name>
```

---

## Runtime Issues

### Container App Not Starting

**Problem:** Container app shows "Provisioning failed" or "Running" but not accessible

**Diagnosis Steps:**

1. **Check Container Logs:**
   ```bash
   az containerapp logs show \
     --name node-app \
     --resource-group <rg-name> \
     --follow
   ```

2. **Check Revision Status:**
   ```bash
   az containerapp revision list \
     --name node-app \
     --resource-group <rg-name> \
     --query "[].{Name:name, Active:properties.active, Health:properties.healthState}"
   ```

3. **Check Dapr Logs:**
   - Go to Azure Portal > Container App > Logs
   - Query Dapr logs:
   ```kusto
   ContainerAppConsoleLogs_CL
   | where ContainerAppName_s == "node-app"
   | where ContainerName_s contains "daprd"
   | order by TimeGenerated desc
   ```

**Common Issues:**

1. **Image Pull Failure**
   - Verify image exists in GHCR
   - Check image tag is correct
   - Ensure GHCR is accessible

2. **Application Crash Loop**
   - Check application logs for errors
   - Verify environment variables
   - Check resource limits (CPU/Memory)

3. **Health Probe Failure**
   - Verify application is listening on correct port
   - Check if health endpoint is implemented
   - Adjust probe timeout settings

---

### Service Returns 500 Error

**Problem:** API calls return HTTP 500 Internal Server Error

**Diagnosis:**

1. **Check Application Logs:**
   ```bash
   az containerapp logs show \
     --name node-app \
     --resource-group <rg-name> \
     --follow
   ```

2. **Test Service Directly:**
   ```bash
   # Get container app FQDN
   az containerapp show \
     --name node-app \
     --resource-group <rg-name> \
     --query properties.configuration.ingress.fqdn

   # Test endpoint
   curl https://<app-fqdn>/
   ```

3. **Check Dapr Communication:**
   - Verify Dapr sidecars are running
   - Check Dapr component configuration
   - Test service invocation

---

### State Not Persisting

**Problem:** Orders are not saved or retrieved correctly

**Diagnosis:**

1. **Verify Dapr State Store Component:**
   ```bash
   az containerapp env dapr-component show \
     --name statestore \
     --environment-name <env-name> \
     --resource-group <rg-name>
   ```

2. **Check Cosmos DB Connection:**
   ```bash
   # Verify Cosmos DB is accessible
   az cosmosdb show \
     --name <cosmos-name> \
     --resource-group <rg-name>

   # Test connection
   az cosmosdb sql database show \
     --account-name <cosmos-name> \
     --name ordersdb \
     --resource-group <rg-name>
   ```

3. **Check Application Code:**
   - Verify Dapr state API calls are correct
   - Check partition key configuration
   - Review error logs

---

## Dapr Issues

### Dapr Sidecar Not Injected

**Problem:** Container app runs without Dapr sidecar

**Solution:**
```bash
# Verify Dapr is enabled for the app
az containerapp show \
  --name node-app \
  --resource-group <rg-name> \
  --query properties.configuration.dapr

# Enable Dapr if not enabled
az containerapp update \
  --name node-app \
  --resource-group <rg-name> \
  --enable-dapr \
  --dapr-app-id node-app \
  --dapr-app-port 3000
```

---

### Dapr Service Invocation Fails

**Problem:** Services cannot communicate via Dapr

**Diagnosis:**
```bash
# Check Dapr logs
az containerapp logs show \
  --name node-app \
  --resource-group <rg-name> \
  --container daprd \
  --follow

# Common issues:
# 1. Incorrect app-id
# 2. Target service not running
# 3. Network policy blocking communication
# 4. Dapr version mismatch
```

**Solution:**
- Verify app-id matches between services
- Check all services have Dapr enabled
- Ensure services are in same environment

---

## Networking Issues

### Cannot Access Application URL

**Problem:** Application URL not accessible or returns 404

**Checklist:**

1. **Verify Ingress Configuration:**
   ```bash
   az containerapp ingress show \
     --name node-app \
     --resource-group <rg-name>
   ```

2. **Check if External Ingress:**
   - Ingress type should be "external" for node-app
   - Internal services (python-app, go-app) not directly accessible

3. **DNS Propagation:**
   - Wait 5-10 minutes for DNS to propagate
   - Try accessing via IP if DNS fails

4. **Firewall/NSG Rules:**
   - Check if corporate firewall blocks access
   - Verify network security groups if using VNet integration

---

### Services Cannot Reach Each Other

**Problem:** Service-to-service calls fail

**Solution:**
```bash
# Verify all services are in same environment
az containerapp list \
  --resource-group <rg-name> \
  --query "[].{Name:name, Environment:properties.environmentId}" -o table

# Check Dapr service discovery
# Services must use Dapr service invocation for internal communication
```

---

## Performance Issues

### Slow Response Times

**Problem:** API responses are slow

**Diagnosis Steps:**

1. **Check Application Insights:**
   - View dependency response times
   - Check for failed requests
   - Review performance metrics

2. **Review Resource Limits:**
   ```bash
   az containerapp show \
     --name node-app \
     --resource-group <rg-name> \
     --query properties.template.containers[0].resources
   ```

3. **Check Scaling Configuration:**
   ```bash
   az containerapp show \
     --name node-app \
     --resource-group <rg-name> \
     --query properties.template.scale
   ```

**Solutions:**
- Increase CPU/Memory allocation
- Adjust scaling rules (more replicas)
- Optimize database queries
- Enable caching

---

### Container App Not Scaling

**Problem:** Application doesn't scale under load

**Solution:**
```bash
# Check current replica count
az containerapp revision show \
  --name node-app \
  --resource-group <rg-name> \
  --revision <revision-name> \
  --query properties.replicas

# Review scaling rules
az containerapp show \
  --name node-app \
  --resource-group <rg-name> \
  --query properties.template.scale

# Update scaling rules
az containerapp update \
  --name node-app \
  --resource-group <rg-name> \
  --min-replicas 2 \
  --max-replicas 10
```

---

## Monitoring and Debugging

### Viewing Logs

**Container App Logs:**
```bash
# Real-time logs
az containerapp logs show \
  --name node-app \
  --resource-group <rg-name> \
  --follow

# Specific container (Dapr)
az containerapp logs show \
  --name node-app \
  --resource-group <rg-name> \
  --container daprd \
  --follow
```

**Log Analytics Queries:**
```kusto
// All logs for an app
ContainerAppConsoleLogs_CL
| where ContainerAppName_s == "node-app"
| order by TimeGenerated desc

// Error logs only
ContainerAppConsoleLogs_CL
| where ContainerAppName_s == "node-app"
| where Log_s contains "error" or Log_s contains "Error"
| order by TimeGenerated desc

// Dapr logs
ContainerAppConsoleLogs_CL
| where ContainerAppName_s == "node-app"
| where ContainerName_s contains "daprd"
| order by TimeGenerated desc
```

---

### Debugging with Application Insights

**View Distributed Traces:**
1. Open Application Insights in Azure Portal
2. Go to **Application Map**
3. Click on a node to see dependencies
4. View individual requests in **End-to-end transaction**

**Query Traces:**
```kusto
// Failed requests
requests
| where success == false
| order by timestamp desc

// Slow requests (> 1 second)
requests
| where duration > 1000
| order by duration desc

// Dependency calls
dependencies
| where target contains "python-app" or target contains "go-app"
| order by timestamp desc
```

---

### Enable Debug Logging

**Node.js (Store API):**
```bash
# Set environment variable
az containerapp update \
  --name node-app \
  --resource-group <rg-name> \
  --set-env-vars "LOG_LEVEL=debug"
```

**Python (Order Service):**
```bash
az containerapp update \
  --name python-app \
  --resource-group <rg-name> \
  --set-env-vars "FLASK_ENV=development" "LOG_LEVEL=DEBUG"
```

**Dapr:**
```bash
# Update Dapr with debug logging
az containerapp update \
  --name node-app \
  --resource-group <rg-name> \
  --dapr-log-level debug
```

---

## Getting Help

If you can't resolve your issue:

1. **Check GitHub Issues**: [View existing issues](https://github.com/TeplrGuy/container-apps-store-api-microservice/issues)
2. **Create New Issue**: Include:
   - Detailed description of the problem
   - Steps to reproduce
   - Error messages and logs
   - Environment details (local/Azure, OS, versions)
3. **Azure Support**: For Azure-specific issues, contact Azure Support

## Related Documentation

- [Getting Started](Getting-Started) - Initial setup guide
- [Deployment Guide](Deployment-Guide) - Deployment instructions
- [Monitoring](Monitoring) - Monitoring and observability
- [API Documentation](API-Documentation) - API reference

## Additional Resources

- [Azure Container Apps Troubleshooting](https://docs.microsoft.com/azure/container-apps/troubleshooting)
- [Dapr Troubleshooting](https://docs.dapr.io/operations/troubleshooting/)
- [GitHub Actions Debugging](https://docs.github.com/actions/monitoring-and-troubleshooting-workflows)
