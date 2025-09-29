targetScope = 'subscription'

param environmentName string
param location string

var abbreviations = loadJsonContent('abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))

var appServicePlanName = '${abbreviations.webSitesAppServicePlan}-${resourceToken}'
var appServiceWebAppName = '${abbreviations.webSitesAppService}-${resourceToken}'

var apiManagementName = '${abbreviations.apiManagementService}-${resourceToken}'

var apiUserAssignedIdentityName = '${abbreviations.managedIdentityUserAssignedIdentities}api-${resourceToken}'
var mcpEntraApplicationUniqueName = 'mcp-api-${resourceToken}'
var mcpEntraApplicationDisplayName = 'MCP-API-${resourceToken}'

var tags = {
  'azd-env-name': environmentName
}

// resource group
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-${environmentName}'
  location: location
  tags: tags
}

// User assigned managed identity to be used by the web app to reach dependencies
module apiUserAssignedIdentity 'br/public:avm/res/managed-identity/user-assigned-identity:0.4.1' = {
  name: 'apiUserAssignedIdentity'
  scope: resourceGroup
  params: {
    location: location
    tags: tags
    name: apiUserAssignedIdentityName
  }
}

// web app & app service plan
module web './app/webapp.bicep' = {
  name: 'web'
  scope: resourceGroup
  params: {
    appName: appServiceWebAppName
    planName: appServicePlanName
    location: location
    identityId: apiUserAssignedIdentity.outputs.resourceId
    tags: tags
    serviceTag: 'todo-api'
  }
}

// MCP Entra App 
module mcpEntraApp './entraid/mcp-entra-app.bicep' = {
  name: 'mcpEntraAppDeployment'
  scope: resourceGroup
  params: {
    mcpAppUniqueName: mcpEntraApplicationUniqueName
    mcpAppDisplayName: mcpEntraApplicationDisplayName
    userAssignedIdentityPrincipalId: apiUserAssignedIdentity.outputs.principalId 
    webAppName: appServiceWebAppName
  }
}

// apim 
module apimService './apim/apim.bicep' = {
  name: apiManagementName
  scope: resourceGroup
  params:{
    apiManagementName: apiManagementName
  }
}

// api 
module api './apim/api.bicep' = {
  name: 'api'
  scope: resourceGroup
  params:{
    apiManagementName: apiManagementName
    appName: appServiceWebAppName
    mcpAppId: mcpEntraApp.outputs.mcpAppId
    mcpAppTenantId: mcpEntraApp.outputs.mcpAppTenantId
  }
}
