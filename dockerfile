# Use the official .NET image as a parent image
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80

# Use the SDK image to build the app
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["albums-api/albums-api.csproj", "albums-api/"]
RUN dotnet restore "albums-api/albums-api.csproj"
COPY . .
WORKDIR "/src/albums-api"
RUN dotnet build "albums-api.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "albums-api.csproj" -c Release -o /app/publish

# Use the base image to run the app
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "albums-api.dll"]