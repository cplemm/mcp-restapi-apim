targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the environment that can be used as part of naming resource convention')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

var abbreviations = loadJsonContent('abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))

var appServicePlanName = '${abbreviations.webSitesAppServicePlan}-${resourceToken}'
var appServiceWebAppName = '${abbreviations.webSitesAppService}-${resourceToken}'

var tags = {
  'azd-env-name': environmentName
}

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-${environmentName}'
  location: location
  tags: tags
}

module web 'app/api.bicep' = {
  name: 'web'
  scope: resourceGroup
  params: {
    appName: appServiceWebAppName
    planName: appServicePlanName
    location: location
    tags: tags
    serviceTag: 'todo-api'
  }
}
