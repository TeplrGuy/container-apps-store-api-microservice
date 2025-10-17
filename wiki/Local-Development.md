# Local Development

This guide covers everything you need to know about developing the Container Apps Store API Microservice locally.

## Development Environment Options

You have four options for local development:

1. **GitHub Codespaces** (Recommended) - Zero setup, runs in the cloud
2. **VS Code Dev Containers** - Consistent environment using Docker
3. **VS Code with Extensions** - Direct development with tools installed
4. **Manual Setup** - Maximum control, requires all tools

## Prerequisites by Option

### Option 1: GitHub Codespaces
- GitHub account with Codespaces access
- Web browser

### Option 2: VS Code Dev Containers
- [Visual Studio Code](https://code.visualstudio.com/)
- [Docker Desktop](https://www.docker.com/products/docker-desktop)
- [Remote Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

### Option 3 & 4: Local Development
- [Visual Studio Code](https://code.visualstudio.com/)
- [Node.js](https://nodejs.org/) (v14 or later)
- [Python](https://www.python.org/) (v3.8 or later)
- [Go](https://golang.org/) (v1.18 or later)
- [Dapr CLI](https://docs.dapr.io/getting-started/install-dapr-cli/)
- [Docker Desktop](https://www.docker.com/products/docker-desktop)
- [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli) (optional)

## Setting Up Your Environment

### Option 1: GitHub Codespaces

1. Navigate to the repository on GitHub
2. Click **Code** > **Codespaces** > **Create codespace on main**
3. Wait for initialization (2-3 minutes)
4. Codespace opens with VS Code in browser
5. All tools and dependencies are pre-installed

**Running the Application:**
```bash
# All services are configured in .devcontainer/devcontainer.json
# Press F5 or go to Run and Debug > "All Services"
# Services will start automatically with Dapr
```

---

### Option 2: VS Code Dev Containers

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/TeplrGuy/container-apps-store-api-microservice.git
   cd container-apps-store-api-microservice
   ```

2. **Open in VS Code:**
   ```bash
   code .
   ```

3. **Reopen in Container:**
   - VS Code will prompt: "Folder contains a Dev Container configuration file"
   - Click **Reopen in Container**
   - Wait for container to build (5-10 minutes first time)

4. **Start Development:**
   - Press F5 or select **Run and Debug** > **All Services**
   - Services start with Dapr sidecars

---

### Option 3: VS Code with Extensions

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/TeplrGuy/container-apps-store-api-microservice.git
   cd container-apps-store-api-microservice
   ```

2. **Install Recommended Extensions:**
   - Open VS Code
   - When prompted, click **Install** for recommended extensions
   - Or manually install from `.vscode/extensions.json`

3. **Initialize Dapr:**
   ```bash
   dapr init
   ```

4. **Install Dependencies:**
   ```bash
   # Node.js service
   cd node-service
   npm install
   cd ..

   # Python service
   cd python-service
   pip install -r requirements.txt
   cd ..

   # Go service
   cd go-service
   go mod download
   cd ..
   ```

5. **Start Development:**
   - Press F5 or select **Run and Debug** > **All Services**

---

### Option 4: Manual Setup

1. **Clone and Install:**
   ```bash
   git clone https://github.com/TeplrGuy/container-apps-store-api-microservice.git
   cd container-apps-store-api-microservice
   ```

2. **Initialize Dapr:**
   ```bash
   dapr init
   dapr --version
   ```

3. **Install Service Dependencies:**
   ```bash
   # Node.js
   cd node-service && npm install && cd ..
   
   # Python (recommended: use virtual environment)
   cd python-service
   python3 -m venv venv
   source venv/bin/activate  # Linux/Mac
   # venv\Scripts\activate    # Windows
   pip install -r requirements.txt
   cd ..
   
   # Go
   cd go-service && go mod download && cd ..
   ```

4. **Run Services Manually:**

   **Terminal 1 - Order Service (Python):**
   ```bash
   cd python-service
   dapr run --app-id python-app --app-port 5000 --dapr-http-port 3500 \
     --resources-path ../dapr-components/local -- python app.py
   ```

   **Terminal 2 - Inventory Service (Go):**
   ```bash
   cd go-service
   dapr run --app-id go-app --app-port 8050 --dapr-http-port 3502 \
     --resources-path ../dapr-components/local -- go run .
   ```

   **Terminal 3 - Store API (Node.js):**
   ```bash
   cd node-service
   dapr run --app-id node-app --app-port 3000 --dapr-http-port 3501 \
     --resources-path ../dapr-components/local -- npm start
   ```

## Development Workflow

### Making Code Changes

1. **Edit Files:**
   - Node.js: Edit files in `node-service/`
   - Python: Edit files in `python-service/`
   - Go: Edit files in `go-service/`

2. **Auto-Reload (Development Mode):**

   **Node.js** (using nodemon):
   ```bash
   cd node-service
   npm run dev  # Uses nodemon for auto-reload
   ```

   **Python** (using Flask debug mode):
   ```bash
   cd python-service
   export FLASK_ENV=development
   dapr run --app-id python-app --app-port 5000 --dapr-http-port 3500 \
     --resources-path ../dapr-components/local -- flask run
   ```

   **Go** (using air for live reload):
   ```bash
   cd go-service
   # Install air: go install github.com/cosmtrek/air@latest
   dapr run --app-id go-app --app-port 8050 --dapr-http-port 3502 \
     --resources-path ../dapr-components/local -- air
   ```

3. **Test Changes:**
   ```bash
   # Access the application
   open http://localhost:3000
   
   # Or use curl
   curl http://localhost:3000/
   curl http://localhost:3000/orders?id=foo
   curl http://localhost:3000/inventory?id=widget
   ```

### Debugging

#### VS Code Debugging

The repository includes launch configurations in `.vscode/launch.json`:

**Available Debug Configurations:**
- **All Services** - Starts all three services with Dapr
- **Node Service** - Debug only the Store API
- **Python Service** - Debug only the Order Service
- **Go Service** - Debug only the Inventory Service

**To Debug:**
1. Set breakpoints in your code
2. Press F5 or go to **Run and Debug**
3. Select configuration from dropdown
4. Start debugging

#### Node.js Debugging
```javascript
// Add debugger statement in code
app.get('/orders', async (req, res) => {
  debugger;  // Execution will pause here
  const orderId = req.query.id;
  // ...
});
```

#### Python Debugging
```python
# Add breakpoint in VS Code or use pdb
import pdb

@app.route('/orders/<order_id>')
def get_order(order_id):
    pdb.set_trace()  # Debugger will stop here
    # ...
```

#### Go Debugging
```go
// Use delve debugger
// Set breakpoints in VS Code
func getInventory(w http.ResponseWriter, r *http.Request) {
    vars := mux.Vars(r)
    // Set breakpoint here in VS Code
    productId := vars["id"]
}
```

### Testing

#### Running Unit Tests

**Node.js:**
```bash
cd node-service
npm test
npm run test:coverage  # With coverage report
```

**Python:**
```bash
cd python-service
pytest
pytest --cov=app  # With coverage
```

**Go:**
```bash
cd go-service
go test ./...
go test -cover ./...  # With coverage
```

#### Running Integration Tests

```bash
# Start all services first
# Then run integration tests

# Node.js integration tests
cd node-service
npm run test:integration

# Python integration tests
cd python-service
pytest tests/integration/

# Go integration tests
cd go-service
go test -tags=integration ./...
```

#### Manual API Testing

**Using cURL:**
```bash
# Test Store API
curl http://localhost:3000/

# Test Order Service directly
curl http://localhost:5000/orders/test-order

# Test Inventory Service directly
curl http://localhost:8050/inventory/widget

# Test Dapr service invocation
curl http://localhost:3501/v1.0/invoke/python-app/method/orders/test
```

**Using Postman:**
1. Import collection from `docs/postman/` (if available)
2. Set environment variables
3. Run collection

### Working with Dapr

#### Viewing Dapr Dashboard

```bash
# Start Dapr dashboard
dapr dashboard

# Access at http://localhost:8080
```

Dashboard shows:
- Running Dapr applications
- Components configuration
- Control plane services
- Logs and metrics

#### Testing State Management

```bash
# Save state using Dapr API
curl -X POST http://localhost:3500/v1.0/state/statestore \
  -H "Content-Type: application/json" \
  -d '[{
    "key": "test-key",
    "value": "test-value"
  }]'

# Get state
curl http://localhost:3500/v1.0/state/statestore/test-key

# Delete state
curl -X DELETE http://localhost:3500/v1.0/state/statestore/test-key
```

#### Testing Service Invocation

```bash
# Invoke Order Service through Dapr
curl http://localhost:3501/v1.0/invoke/python-app/method/orders/test

# Invoke Inventory Service through Dapr
curl http://localhost:3501/v1.0/invoke/go-app/method/inventory/widget
```

### Local State Store

By default, local development uses Redis for state storage:

```bash
# Check Redis container is running
docker ps | grep redis

# Connect to Redis CLI
docker exec -it dapr_redis redis-cli

# View all keys
KEYS *

# Get value
GET "python-app||order-123"
```

### Environment Variables

Create `.env` files for local development:

**node-service/.env:**
```env
NODE_ENV=development
PORT=3000
DAPR_HTTP_PORT=3501
LOG_LEVEL=debug
```

**python-service/.env:**
```env
FLASK_ENV=development
DAPR_HTTP_PORT=3500
LOG_LEVEL=DEBUG
```

**go-service/.env:**
```env
APP_PORT=8050
DAPR_HTTP_PORT=3502
LOG_LEVEL=debug
```

### Code Formatting and Linting

**Node.js:**
```bash
cd node-service
npm run lint          # Check for issues
npm run lint:fix      # Auto-fix issues
npm run format        # Format code (if using Prettier)
```

**Python:**
```bash
cd python-service
flake8 .              # Lint code
black .               # Format code
pylint app.py         # Advanced linting
```

**Go:**
```bash
cd go-service
gofmt -w .            # Format code
go vet ./...          # Check for issues
golangci-lint run     # Advanced linting
```

### Git Workflow

1. **Create Feature Branch:**
   ```bash
   git checkout -b feature/my-new-feature
   ```

2. **Make Changes and Commit:**
   ```bash
   git add .
   git commit -m "Add new feature"
   ```

3. **Push and Create PR:**
   ```bash
   git push origin feature/my-new-feature
   # Create pull request on GitHub
   ```

4. **CI/CD Will Run:**
   - Build all services
   - Run tests
   - Check code quality

### Hot Reload Configuration

**Node.js (nodemon.json):**
```json
{
  "watch": ["*.js", "routes/*.js"],
  "ext": "js,json",
  "ignore": ["node_modules/"],
  "exec": "node app.js"
}
```

**Python (Flask debug mode):**
```python
if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
```

## Common Development Tasks

### Adding a New Endpoint

**Store API (Node.js):**
```javascript
// In node-service/routes/index.js
router.get('/new-endpoint', async (req, res) => {
  try {
    // Your logic here
    res.json({ message: 'Success' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});
```

### Adding a New Environment Variable

1. Add to local `.env` file
2. Update Azure deployment in `.github/workflows/build-and-deploy.yaml`
3. Document in README.md

### Updating Dependencies

**Node.js:**
```bash
npm update
npm audit fix  # Fix security vulnerabilities
```

**Python:**
```bash
pip install --upgrade -r requirements.txt
pip-review --auto  # Update all packages
```

**Go:**
```bash
go get -u ./...
go mod tidy
```

## Performance Profiling

### Node.js Profiling
```bash
node --prof app.js
node --prof-process isolate-*.log > profile.txt
```

### Python Profiling
```bash
pip install py-spy
py-spy top -- python app.py
```

### Go Profiling
```go
import _ "net/http/pprof"

// Access profiling at http://localhost:6060/debug/pprof/
go tool pprof http://localhost:6060/debug/pprof/profile
```

## Troubleshooting Local Development

See the [Troubleshooting Guide](Troubleshooting#local-development-issues) for common issues.

## Next Steps

- Review [Architecture Overview](Architecture-Overview) to understand the system
- Check [API Documentation](API-Documentation) for endpoint details
- Learn about [Deployment](Deployment-Guide) to Azure
- Explore [Contributing Guide](Contributing-Guide) for contribution guidelines

## Additional Resources

- [VS Code Documentation](https://code.visualstudio.com/docs)
- [Dapr Local Development](https://docs.dapr.io/developing-applications/local-development/)
- [Docker Documentation](https://docs.docker.com/)
- [GitHub Codespaces Documentation](https://docs.github.com/codespaces)
