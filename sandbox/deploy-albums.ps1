param(
  [Parameter(Mandatory=$true)][string]$SubscriptionId,
  [Parameter(Mandatory=$true)][string]$ResourceGroupName,
  [Parameter(Mandatory=$true)][string]$Location,
  [Parameter(Mandatory=$true)][string]$ParametersFile
)

$ErrorActionPreference = 'Stop'

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "Dapr Albums Deployment to Azure Container Apps" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

Write-Host "Configuration:" -ForegroundColor Yellow
Write-Host "  Subscription ID:    $SubscriptionId" -ForegroundColor Gray
Write-Host "  Resource Group:     $ResourceGroupName" -ForegroundColor Gray
Write-Host "  Location:           $Location" -ForegroundColor Gray
Write-Host "  Parameters File:    $ParametersFile" -ForegroundColor Gray
Write-Host ""

Write-Host "Setting Azure subscription..." -ForegroundColor Cyan
az account set --subscription $SubscriptionId
if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to set subscription" -ForegroundColor Red
    exit 1
}

Write-Host "Creating resource group (if it doesn't exist)..." -ForegroundColor Cyan
az group create --name $ResourceGroupName --location $Location --output none
if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to create resource group" -ForegroundColor Red
    exit 1
}

Write-Host "Deploying ARM template..." -ForegroundColor Cyan
$deploymentName = "albums-deployment-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

$deployment = az deployment group create `
  --resource-group $ResourceGroupName `
  --name $deploymentName `
  --template-file "sandbox/templates/albums-app.json" `
  --parameters "@$ParametersFile" `
  --parameters location=$Location `
  --output json | ConvertFrom-Json

if ($LASTEXITCODE -ne 0) {
    Write-Host "Deployment failed!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
Write-Host "Deployment Completed Successfully!" -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
Write-Host ""
Write-Host "Application URLs:" -ForegroundColor Yellow
Write-Host "  Album Viewer:  $($deployment.properties.outputs.albumViewerUrl.value)" -ForegroundColor White
Write-Host "  Album API:     https://$($deployment.properties.outputs.albumApiFqdn.value)" -ForegroundColor White
Write-Host ""
Write-Host "Resource Group:  $ResourceGroupName" -ForegroundColor Gray
Write-Host "Environment:     $($deployment.properties.outputs.environmentId.value)" -ForegroundColor Gray
Write-Host ""
Write-Host "Visit the Album Viewer URL in your browser to see the application!" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
