param apiManagementName string
param location string = resourceGroup().location
param publisherEmail string = 'noreply@microsoft.com'
param publisherName string = 'Contoso'
param apimSku string = 'Basicv2'

resource apimService 'Microsoft.ApiManagement/service@2024-06-01-preview' = {
  name: apiManagementName
  location: location
  sku: {
    name: apimSku
    capacity: 1
  }
  properties: {
    publisherEmail: publisherEmail
    publisherName: publisherName
  }
}

output id string = apimService.id
output name string = apimService.name
output gatewayUrl string = apimService.properties.gatewayUrl
