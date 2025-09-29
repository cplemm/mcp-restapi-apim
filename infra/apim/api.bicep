param apiManagementName string
param appName string

param mcpAppTenantId string
param mcpAppId string

resource apimService 'Microsoft.ApiManagement/service@2024-06-01-preview' existing = {
  name: apiManagementName
}

var openapi = loadTextContent('todo-api.json') 

// Backend API definition in APIM
resource backendApi 'Microsoft.ApiManagement/service/apis@2023-05-01-preview' = {
  parent: apimService
  name: 'todo'
  properties: {
    displayName: 'Todos'
    description: 'A simple Todo API'
    subscriptionRequired: false
    path: '/todos'
    protocols: [
      'https'
    ]
    serviceUrl: 'https://${appName}.azurewebsites.net/'
    format: 'openapi+json'          
    value: openapi
  }
}

// Backend API definition in APIM
// resource backendApi 'Microsoft.ApiManagement/service/apis@2023-05-01-preview' = {
//   parent: apimService
//   name: 'todo'
//   properties: {
//     displayName: 'Todos'
//     description: 'A simple Todo API'
//     subscriptionRequired: false
//     path: '/todos'
//     protocols: [
//       'https'
//     ]
//     serviceUrl: 'https://${appName}.azurewebsites.net/'
//   }
// }

resource getTodosOperation 'Microsoft.ApiManagement/service/apis/operations@2023-05-01-preview' existing = {
  name: '${apimService.name}/${backendApi.name}/apiTodosGet'
}

resource createTodoOperation 'Microsoft.ApiManagement/service/apis/operations@2023-05-01-preview' existing = {
  name: '${apimService.name}/${backendApi.name}/apiTodosPost'
}

resource deleteTodoOperation 'Microsoft.ApiManagement/service/apis/operations@2023-05-01-preview' existing = {
  name: '${apimService.name}/${backendApi.name}/apiTodosIdDelete'
}

resource getTodoOperation 'Microsoft.ApiManagement/service/apis/operations@2023-05-01-preview' existing = {
  name: '${apimService.name}/${backendApi.name}/apiTodosIdGet'
}

resource updateTodoOperation 'Microsoft.ApiManagement/service/apis/operations@2023-05-01-preview' existing = {
  name: '${apimService.name}/${backendApi.name}/apiTodosIdPut'
}

// MCP Server definition in APIM
resource mcpServerApi 'Microsoft.ApiManagement/service/apis@2024-06-01-preview' = {
  parent: apimService
  dependsOn: [
    backendApi
  ]
  name: 'todo-mcp-server'
  properties: {
    apiType: 'mcp'
    type: 'mcp'
    displayName: 'Todo MCP Server'
    description: 'MCP Server for Todo API backend'
    subscriptionRequired: false
    path: 'todos-mcp'
    protocols: [
      'https'
    ]
    mcpTools: [
      {
          name: 'apiTodosGet'
          operationId: getTodosOperation.id
          description: getTodosOperation.properties.description
      }
      {
          name: 'apiTodosPost'
          operationId: createTodoOperation.id
          description: createTodoOperation.properties.description
      }
      {
          name: 'apiTodosIdDelete'
          operationId: deleteTodoOperation.id
          description: deleteTodoOperation.properties.description
      }
      {
          name: 'apiTodosIdGet'
          operationId: getTodoOperation.id
          description: getTodoOperation.properties.description
      }
      {
          name: 'apiTodosIdPut'
          operationId: updateTodoOperation.id
          description: updateTodoOperation.properties.description
      }
    ]
  }
}

// resource schema 'Microsoft.ApiManagement/service/apis/schemas@2024-06-01-preview' = {
//   parent: backendApi
//   name: 'backendApiSchema'
//   properties: {
//     contentType: 'application/vnd.oai.openapi.components+json'
//     document: {}
//   }
// }

// resource wiki 'Microsoft.ApiManagement/service/apis/wikis@2024-06-01-preview' = {
//   parent: backendApi
//   name: 'default'
//   properties: {
//     documents: []
//   }
// }

// // Backend API operations
// resource getTodosOperation 'Microsoft.ApiManagement/service/apis/operations@2023-05-01-preview' = {
//   parent: backendApi
//   dependsOn: [
//     schema
//   ]
//   name: 'get-api-todos'
//   properties: {
//     displayName: '/api/todos - GET'
//     method: 'GET'
//     urlTemplate: '/api/todos'
//     description: 'gets a list of todo items'
//     responses: [
//       {
//         statusCode: 200
//         description: 'OK'
//         representations: [
//           {
//             contentType: 'text/plain'
//             examples: {
//               default: {}
//             }
//             schemaId: 'backendApiSchema'
//             typeName: 'ApiTodosGet200TextPlainResponse'
//           }
//           {
//             contentType: 'application/json'
//             examples: {
//               default: {
//                 value: [
//                   {
//                     id: 0
//                     name: 'string'
//                     isComplete: true
//                   }
//                 ]
//               }
//             }
//             schemaId: 'backendApiSchema'
//             typeName: 'ApiTodosGet200ApplicationJsonResponse'
//           }
//           {
//             contentType: 'text/json'
//             examples: {
//               default: {
//                 value: [
//                   {
//                     id: 0
//                     name: 'string'
//                     isComplete: true
//                   }
//                 ]
//               }
//             }
//             schemaId: 'backendApiSchema'
//             typeName: 'ApiTodosGet200TextJsonResponse'
//           }
//         ]
//         headers: []
//       }
//     ]
//   }
// }

// resource createTodoOperation 'Microsoft.ApiManagement/service/apis/operations@2023-05-01-preview' = {
//   parent: backendApi
//   dependsOn: [
//     schema
//   ]
//   name: 'post-api-todos'
//   properties: {
//     displayName: '/api/todos - POST'
//     method: 'POST'
//     urlTemplate: '/api/todos'
//     description: 'creates a new todo item'
//     request: {
//       queryParameters: []
//       headers: []
//       representations: [
//         {
//           contentType: 'application/json'
//           examples: {
//             default: {
//               value: {
//                 id: 0
//                 name: 'string'
//                 isComplete: true
//               }
//             }
//           }
//           schemaId: 'backendApiSchema'
//           typeName: 'TodoItem'
//         }
//         {
//           contentType: 'text/json'
//           examples: {
//             default: {
//               value: {
//                 id: 0
//                 name: 'string'
//                 isComplete: true
//               }
//             }
//           }
//           schemaId: 'backendApiSchema'
//           typeName: 'TodoItem'
//         }
//         {
//           contentType: 'application/*+json'
//           examples: {
//             default: {
//               value: {
//                 id: 0
//                 name: 'string'
//                 isComplete: true
//               }
//             }
//           }
//           schemaId: 'backendApiSchema'
//           typeName: 'TodoItem'
//         }
//       ]
//     }
//     responses: [
//       {
//         statusCode: 200
//         description: 'OK'
//         representations: [
//           {
//             contentType: 'text/plain'
//             examples: {
//               default: {}
//             }
//             schemaId: 'backendApiSchema'
//             typeName: 'TodoItem'
//           }
//           {
//             contentType: 'application/json'
//             examples: {
//               default: {
//                 value: {
//                   id: 0
//                   name: 'string'
//                   isComplete: true
//                 }
//               }
//             }
//             schemaId: 'backendApiSchema'
//             typeName: 'TodoItem'
//           }
//           {
//             contentType: 'text/json'
//             examples: {
//               default: {
//                 value: {
//                   id: 0
//                   name: 'string'
//                   isComplete: true
//                 }
//               }
//             }
//             schemaId: 'backendApiSchema'
//             typeName: 'TodoItem'
//           }
//         ]
//         headers: []
//       }
//     ]
//   }
// }

// resource deleteTodoOperation 'Microsoft.ApiManagement/service/apis/operations@2023-05-01-preview' = {
//   parent: backendApi
//   dependsOn: [
//     schema
//   ]
//   name: 'delete-api-todos-id'
//   properties: {
//     displayName: '/api/todos/{id} - DELETE'
//     method: 'DELETE'
//     urlTemplate: '/api/todos/{id}'
//     templateParameters: [
//       {
//         name: 'id'
//         type: 'integer'
//         required: true
//         values: []
//         schemaId: 'backendApiSchema'
//         typeName: 'ApiTodos-id-DeleteRequest'
//       }
//     ]
//     description: 'delete a todo item, specified by its unique id'
//     responses: [
//       {
//         statusCode: 200
//         description: 'OK'
//         representations: []
//         headers: []
//       }
//     ]
//   }
// }

// resource getTodoOperation 'Microsoft.ApiManagement/service/apis/operations@2023-05-01-preview' = {
//   parent: backendApi
//   dependsOn: [
//     schema
//   ]
//   name: 'get-api-todos-id'
//   properties: {
//     displayName: '/api/todos/{id} - GET'
//     method: 'GET'
//     urlTemplate: '/api/todos/{id}'
//     templateParameters: [
//       {
//         name: 'id'
//         type: 'integer'
//         required: true
//         values: []
//         schemaId: 'backendApiSchema'
//         typeName: 'ApiTodos-id-GetRequest'
//       }
//     ]
//     description: 'gets a todo item by its id'
//     responses: [
//       {
//         statusCode: 200
//         description: 'OK'
//         representations: [
//           {
//             contentType: 'text/plain'
//             examples: {
//               default: {}
//             }
//             schemaId: 'backendApiSchema'
//             typeName: 'TodoItem'
//           }
//           {
//             contentType: 'application/json'
//             examples: {
//               default: {
//                 value: {
//                   id: 0
//                   name: 'string'
//                   isComplete: true
//                 }
//               }
//             }
//             schemaId: 'backendApiSchema'
//             typeName: 'TodoItem'
//           }
//           {
//             contentType: 'text/json'
//             examples: {
//               default: {
//                 value: {
//                   id: 0
//                   name: 'string'
//                   isComplete: true
//                 }
//               }
//             }
//             schemaId: 'backendApiSchema'
//             typeName: 'TodoItem'
//           }
//         ]
//         headers: []
//       }
//     ]
//   }
// }

// resource updateTodoOperation 'Microsoft.ApiManagement/service/apis/operations@2023-05-01-preview' = {
//   parent: backendApi
//   dependsOn: [
//     schema
//   ]
//   name: 'put-api-todos-id'
//   properties: {
//     displayName: '/api/todos/{id} - PUT'
//     method: 'PUT'
//     urlTemplate: '/api/todos/{id}'
//     templateParameters: [
//       {
//         name: 'id'
//         type: 'integer'
//         required: true
//         values: []
//         schemaId: 'backendApiSchema'
//         typeName: 'ApiTodos-id-PutRequest'
//       }
//     ]
//     description: 'updates an existing todo item, specified by its unique id'
//     request: {
//       queryParameters: []
//       headers: []
//       representations: [
//         {
//           contentType: 'application/json'
//           examples: {
//             default: {
//               value: {
//                 id: 0
//                 name: 'string'
//                 isComplete: true
//               }
//             }
//           }
//           schemaId: 'backendApiSchema'
//           typeName: 'TodoItem'
//         }
//         {
//           contentType: 'text/json'
//           examples: {
//             default: {
//               value: {
//                 id: 0
//                 name: 'string'
//                 isComplete: true
//               }
//             }
//           }
//           schemaId: 'backendApiSchema'
//           typeName: 'TodoItem'
//         }
//         {
//           contentType: 'application/*+json'
//           examples: {
//             default: {
//               value: {
//                 id: 0
//                 name: 'string'
//                 isComplete: true
//               }
//             }
//           }
//           schemaId: 'backendApiSchema'
//           typeName: 'TodoItem'
//         }
//       ]
//     }
//     responses: [
//       {
//         statusCode: 200
//         description: 'OK'
//         representations: []
//         headers: []
//       }
//     ]
//   }
// }

// Apply policy at the API level for all operations
resource mcpServerApiPolicy 'Microsoft.ApiManagement/service/apis/policies@2023-05-01-preview' = {
  parent: mcpServerApi
  name: 'policy'
  properties: {
    format: 'rawxml'
    value: loadTextContent('mcp-server-api-policy.xml')
  }
  dependsOn: [
    APIMGatewayURLNamedValue
    mcpTenantIdNamedValue
    mcpClientIdNamedValue
  ]
}

// Create or update the APIM Gateway URL named value
resource APIMGatewayURLNamedValue 'Microsoft.ApiManagement/service/namedValues@2021-08-01' = {
  parent: apimService
  name: 'APIMGatewayURL'
  properties: {
    displayName: 'APIMGatewayURL'
    value: apimService.properties.gatewayUrl
    secret: false
  }
}

// Create or update named values for MCP OAuth configuration
resource mcpTenantIdNamedValue 'Microsoft.ApiManagement/service/namedValues@2021-08-01' = {
  parent: apimService
  name: 'McpTenantId'
  properties: {
    displayName: 'McpTenantId'
    value: mcpAppTenantId
    secret: false
  }
}

resource mcpClientIdNamedValue 'Microsoft.ApiManagement/service/namedValues@2021-08-01' = {
  parent: apimService
  name: 'McpClientId'
  properties: {
    displayName: 'McpClientId'
    value: mcpAppId
    secret: false
  }
}

// PRM API definition in APIM
resource prmApi 'Microsoft.ApiManagement/service/apis@2023-05-01-preview' = {
  parent: apimService
  name: 'prm'
  properties: {
    displayName: 'PRM'
    description: 'Protected Resource Metadata API'
    subscriptionRequired: false
    path: '/'
    protocols: [
      'https'
    ]
  }
}

// Create the PRM GET endpoint
resource prmGetOperation 'Microsoft.ApiManagement/service/apis/operations@2023-05-01-preview' = {
  parent: prmApi
  name: 'mcp-prm'
  properties: {
    displayName: 'Protected Resource Metadata'
    method: 'GET'
    urlTemplate: '/.well-known/oauth-protected-resource'
    description: 'Protected Resource Metadata endpoint (RFC 9728)'
  }
}

// Apply PRM policy at the API level for all operations
resource prmPolicy 'Microsoft.ApiManagement/service/apis/operations/policies@2023-05-01-preview' = {
  parent: prmGetOperation
  name: 'policy'
  properties: {
    format: 'rawxml'
    value: loadTextContent('prm-policy.xml')
  }
  dependsOn: [
    APIMGatewayURLNamedValue
    mcpTenantIdNamedValue
    mcpClientIdNamedValue
  ]
}
