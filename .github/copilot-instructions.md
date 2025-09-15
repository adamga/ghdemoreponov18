# GitHub Copilot Instructions

This is a **GitHub Copilot demo repository** based on Azure Container Apps Dapr Albums Sample, designed to showcase AI coding capabilities across multiple tech stacks and security scenarios.

## Architecture Overview

**Microservices Pattern**: Two main services communicate via Dapr:
- `albums-api/` - .NET 7 Web API (port 5000/80) using minimal API pattern
- `album-viewer/` - Node.js/Express frontend (port 3000) with Pug templates

**Key Integration**: Album viewer calls API via Dapr service invocation:
```js
// Pattern used throughout album-viewer/routes/index.js
const url = `http://127.0.0.1:${DaprHttpPort}/v1.0/invoke/${AlbumService}/method/albums`;
```

**State Management**: Local Redis (dev) → Azure Storage (production) via Dapr state store components in `dapr-components/local/`

## Development Workflows

### Local Development
```bash
# Terminal 1 - API (from repo root)
cd albums-api && dapr run --app-id album-api --app-port 5000 --dapr-http-port 3500 --components-path ../dapr-components/local -- dotnet run

# Terminal 2 - Frontend
cd album-viewer && dapr run --app-id album-viewer --app-port 3000 --dapr-http-port 3501 --components-path ../dapr-components/local -- npm run start
```

**Critical**: Always use Dapr CLI for local runs. Direct `dotnet run`/`npm start` breaks service communication.

### Infrastructure as Code
- `iac/bicep/` - Azure Container Apps deployment templates
- `iac/terraform/` - Alternative Terraform configurations
- Both deploy identical architecture with different tooling

## Project-Specific Patterns

### Demo Categories by Directory
- `albums-api/Controllers/UnsecuredController.cs` - **Security vulnerability examples** (SQL injection, path traversal, info disclosure)
- `legacy/albums.cbl` - **COBOL translation demos** for cross-language scenarios
- `adventureforms/` - **Additional full-stack demos** with different security patterns
- `iac/` - **Infrastructure as Code demonstrations**

### Data Models
```cs
// albums-api/Models/Album.cs - Record pattern with static seed data
public record Album(int Id, string Title, string Artist, double Price, string Image_url)
```

### Environment Configuration
Both services use these key environment variables:
- `DAPR_HTTP_PORT` - Dapr sidecar communication
- `ALBUM_API_NAME` / `ALBUM_SERVICE` - Service discovery names
- `COLLECTION_ID` - State store collection identifier

### Security Demo Patterns
When working with `UnsecuredController.cs`:
1. **Never fix the vulnerabilities** - they're intentional demo material
2. **Use for "secure refactoring" examples** - show parameterized queries, input validation, error handling
3. **Reference `pccdss.md`** - PCI security standards context for enterprise demos

## Common Demo Scenarios

### Code Generation
- Add validation functions to `album-viewer/utils/`
- Generate API endpoints in `albums-api/Controllers/`
- Create Bicep/Terraform resources in `iac/`

### Code Translation
- Translate between `albums.cbl` (COBOL) ↔ modern languages
- Convert validation logic across TypeScript/C#/Python

### Security Analysis
- Analyze `UnsecuredController.cs` for vulnerabilities
- Generate secure alternatives with proper parameterization
- Create security test cases

## Integration Points

**Dapr Dependencies**: Service communication relies on:
- State store component (`statestore.yaml`)
- App-id based routing between services
- HTTP port conventions (3500/3501 for Dapr sidecars)

**Container Strategy**: 
- Development: Redis + local Dapr components
- Production: Azure Storage + Container Apps managed Dapr