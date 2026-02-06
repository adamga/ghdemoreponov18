#!/bin/bash

# Dapr Albums Deployment Script for Azure Container Apps
# This script deploys the Dapr Albums microservices application to a new resource group

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${CYAN}$1${NC}"
}

print_success() {
    echo -e "${GREEN}$1${NC}"
}

print_error() {
    echo -e "${RED}$1${NC}"
}

# Check if required parameters are provided
if [ $# -lt 4 ]; then
    print_error "Usage: $0 <subscription-id> <resource-group-name> <location> <parameters-file>"
    print_info "Example: $0 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx' 'my-albums-rg' 'eastus' 'templates/albums-app.parameters.json'"
    exit 1
fi

SUBSCRIPTION_ID=$1
RESOURCE_GROUP_NAME=$2
LOCATION=$3
PARAMETERS_FILE=$4

print_info "Starting deployment..."
print_info "Subscription: $SUBSCRIPTION_ID"
print_info "Resource Group: $RESOURCE_GROUP_NAME"
print_info "Location: $LOCATION"
print_info "Parameters File: $PARAMETERS_FILE"

# Set the subscription
print_info "Setting Azure subscription..."
az account set --subscription "$SUBSCRIPTION_ID"

# Create resource group
print_info "Creating resource group (if it doesn't exist)..."
az group create --name "$RESOURCE_GROUP_NAME" --location "$LOCATION" --output none

# Deploy the ARM template
print_info "Deploying ARM template..."
DEPLOYMENT_NAME="albums-deployment-$(date +%Y%m%d-%H%M%S)"

az deployment group create \
  --resource-group "$RESOURCE_GROUP_NAME" \
  --name "$DEPLOYMENT_NAME" \
  --template-file "sandbox/templates/albums-app.json" \
  --parameters "@$PARAMETERS_FILE" \
  --parameters location="$LOCATION" \
  --output json > deployment_output.json

# Extract outputs
if [ $? -eq 0 ]; then
    print_success "Deployment completed successfully!"
    print_info "Extracting deployment outputs..."
    
    ALBUM_VIEWER_URL=$(jq -r '.properties.outputs.albumViewerUrl.value' deployment_output.json)
    ALBUM_API_FQDN=$(jq -r '.properties.outputs.albumApiFqdn.value' deployment_output.json)
    
    print_success "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print_success "Deployment Summary"
    print_success "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print_success "Album Viewer URL: $ALBUM_VIEWER_URL"
    print_success "Album API FQDN: $ALBUM_API_FQDN"
    print_success "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print_info "Visit the Album Viewer URL in your browser to see the application!"
    
    # Clean up temporary file
    rm deployment_output.json
else
    print_error "Deployment failed. Check the error messages above."
    exit 1
fi
