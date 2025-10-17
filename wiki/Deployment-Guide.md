# Deployment Guide

This guide covers deploying the Container Apps Store API Microservice to Azure Container Apps using GitHub Actions.

## Prerequisites

Before deploying, ensure you have:

- An active Azure subscription
- Azure CLI installed (version 2.37.0 or later)
- A GitHub account with access to the repository
- Appropriate permissions to create Azure resources

## Deployment Overview

The deployment process:
1. Builds container images for each microservice
2. Pushes images to GitHub Container Registry (GHCR)
3. Creates Azure resources using Bicep templates
4. Deploys container apps to Azure
5. Configures Dapr components and networking

## Step-by-Step Deployment

### Step 1: Fork the Repository

1. Navigate to [https://github.com/TeplrGuy/container-apps-store-api-microservice](https://github.com/TeplrGuy/container-apps-store-api-microservice)
2. Click the **Fork** button in the top right
3. Select your GitHub account as the destination

### Step 2: Create Azure Service Principal

Create a service principal with contributor access to your subscription:

```bash
az login

# Get your subscription ID
az account show --query id -o tsv

# Create service principal (replace {subscription-id} with actual ID)
az ad sp create-for-rbac \
  --name "container-apps-store-api-sp" \
  --role contributor \
  --scopes /subscriptions/{subscription-id} \
  --sdk-auth
```

**Important:** Save the entire JSON output - you'll need it in the next step.

Example output:
```json
{
  "clientId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "clientSecret": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "subscriptionId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "tenantId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
  "resourceManagerEndpointUrl": "https://management.azure.com/",
  "activeDirectoryGraphResourceId": "https://graph.windows.net/",
  "sqlManagementEndpointUrl": "https://management.core.windows.net:8443/",
  "galleryEndpointUrl": "https://gallery.azure.com/",
  "managementEndpointUrl": "https://management.core.windows.net/"
}
```

### Step 3: Configure GitHub Secrets

1. Navigate to your forked repository on GitHub
2. Click **Settings** > **Secrets and variables** > **Actions**
3. Click **New repository secret**
4. Add the following secrets:

| Secret Name | Value | Description |
|-------------|-------|-------------|
| `AZURE_CREDENTIALS` | JSON output from Step 2 | Azure service principal credentials |
| `RESOURCE_GROUP` | e.g., `store-api-rg` | Name for your Azure resource group |

**Note:** The resource group will be created automatically if it doesn't exist.

### Step 4: Configure Deployment Settings (Optional)

You can customize the deployment by editing `.github/workflows/build-and-deploy.yaml`:

```yaml
env:
  # Change this to deploy with API Management
  deployApim: false  # Set to true to deploy APIM
  
  # Customize resource names
  AZURE_CONTAINER_APPS_ENVIRONMENT: store-api-env
  COSMOS_DB_ACCOUNT_NAME: store-api-cosmos
```

### Step 5: Run the Deployment

1. Go to the **Actions** tab in your GitHub repository
2. Select the **Build and Deploy** workflow
3. Click **Run workflow** dropdown
4. Select the branch (usually `main`)
5. Click the green **Run workflow** button

The workflow will:
- Build all three microservices (approximately 5 minutes)
- Push images to GHCR (approximately 2 minutes)
- Deploy Azure infrastructure (approximately 8-10 minutes)
- Deploy container apps (approximately 3-5 minutes)

**Total deployment time: 15-20 minutes**

### Step 6: Monitor Deployment Progress

You can monitor the deployment in real-time:

1. Click on the running workflow in the Actions tab
2. Click on the job name to see detailed logs
3. Each step will show green checkmarks when completed
4. Any errors will be displayed with red X marks

### Step 7: Verify Deployment

Once the workflow completes successfully:

1. Open the [Azure Portal](https://portal.azure.com)
2. Navigate to your resource group (name from `RESOURCE_GROUP` secret)
3. Verify the following resources were created:
   - Container Apps Environment
   - Three Container Apps (node-app, python-app, go-app)
   - Cosmos DB account
   - Log Analytics workspace
   - Application Insights instance
   - (Optional) API Management instance

### Step 8: Access Your Application

1. In the Azure Portal, open the **node-app** container app
2. Click on the **Application Url** in the Overview section
3. The application should load in your browser
4. Test the endpoints:
   - Home page: `https://<your-app-url>/`
   - Orders: `https://<your-app-url>/orders?id=foo`
   - Inventory: `https://<your-app-url>/inventory?id=foo`

## Deployed Azure Resources

### Container Apps Environment

The environment provides:
- Managed Kubernetes cluster
- Dapr integration
- Log Analytics workspace integration
- Networking and ingress
- Scale-to-zero capability

### Container Apps

Three container apps are deployed:

#### 1. node-app (Store API)
```yaml
Properties:
  - Ingress: External, Port 3000
  - Scale: 1-10 replicas
  - CPU: 0.5 cores
  - Memory: 1.0 Gi
  - Dapr: Enabled, App ID: node-app
```

#### 2. python-app (Order Service)
```yaml
Properties:
  - Ingress: Internal, Port 5000
  - Scale: 1-10 replicas
  - CPU: 0.5 cores
  - Memory: 1.0 Gi
  - Dapr: Enabled, App ID: python-app
```

#### 3. go-app (Inventory Service)
```yaml
Properties:
  - Ingress: Internal, Port 8050
  - Scale: 1-5 replicas
  - CPU: 0.25 cores
  - Memory: 0.5 Gi
  - Dapr: Enabled, App ID: go-app
```

### Cosmos DB

- **API Type:** SQL API
- **Consistency Level:** Session
- **Database:** ordersdb
- **Container:** orders
- **Partition Key:** /id

### Dapr Components

#### State Store Component
Automatically configured to use Cosmos DB:
```yaml
apiVersion: dapr.io/v1alpha1
kind: Component
metadata:
  name: statestore
spec:
  type: state.azure.cosmosdb
  version: v1
  metadata:
  - name: url
    value: <cosmos-db-url>
  - name: masterKey
    secretKeyRef:
      name: cosmosdb-secret
      key: master-key
  - name: database
    value: ordersdb
  - name: collection
    value: orders
```

## Deployment with API Management

To deploy with Azure API Management:

1. Edit `.github/workflows/build-and-deploy.yaml`
2. Change `deployApim: false` to `deployApim: true`
3. Commit and push the change
4. Run the workflow again

APIM provides:
- API gateway in front of Store API
- Rate limiting and throttling
- API versioning
- Developer portal
- OAuth authentication

**Note:** APIM deployment adds approximately 45 minutes to deployment time.

## Infrastructure as Code (Bicep)

The deployment uses Bicep templates in the `/deploy` folder:

| File | Purpose |
|------|---------|
| `main.bicep` | Main orchestration template |
| `environment.bicep` | Container Apps environment |
| `container-http.bicep` | Container app definitions |
| `cosmosdb.bicep` | Cosmos DB setup |
| `api-management.bicep` | APIM instance |
| `api-management-api.bicep` | APIM API configuration |

## Post-Deployment Configuration

### Enable Monitoring

Application Insights is automatically configured. View telemetry:

1. Open Application Insights in Azure Portal
2. Click **Application Map** to see service dependencies
3. Click **Live Metrics** for real-time monitoring
4. Use **Logs** for custom queries

### Configure Autoscaling

Edit scaling rules in the Azure Portal:

1. Open a Container App
2. Go to **Scale and replicas**
3. Click **Edit and deploy** > **Scale** tab
4. Add custom scaling rules:
   - HTTP traffic based
   - CPU based
   - Memory based
   - Custom metrics

### Set Up Alerts

Create alerts for important metrics:

1. In Azure Portal, go to **Monitor** > **Alerts**
2. Click **New alert rule**
3. Select your container app as the resource
4. Choose a metric (e.g., CPU percentage, replica count)
5. Set threshold and notification actions

## Updating the Deployment

To update your deployment after code changes:

1. Commit and push changes to your GitHub repository
2. The GitHub Actions workflow will automatically trigger
3. New container images will be built and deployed
4. Container Apps will perform a rolling update

## Rollback

If you need to rollback to a previous version:

```bash
# List revisions
az containerapp revision list \
  --name node-app \
  --resource-group <resource-group-name> \
  --query "[].name" -o table

# Activate a previous revision
az containerapp revision activate \
  --name node-app \
  --resource-group <resource-group-name> \
  --revision <revision-name>
```

## Cleanup

To delete all deployed resources:

```bash
az group delete --name <resource-group-name> --yes --no-wait
```

**Warning:** This will delete all resources and data. This action cannot be undone.

## Troubleshooting Deployment

### GitHub Actions Fails

**Issue:** Build fails with "permission denied"
- **Solution:** Ensure GHCR access is enabled (should work with GITHUB.TOKEN by default)

**Issue:** Azure deployment fails with authentication error
- **Solution:** Verify `AZURE_CREDENTIALS` secret contains valid JSON

**Issue:** Resource already exists error
- **Solution:** Use a unique resource group name or delete existing resources

### Container App Not Starting

**Issue:** Container app shows "Provisioning failed"
- **Solution:** Check container logs in Azure Portal
- Verify image was pushed successfully to GHCR
- Check environment variables are set correctly

**Issue:** Dapr sidecar fails to start
- **Solution:** Verify Dapr component configuration
- Check Cosmos DB connection string
- Review Dapr logs in Log Analytics

### Application Not Accessible

**Issue:** Cannot access the application URL
- **Solution:** Verify ingress is enabled on node-app
- Check if external ingress is configured
- Wait a few minutes for DNS propagation

## Cost Optimization

To minimize Azure costs:

1. **Use scale-to-zero** - Allow apps to scale down when idle
2. **Choose appropriate tiers** - Use consumption-based pricing
3. **Delete dev/test resources** - Remove when not in use
4. **Monitor spending** - Set up Azure Cost Management alerts

## Next Steps

- Configure [Monitoring](Monitoring) for production use
- Review [API Documentation](API-Documentation) for endpoint details
- Set up [CI/CD best practices](GitHub-Actions-CICD)
- Read [Troubleshooting Guide](Troubleshooting) for common issues

## Additional Resources

- [Azure Container Apps Documentation](https://docs.microsoft.com/azure/container-apps/)
- [Dapr Documentation](https://docs.dapr.io/)
- [Bicep Documentation](https://docs.microsoft.com/azure/azure-resource-manager/bicep/)
- [GitHub Actions Documentation](https://docs.github.com/actions)
