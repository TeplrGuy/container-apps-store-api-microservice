# Getting Started

This guide will help you get the Container Apps Store API Microservice up and running quickly.

## Prerequisites

Before you begin, ensure you have:

### Required
- **GitHub Account** - For repository access and GitHub Actions
- **Azure Subscription** - For deploying to Azure Container Apps
- **Azure CLI** - Version 2.37.0 or later
- **Git** - For cloning the repository

### For Local Development
- **Docker Desktop** - For running containers locally
- **Node.js** - Version 14.x or later (for the Store API)
- **Python** - Version 3.8 or later (for the Order Service)
- **Go** - Version 1.18 or later (for the Inventory Service)
- **Dapr CLI** - For running Dapr locally

## Quick Start Options

Choose the method that best fits your needs:

### Option 1: GitHub Codespaces (Recommended)
The fastest way to get started with zero local setup required.

1. Navigate to the [repository](https://github.com/TeplrGuy/container-apps-store-api-microservice)
2. Click the **Code** button
3. Select **Codespaces** tab
4. Click **Create codespace on main**
5. Wait for the environment to initialize
6. Select **All Services** from the debug menu
7. Press F5 to start debugging

### Option 2: Deploy to Azure via GitHub Actions
Deploy directly to Azure Container Apps using automated CI/CD.

1. **Fork the repository**
   ```bash
   # Visit https://github.com/TeplrGuy/container-apps-store-api-microservice
   # Click the "Fork" button
   ```

2. **Create Azure Service Principal**
   ```bash
   az ad sp create-for-rbac --name "container-apps-store-api" --role contributor \
     --scopes /subscriptions/{subscription-id} \
     --sdk-auth
   ```

3. **Configure GitHub Secrets**
   - Navigate to your forked repository
   - Go to Settings > Secrets and variables > Actions
   - Add the following secrets:
     - `AZURE_CREDENTIALS` - JSON output from the service principal creation
     - `RESOURCE_GROUP` - Name for your Azure resource group (e.g., "store-api-rg")

4. **Run the Deployment Workflow**
   - Go to Actions tab
   - Select "Build and Deploy" workflow
   - Click "Run workflow"
   - Wait for deployment to complete (approximately 10-15 minutes)

5. **Access Your Application**
   - Go to Azure Portal
   - Open your resource group
   - Find the `node-app` Container App
   - Click on the Application URL

### Option 3: Local Development with Docker
Run the application locally using Docker and Dapr.

1. **Clone the repository**
   ```bash
   git clone https://github.com/TeplrGuy/container-apps-store-api-microservice.git
   cd container-apps-store-api-microservice
   ```

2. **Initialize Dapr**
   ```bash
   dapr init
   ```

3. **Start the services**
   
   Terminal 1 - Order Service:
   ```bash
   cd python-service
   pip install -r requirements.txt
   dapr run --app-id python-app --app-port 5000 --dapr-http-port 3500 \
     --resources-path ../dapr-components/local -- python app.py
   ```
   
   Terminal 2 - Inventory Service:
   ```bash
   cd go-service
   go mod download
   dapr run --app-id go-app --app-port 8050 --dapr-http-port 3502 \
     --resources-path ../dapr-components/local -- go run .
   ```
   
   Terminal 3 - Store API:
   ```bash
   cd node-service
   npm install
   dapr run --app-id node-app --app-port 3000 --dapr-http-port 3501 \
     --resources-path ../dapr-components/local -- npm start
   ```

4. **Access the application**
   - Open your browser to http://localhost:3000
   - Try the endpoints:
     - `/` - Home page
     - `/orders?id=foo` - Order details
     - `/inventory?id=foo` - Inventory details

## Verifying Your Installation

### Check Service Health

1. **Store API Health Check**
   ```bash
   curl http://localhost:3000/
   ```

2. **Order Service Health Check**
   ```bash
   curl http://localhost:5000/
   ```

3. **Inventory Service Health Check**
   ```bash
   curl http://localhost:8050/
   ```

### Test the Application Flow

1. **Create an Order**
   - Navigate to http://localhost:3000
   - Use the UI to create a test order

2. **Retrieve Order**
   ```bash
   curl http://localhost:3000/orders?id=foo
   ```

3. **Check Inventory**
   ```bash
   curl http://localhost:3000/inventory?id=foo
   ```

## Next Steps

Now that you have the application running:

1. **Explore the Architecture** - Read the [Architecture Overview](Architecture-Overview) to understand how the services interact
2. **Review the APIs** - Check out the [API Documentation](API-Documentation) for detailed endpoint information
3. **Customize the Application** - Learn about [Local Development](Local-Development) to start making changes
4. **Monitor Your Application** - Set up [Monitoring](Monitoring) to track performance and issues

## Troubleshooting

If you encounter issues during setup:

- **Port Conflicts** - Ensure ports 3000, 3500, 3501, 3502, 5000, and 8050 are available
- **Dapr Issues** - Run `dapr --version` to verify installation
- **Azure Deployment Fails** - Check that your service principal has correct permissions
- **Container Build Errors** - Ensure Docker Desktop is running

For more help, see the [Troubleshooting Guide](Troubleshooting).

## Support

- [Report Issues](https://github.com/TeplrGuy/container-apps-store-api-microservice/issues)
- [View Documentation](Home)
- [Contributing Guidelines](Contributing-Guide)
