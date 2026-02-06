# Sandbox environment notes (from topology screenshot)

> Source: the pasted Azure “resource topology/dependency” diagram screenshot.
>
> Important: the screenshot resolution makes some resource *names* hard to read reliably. This document describes what is clearly visible (resource *types*, relationships, and patterns), and calls out anything that is inferred.

## 1) What this environment appears to be

This looks like an Azure sandbox built with a strong **private networking / Private Link** posture:

- Multiple platform services (notably **Key Vault**, and likely other PaaS services) are exposed to the workload through **Private Endpoints**.
- Each Private Endpoint is paired with a **Network Interface (NIC)** and typically wired into **Private DNS** (a DNS icon is visible), which is the standard pattern for Private Link name resolution.
- The diagram is laid out in the “dependencies” style: resources across the top, with dependency lines down into Private Endpoints / NICs and across to the workload.

In other words: the workload seems designed so app components can reach dependencies *privately* within a VNet (rather than over public endpoints).

## 2) Major building blocks visible in the diagram

### 2.1 Monitoring / health signals

At the far left, the diagram includes an item labeled **“Failure Anomalies”** (the wording is visible), which strongly suggests **Application Insights smart detection/alerting** is enabled for at least one application component.

What that implies operationally:

- There is (or was) an Application Insights resource collecting request/exception telemetry.
- Azure Monitor is generating anomaly detection signals/alerts for abnormal failure rates.

### 2.2 Network integration + Private Link

The most repeated pattern in the diagram is:

- A **Private Endpoint** resource (blue network/connector icon)
- Connected to a corresponding **NIC** (green NIC icon)
- With lines that also touch DNS-related resources (a DNS globe icon is visible)

This indicates:

- The platform services (Key Vault and potentially others) are being reached via **Private Link** from inside a VNet.
- DNS is configured so standard service hostnames resolve to private IPs when queried from inside the VNet (typical: `privatelink.*` zones).

**Operational consequences:**

- If DNS/private zones are misconfigured, the app will fail with connection/timeouts even though the service exists.
- Private Endpoints are sensitive to subnet placement and NSG/route rules.
- Diagnosing outages often requires checking: PE connection state, NIC IP, private DNS zone linkage, and the app’s outbound network path.

### 2.3 Secrets / keys (multiple Key Vaults)

Across the top row, there are multiple **Key Vault** icons (yellow key), with names that appear to follow a pattern like `keyvault_<suffix>`.

What this implies:

- Secrets and/or certificates are centralized in Key Vault.
- Multiple vaults could indicate:
  - separation by application component
  - separation by environment (dev/test/prod naming)
  - separation by tenant/subscription boundary, or
  - separation by purpose (app secrets vs. platform/shared secrets)

Given the presence of Private Endpoints, these vaults are likely configured with **private endpoint access** (and possibly restricted public access).

### 2.4 App / compute components (inferred)

The screenshot includes a set of resources that appear to be **application/compute** components (the exact compute type is hard to read at this resolution). The dependency lines show that these compute components depend on the private-linked resources (Key Vault and others).

Most likely candidates (based on common topology diagrams) are:

- App Service (Web Apps) and/or Function Apps, or
- Container Apps / Kubernetes workloads

**What is clear** is the *relationship*: the compute tier is consuming configuration/secrets and other backing services through Private Link.

### 2.5 DNS

A DNS-labeled icon is visible near the right side of the diagram.

This suggests there is DNS infrastructure involved, typically one or more of:

- Azure **Private DNS zones** for Private Link endpoints (common)
- Azure DNS zones for public DNS (possible)

In Private Link environments, Private DNS zones are a key dependency:

- `privatelink.vaultcore.azure.net` (Key Vault)
- `privatelink.blob.core.windows.net` (Storage)
- `privatelink.database.windows.net` (SQL)
- etc.

The diagram’s PE→NIC→DNS relationships match this pattern.

## 3) How traffic/data likely flows (conceptual)

Based on the dependency arrows/lines:

1. **Compute/app components** start and need secrets/config.
2. They resolve service names via **DNS** (private zones) to private IPs.
3. They connect to platform services through **Private Endpoints** (private IP addresses on NICs).
4. Key Vault (and other PaaS resources) only see traffic coming through the Private Link path.

This is the standard “no public egress to dependencies” design.

## 4) Naming conventions visible

Even though the small text is difficult to read, the diagram clearly uses consistent suffixes/patterns typical of Private Link deployments:

- `*-pep` / `*-pe` (Private Endpoint)
- `*-nic` (NIC backing a Private Endpoint)
- resource names prefixed with the service type (e.g., `keyvault_*`)

If you share the original image (or a higher-resolution export), I can update this document with an exact inventory of each resource name.

## 5) What to check when working with this environment

When debugging issues in this kind of deployment, the highest-signal checks are:

- **Private Endpoint connection state**: Approved/Rejected/Disconnected.
- **NIC private IP**: is it allocated and in the expected subnet.
- **Private DNS**: zone exists, `A` records exist for the PE, and the zone is linked to the correct VNet(s).
- **Service-side networking**: public network access disabled/enabled as intended; firewall rules.
- **App outbound path**: VNet integration, subnet NSGs/UDRs, and any forced tunneling/NAT.

---

# Appendix A — Concrete IaC in this repo (Dapr Albums Container Apps)

The repository you’re in also contains a *separate, very concrete* deployment definition for the “Dapr Albums” sample under:

- `iac/bicep/main.bicep`
- `iac/bicep/modules/container-app.bicep`

That IaC deploys a simpler environment than what your screenshot appears to show, but it’s useful as a baseline reference for how this repo expects deployments to look.

## A.1 Resources created by `iac/bicep/main.bicep`

- **Log Analytics Workspace** (`Microsoft.OperationalInsights/workspaces`)
  - Retention: 30 days
- **Application Insights** (`Microsoft.Insights/components`)
  - Linked to the Log Analytics workspace
- **Storage Account** (`Microsoft.Storage/storageAccounts`)
  - With a blob container named `albums`
- **Container Apps Environment** (`Microsoft.App/managedEnvironments`)
  - Configured to send logs to Log Analytics
  - Configured with `daprAIInstrumentationKey` from App Insights
- **Dapr state store component** (via module `modules/dapr-statestore.bicep`)
  - Uses the Storage Account + `albums` container as backing store
- **Two Azure Container Apps** (`Microsoft.App/containerApps` via module `modules/container-app.bicep`)
  - `album-api` (ingress external, target port 80, Dapr enabled)
  - `album-viewer` (ingress external, target port 3000, Dapr enabled)

## A.2 Runtime behavior implied by the IaC

- Both container apps:
  - Pull images from a container registry (credentials injected as secrets)
  - Are exposed externally (public ingress = `external: true`)
  - Have **Dapr enabled**, with `appId` equal to the container app name
- Logs/metrics:
  - Flow into Log Analytics
  - App Insights instrumentation key is wired for Dapr telemetry

If your screenshot is from a different/supplemental sandbox (more Private Link-heavy), you may have *two* separate “environments” to understand: the repo’s Container Apps sample and the broader sandbox depicted in the screenshot.

---

## Appendix B: Your Private Sandbox Deployments

Based on the analysis above, **two deployment options** have been created in the `sandbox/` folder for your private use:

### B.1 Sandbox Option 1: Private Link Infrastructure

**Template:** `sandbox/templates/rg.main.json`

This template recreates a Private Link-oriented environment similar to what's depicted in the topology screenshot:
- Virtual Network with subnets for workloads and private endpoints
- Private DNS zones for Azure services
- Key Vaults, App Configuration stores, and Storage Accounts
- Private Endpoints connecting services to your VNet
- Optional monitoring (Log Analytics + Application Insights)

**Use this when:** You need a secure, private networking sandbox for testing Private Link connectivity patterns, or when you need to isolate Azure PaaS services from the public internet.

**Deployment:**
```powershell
./sandbox/deploy.ps1 -SubscriptionId <id> -ResourceGroupName <name> -Location <region> -ParametersFile sandbox/templates/rg.parameters.json
```

### B.2 Sandbox Option 2: Dapr Albums Microservices

**Template:** `sandbox/templates/albums-app.json`

This template deploys the complete Dapr Albums demonstration application from this repository to Azure Container Apps:
- Container Apps Environment with Dapr enabled
- Log Analytics Workspace and Application Insights for monitoring
- Storage Account configured as a Dapr state store
- Album API container app (.NET 7 backend)
- Album Viewer container app (Node.js frontend)
- Dapr components for service-to-service communication and state management

**Use this when:** You want a complete, working copy of the albums microservices demo in your own subscription with full control over naming and configuration.

**Deployment:**
```powershell
./sandbox/deploy-albums.ps1 -SubscriptionId <id> -ResourceGroupName <name> -Location <region> -ParametersFile sandbox/templates/albums-app.parameters.json
```

Or using bash:
```bash
./sandbox/deploy-albums.sh <id> <name> <region> sandbox/templates/albums-app.parameters.json
```

### B.3 Customizing Your Deployment

**All resource names are fully customizable** via parameters files:
- Copy the `.example.json` parameter files to create your own
- Edit all names to match your naming conventions
- Set tags for cost tracking and organization
- Adjust SKUs and configurations as needed

See `sandbox/README.md` for detailed deployment instructions, prerequisites, and troubleshooting tips.

### B.4 Key Differences Between Options

| Aspect | Private Link Infrastructure | Dapr Albums Application |
|--------|---------------------------|------------------------|
| **Focus** | Networking and private connectivity | Microservices application deployment |
| **Resources** | VNet, Private Endpoints, DNS, PaaS services | Container Apps, Dapr components, monitoring |
| **Complexity** | More infrastructure pieces | Application-focused |
| **Use Case** | Testing Private Link patterns | Running the albums demo app |
| **Can Combine?** | Yes - deploy albums app into a VNet from Option 1 (requires template modifications) |

Both options give you **complete control** over resource naming through parameters, meeting the requirement for customizable naming during deployment.
