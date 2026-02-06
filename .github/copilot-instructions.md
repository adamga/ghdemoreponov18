# Copilot instructions (ghdemoreponov18)

This repo is a **GitHub Copilot demo playground** with multiple sample apps. The primary “big picture” is the **Dapr Albums** microservices sample (Azure Container Apps style) plus a few unrelated demo projects.

## Primary sample: Dapr Albums (microservices)
- Backend API: `albums-api/` (in `gh-copilot-demo.sln`) is an ASP.NET Core Web API targeting **.NET 7** (`albums-api/albums-api.csproj`).
	- Main endpoint is `GET /albums` (`albums-api/Controllers/AlbumController.cs`) returning the in-memory catalog in `albums-api/Models/Album.cs`.
- Frontend: `album-viewer/` is a Node/Express app (Pug views) that calls the API via **Dapr service invocation** (`album-viewer/routes/index.js`).
	- Keep these env var names when changing wiring: `DAPR_HTTP_PORT`, `ALBUM_API_NAME`, `BACKGROUND_COLOR`.

## Local dev workflow (Albums)
Canonical steps are in `build-and-run.md`.
- Install deps:
	- `cd album-viewer && npm install`
	- `cd albums-api && dotnet restore`
- Run via Dapr (two terminals; components are in `dapr-components/local`):
	- API: `cd albums-api && dapr run --app-id album-api --app-port 5000 --dapr-http-port 3500 --components-path ../dapr-components/local -- dotnet run`
	- Viewer: `cd album-viewer && dapr run --app-id album-viewer --app-port 3000 --dapr-http-port 3501 --components-path ../dapr-components/local -- npm start`
- The local state store component is Redis (`dapr-components/local/statestore.yaml` -> `localhost:6379`, scoped to `album-api`).

## Docker / IaC (Albums)
- Viewer container build: `album-viewer/Dockerfile` (exposes 3000).
- API container build: repo-root `dockerfile` builds `albums-api` (note: it currently uses .NET 6 images; align with `.csproj` TargetFramework if you touch it).
- Azure Container Apps infra is in `iac/bicep/` and `iac/terraform/` (deploys `album-api` on port 80 and `album-viewer` on port 3000; sets up a Dapr state store).

## Other demo projects (not coupled to Albums)
- `adventureforms/FormsApp` (WinForms) + `adventureforms/adventureview` (Node) use the AdventureWorks2014 sample DB; SQL scripts live under `ADV_DB/`.
- `rotatingcube/my-direct3d12-app` is a standalone C++/CMake Direct3D12 sample.

## Repo-specific cautions
- `.vscode/settings.json` contains a sample SQLTools connection (including credentials). Avoid echoing secrets into logs/issues/PRs; prefer env vars or local user config.
- There are no `.github/workflows/` pipelines in this repo; don’t assume CI conventions.
