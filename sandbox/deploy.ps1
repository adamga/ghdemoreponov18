param(
  [Parameter(Mandatory=$true)][string]$SubscriptionId,
  [Parameter(Mandatory=$true)][string]$ResourceGroupName,
  [Parameter(Mandatory=$true)][string]$Location,
  [Parameter(Mandatory=$true)][string]$ParametersFile
)

$ErrorActionPreference = 'Stop'

Write-Host "Setting subscription..." -ForegroundColor Cyan
az account set --subscription $SubscriptionId | Out-Null

Write-Host "Creating resource group (if needed)..." -ForegroundColor Cyan
az group create --name $ResourceGroupName --location $Location | Out-Null

Write-Host "Deploying ARM template to resource group..." -ForegroundColor Cyan
az deployment group create `
  --resource-group $ResourceGroupName `
  --template-file "sandbox/templates/rg.main.json" `
  --parameters "@$ParametersFile" `
  --parameters location=$Location | Out-Null

Write-Host "Done." -ForegroundColor Green
