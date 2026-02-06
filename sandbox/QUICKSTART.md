# Sandbox Deployment Quick Start

This guide helps you quickly deploy your private sandbox environment.

## Choose Your Deployment

### Option 1: Just the Albums App (Recommended for Quick Start)

Deploy the Dapr Albums microservices application to Azure Container Apps.

#### Prerequisites
- Azure subscription
- Azure CLI installed
- Container images built and pushed to a registry

#### Quick Steps

1. **Copy the parameters file:**
   ```bash
   cp sandbox/templates/albums-app.parameters.example.json sandbox/templates/albums-app.parameters.json
   ```

2. **Edit the parameters** in `sandbox/templates/albums-app.parameters.json`:
   - Change all names to match your preferences
   - Update container registry details
   - Set your container image paths

3. **Deploy:**
   
   PowerShell:
   ```powershell
   ./sandbox/deploy-albums.ps1 `
     -SubscriptionId "your-subscription-id" `
     -ResourceGroupName "my-albums-sandbox" `
     -Location "eastus" `
     -ParametersFile "sandbox/templates/albums-app.parameters.json"
   ```
   
   Bash:
   ```bash
   ./sandbox/deploy-albums.sh \
     "your-subscription-id" \
     "my-albums-sandbox" \
     "eastus" \
     "sandbox/templates/albums-app.parameters.json"
   ```

4. **Visit your app** at the URL shown in the deployment output!

---

### Option 2: Private Link Infrastructure

Deploy VNet, Private Endpoints, and PaaS services for private connectivity testing.

#### Quick Steps

1. **Copy the parameters file:**
   ```bash
   cp sandbox/templates/rg.parameters.example.json sandbox/templates/rg.parameters.json
   ```

2. **Edit the parameters** in `sandbox/templates/rg.parameters.json`:
   - Customize all resource names
   - Adjust VNet address spaces if needed
   - Modify the privateEndpoints array for your services

3. **Deploy:**
   ```powershell
   ./sandbox/deploy.ps1 `
     -SubscriptionId "your-subscription-id" `
     -ResourceGroupName "my-privatelink-sandbox" `
     -Location "eastus" `
     -ParametersFile "sandbox/templates/rg.parameters.json"
   ```

---

## Building Container Images

Before deploying the Albums app, build and push your images:

```bash
# Login to Azure Container Registry
az acr login --name <your-registry-name>

# Build album API (from repo root)
cd albums-api
az acr build --registry <your-registry-name> \
  --image album-api:latest \
  --file ../dockerfile .

# Build album viewer
cd ../album-viewer
docker build -t <your-registry-name>.azurecr.io/album-viewer:latest .
docker push <your-registry-name>.azurecr.io/album-viewer:latest
```

---

## Customization Examples

### Example 1: Different Azure Region
Change the `location` parameter in your parameters file or pass it on the command line:
```powershell
-Location "westus2"
```

### Example 2: Custom Resource Names
In your parameters JSON file:
```json
{
  "environmentName": { "value": "johndoe-albums-env" },
  "albumApiName": { "value": "johndoe-album-api" },
  "albumViewerName": { "value": "johndoe-album-viewer" },
  "storageAccountName": { "value": "johndoealbumstore" }
}
```

### Example 3: Custom Tags
```json
{
  "tags": {
    "value": {
      "owner": "john.doe@company.com",
      "project": "albums-demo",
      "costcenter": "engineering",
      "environment": "development"
    }
  }
}
```

---

## Troubleshooting

### Container Images Not Found
Make sure you've built and pushed your images, and that the image paths in your parameters file match exactly:
```json
{
  "albumApiImage": { 
    "value": "myregistry.azurecr.io/album-api:latest" 
  }
}
```

### Authentication Errors
Ensure your container registry credentials are correct in the parameters file.

### Resource Name Conflicts
If you get naming conflicts, choose different names in your parameters file. Azure resource names must be globally unique for some services.

### View Deployment Logs
```bash
az deployment group show \
  --resource-group <your-rg-name> \
  --name <deployment-name>
```

---

## Next Steps

After deployment:
1. Visit the Album Viewer URL to see your app
2. Check Application Insights for telemetry
3. View logs in Log Analytics
4. Test Dapr service invocation between components

For detailed information, see:
- `sandbox/README.md` - Complete deployment documentation
- `sandbox.md` - Environment architecture analysis
- `build-and-run.md` - Local development guide
