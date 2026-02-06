# Sandbox (private) Azure environment — ARM templates

This folder contains **Azure ARM templates** intended to recreate a *private, Private Link–oriented* sandbox similar to the topology screenshot.

## What this deploys (template-driven)

The main resource-group template is data-driven and can deploy:

- Virtual Network + subnets (including a subnet suitable for Private Endpoints)
- Private DNS zones + VNet links
- One or more Key Vaults
- One or more App Configuration stores
- One or more Storage Accounts
- Optional Log Analytics + Application Insights
- An arbitrary set of Private Endpoints wired to Private DNS zone groups

Everything is parameterized so you can **choose every name**.

## Files

- `templates/rg.main.json`: main resource-group–scope ARM template
- `templates/rg.parameters.example.json`: example parameters file (edit this for your deployment)
- `deploy.ps1`: creates a new resource group then runs `az deployment group create`

## Prerequisites

- Azure CLI (`az`) installed and logged in
- You have permission to create:
  - Resource group
  - Networking resources (VNet, Private Endpoints, Private DNS)
  - Key Vault / App Configuration / Storage

## Deploy

1. Copy the example parameters:

   - Duplicate `templates/rg.parameters.example.json` to `templates/rg.parameters.json`
   - Edit values (names, address space, and the `privateEndpoints` list)

2. Run:

   - `./deploy.ps1 -SubscriptionId <subId> -ResourceGroupName <rgName> -Location <azureRegion> -ParametersFile templates/rg.parameters.json`

## Notes / gotchas

- Private Endpoints will create NICs automatically. You *do not* deploy NIC resources directly.
- Private DNS zone names are service-specific. Common ones:
  - Key Vault: `privatelink.vaultcore.azure.net`
  - App Configuration: `privatelink.azconfig.io`
  - Storage (Blob): `privatelink.blob.core.windows.net`
- The screenshot includes many resources; this template is meant to be flexible. Add/adjust entries in `privateEndpoints` and the resource arrays to match your exact sandbox.
