# MCP REST API with Azure API Management

This repository demonstrates how to create a Model Context Protocol (MCP) server using Azure API Management (APIM) that transforms a REST API into an MCP-compliant endpoint. The solution showcases a modern, secure, and scalable architecture for exposing backend services through the MCP protocol.

## Overview

This repo provides a fully deployable solution consisting of a Todo REST API backend deployed on Azure App Service, fronted by Azure API Management which provides MCP server capabilities. The architecture implements OAuth 2.0 authentication with Azure Entra ID and follows MCP specifications for tool discovery and execution.

## Architecture

```
┌─────────────────────┐    ┌──────────────────────┐    ┌─────────────────────┐
│  MCP Client         │───▶  Azure API            ───▶   Todo API           │ 
│  (VS Code, etc.)    │    │  Management          │    │  (App Service)      │
│                     │    │                      │    │                     │
│  - OAuth2 Auth      │    │  - MCP Server        │    │  - ASP.NET Core 9   │
│  - Tool Discovery   │    │  - Token Validation  │    │  - Entity Framework │
│  - Tool Execution   │    │  - Protocol Transform│    │  - In-Memory DB     │
└─────────────────────┘    └──────────────────────┘    └─────────────────────┘
                                      │
                                      ▼
                           ┌──────────────────────┐
                           │  Azure Entra ID      │
                           │                      │
                           │  - OAuth2 Provider   │
                           │  - Token Issuer      │
                           │  - App Registration  │
                           └──────────────────────┘
```

## Components

### 1. Todo API Backend (`/src/TodoApi`)
A simple ASP.NET Core 9 Web API that provides CRUD operations for todo items:

- **Technologies**: ASP.NET Core 9, Entity Framework Core, Swagger/OpenAPI
- **Database**: In-memory database for demonstration purposes
- **Features**:
  - RESTful API endpoints (`GET`, `POST`, `PUT`, `DELETE`)
  - Swagger UI for API documentation and testing
  - OpenAPI specification generation
  - Hosted on Azure App Service

**API Endpoints**:
- `GET /api/todos` - Retrieve all todo items
- `GET /api/todos/{id}` - Get a specific todo item
- `POST /api/todos` - Create a new todo item
- `PUT /api/todos/{id}` - Update an existing todo item
- `DELETE /api/todos/{id}` - Delete a todo item

### 2. Azure Infrastructure (`/infra`)
Bicep templates for Infrastructure as Code (IaC) deployment:

#### Core Infrastructure (`/infra/main.bicep`)
- **Resource Group**: Container for all Azure resources
- **App Service Plan**: Hosting plan for the web application
- **App Service**: Hosts the Todo API backend
- **User Assigned Managed Identity**: Secure identity for resource access
- **Azure Entra ID App Registration**: OAuth2 application for MCP authentication

#### API Management (`/infra/apim/`)
- **APIM Service** (`apim.bicep`): Azure API Management instance
- **Backend API** (`api.bicep`): Configures the Todo API as a backend service
- **MCP Server API**: Transforms REST operations into MCP tools
- **OAuth2 Policies** (`mcp-server-api-policy.xml`): Token validation and security
- **Protected Resource Metadata** (`prm-policy.xml`): RFC 9728 compliance for OAuth2 discovery

### 3. MCP Server Configuration
The Azure API Management service is configured to expose MCP tools that correspond to the REST API operations:

**MCP Tools Available**:
- `apiTodosGet` - List all todos
- `apiTodosPost` - Create a new todo
- `apiTodosIdGet` - Get a specific todo by ID
- `apiTodosIdPut` - Update a todo by ID
- `apiTodosIdDelete` - Delete a todo by ID

### 4. Security & Authentication
- **OAuth 2.0 Flow**: Azure Entra ID provides authentication
- **JWT Token Validation**: APIM validates access tokens
- **Protected Resource Metadata**: Implements RFC 9728 for OAuth2 discovery
- **Managed Identity**: Secure service-to-service authentication

## Prerequisites

- Azure subscription
- [Azure Developer CLI (azd)](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/install-azd)
- [.NET 9 SDK](https://dotnet.microsoft.com/download/dotnet/9.0)
- [PowerShell](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell) (for Windows users)

## Getting Started

### 1. Clone the Repository
```bash
git clone https://github.com/cplemm/mcp-restapi-apim.git
cd mcp-restapi-apim
```

### 2. Deploy to Azure
```bash
# Login to Azure
azd auth login

# Initialize the environment
azd init

# Deploy the infrastructure and application
azd up
```

The deployment will:
1. Create all Azure resources using Bicep templates
2. Build and deploy the Todo API to App Service
3. Configure API Management with MCP server capabilities
4. Set up OAuth2 authentication with Azure Entra ID

### 3. Configure MCP Client

After deployment, you'll receive the MCP server endpoint URL. Configure your MCP client (e.g., VS Code with MCP extension) to use this endpoint.

**Example MCP Configuration** (`.vscode/mcp.json`):
```json
{
  "servers": {
    "todo-server": {
      "url": "https://<your-apim-instance>.azure-api.net/todos-mcp/mcp",
      "type": "http"
    }
  },
  "inputs": []
}
```

### 4. Authentication Setup
1. Navigate to the Azure portal
2. Find your Entra ID app registration
3. Configure the OAuth2 flow in your MCP client
4. Use the provided client credentials to authenticate

## Development

### Local Development
```bash
# Navigate to the API project
cd src/TodoApi

# Run the API locally
dotnet run
```

The API will be available at `https://localhost:7049` with Swagger UI at `/swagger`.

### Testing the API
You can test the API endpoints using:
- Swagger UI (when running locally or deployed)
- Postman or similar API testing tools
- curl commands

Example curl command:
```bash
curl -X GET "https://<your-app-name>.azurewebsites.net/api/todos" \
  -H "accept: application/json"
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Resources

- [Model Context Protocol Specification](https://modelcontextprotocol.io/)
- [Azure API Management Documentation](https://docs.microsoft.com/en-us/azure/api-management/)
- [ASP.NET Core Documentation](https://docs.microsoft.com/en-us/aspnet/core/)
- [Azure Bicep Documentation](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
- [OAuth 2.0 RFC 6749](https://tools.ietf.org/html/rfc6749)
- [Protected Resource Metadata RFC 9728](https://tools.ietf.org/html/rfc9728)