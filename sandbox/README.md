# Sandbox (private) Azure environment — ARM templates

This folder contains **Azure ARM templates** for deploying Azure resources to your own private sandbox environment. Two deployment options are available:

1. **Private Link Infrastructure** (`rg.main.json`) - VNet with Private Endpoints for secure PaaS connectivity
2. **Dapr Albums Microservices** (`albums-app.json`) - Complete Container Apps deployment of the albums demo application

All templates are fully parameterized so you can **customize every resource name** during deployment.

---

## 📁 Files

### Private Link Infrastructure
- `templates/rg.main.json` - Main ARM template for Private Link infrastructure
- `templates/rg.parameters.example.json` - Example parameters file
- `deploy.ps1` - PowerShell deployment script for Private Link infrastructure

### Dapr Albums Application
- `templates/albums-app.json` - ARM template for Dapr Albums microservices on Container Apps
- `templates/albums-app.parameters.example.json` - Example parameters file for albums app
- `deploy-albums.ps1` - PowerShell deployment script for albums app
- `deploy-albums.sh` - Bash deployment script for albums app

---

## 🎯 Option 1: Private Link Infrastructure

Deploys a private, Private Link–oriented sandbox environment:

### What this deploys
- Virtual Network + subnets (including a subnet suitable for Private Endpoints)
- Private DNS zones + VNet links
- One or more Key Vaults
- One or more App Configuration stores
- One or more Storage Accounts
- Optional Log Analytics + Application Insights
- An arbitrary set of Private Endpoints wired to Private DNS zone groups

### Prerequisites
- Azure CLI (`az`) installed and logged in
- Permissions to create:
  - Resource group
  - Networking resources (VNet, Private Endpoints, Private DNS)
  - Key Vault / App Configuration / Storage

### Deploy

1. Copy and customize the parameters:
   ```bash
   cp templates/rg.parameters.example.json templates/rg.parameters.json
   # Edit templates/rg.parameters.json with your desired names and settings
   ```

2. Run the deployment:
   ```powershell
   ./deploy.ps1 -SubscriptionId <subId> -ResourceGroupName <rgName> -Location <azureRegion> -ParametersFile templates/rg.parameters.json
   ```

### Notes
- Private Endpoints create NICs automatically (don't deploy NIC resources directly)
- Private DNS zone names are service-specific:
  - Key Vault: `privatelink.vaultcore.azure.net`
  - App Configuration: `privatelink.azconfig.io`
  - Storage (Blob): `privatelink.blob.core.windows.net`

---

## 🎯 Option 2: Dapr Albums Microservices Application

Deploys the complete Dapr Albums demo application to Azure Container Apps.

### What this deploys
- **Container Apps Environment** - Dapr-enabled environment for microservices
- **Log Analytics Workspace** - For logging and monitoring
- **Application Insights** - For telemetry and distributed tracing
- **Storage Account** - Used as Dapr state store (blob storage)
- **Dapr State Store Component** - Configured to use Azure Blob Storage
- **Album API Container App** - .NET 7 Web API backend
- **Album Viewer Container App** - Node.js/Express frontend

### Prerequisites
- Azure CLI (`az`) installed and logged in
- Container images built and pushed to a container registry (ACR or Docker Hub)
- Container registry credentials
- Permissions to create Container Apps and related resources

### Build and Push Container Images

Before deploying, you need to build and push your container images:

```bash
# Login to your Azure Container Registry
az acr login --name <your-registry-name>

# Build and push the album API
cd albums-api
az acr build --registry <your-registry-name> --image album-api:latest --file ../dockerfile .

# Build and push the album viewer
cd ../album-viewer
docker build -t <your-registry-name>.azurecr.io/album-viewer:latest .
docker push <your-registry-name>.azurecr.io/album-viewer:latest
```

### Deploy

1. Copy and customize the parameters:
   ```bash
   cp templates/albums-app.parameters.example.json templates/albums-app.parameters.json
   ```

2. Edit `templates/albums-app.parameters.json` with your values:
   - Resource names (environment, workspace, storage account, etc.)
   - Container registry details (name, username, password)
   - Container image paths
   - Tags for resource organization

3. Run the deployment:

   **PowerShell:**
   ```powershell
   ./deploy-albums.ps1 -SubscriptionId <your-subscription-id> -ResourceGroupName <your-rg-name> -Location <azure-region> -ParametersFile templates/albums-app.parameters.json
   ```

   **Bash:**
   ```bash
   ./deploy-albums.sh <your-subscription-id> <your-rg-name> <azure-region> templates/albums-app.parameters.json
   ```

### Post-Deployment

After deployment completes, you'll see output like:
```
Album Viewer URL: https://album-viewer.xxxxx.eastus.azurecontainerapps.io
Album API FQDN: album-api.xxxxx.eastus.azurecontainerapps.io
```

Visit the Album Viewer URL in your browser to see the application!

### Customization Options

All resource names are customizable through parameters:
- `environmentName` - Container Apps Environment name
- `logAnalyticsWorkspaceName` - Log Analytics workspace name
- `appInsightsName` - Application Insights name
- `storageAccountName` - Storage account name (hyphens will be removed automatically)
- `albumApiName` - Album API container app name
- `albumViewerName` - Album viewer container app name
- `tags` - Custom tags for all resources

### Architecture

The deployment creates a microservices architecture using Dapr:
- **Album Viewer** calls **Album API** via Dapr service-to-service invocation
- **Album API** uses Dapr state management backed by Azure Blob Storage
- Both apps run in the same Container Apps Environment with Dapr enabled
- Application Insights provides distributed tracing across both services

---

## 🔍 Validating Your Deployment

### Check Container Apps Status
```bash
# List all container apps in the resource group
az containerapp list --resource-group <your-rg-name> --output table

# Get specific container app details
az containerapp show --name album-viewer --resource-group <your-rg-name>
```

### View Logs
```bash
# Stream logs from album viewer
az containerapp logs show --name album-viewer --resource-group <your-rg-name> --follow

# Stream logs from album API
az containerapp logs show --name album-api --resource-group <your-rg-name> --follow
```

### Test the Application
```bash
# Test the API directly
curl https://<album-api-fqdn>/albums

# Open the viewer in a browser
open https://<album-viewer-fqdn>
```

---

## 🧹 Cleanup

To remove all resources when you're done:

```bash
az group delete --name <your-rg-name> --yes --no-wait
```

---

## 📚 Additional Resources

- [Azure Container Apps Documentation](https://learn.microsoft.com/azure/container-apps/)
- [Dapr Documentation](https://docs.dapr.io/)
- [Azure Private Link Documentation](https://learn.microsoft.com/azure/private-link/)
- [Build and Run Guide](../build-and-run.md) - Local development with Dapr
