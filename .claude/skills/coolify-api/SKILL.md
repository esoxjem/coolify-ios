---
name: coolify-api
description: Comprehensive reference for Coolify REST API v1. Use when implementing API calls, creating new endpoints, debugging API responses, or understanding Coolify's data models. Covers servers, applications, databases, services, deployments, projects, and teams.
---

# Coolify API Reference

This skill provides comprehensive documentation for the Coolify REST API v1, used by the Coolify iOS app to manage self-hosted instances.

## Quick Start

### Base URL
```
{instance.baseURL}/api/v1
```

### Authentication
All requests require a Bearer token in the Authorization header:
```bash
curl -X GET "https://your-coolify.io/api/v1/servers" \
  -H "Authorization: Bearer YOUR_API_TOKEN"
```

Generate tokens from **Settings → Keys & Tokens → API Tokens** in the Coolify UI.

### Swift Example
```swift
actor CoolifyAPIClient {
    private let baseURL: URL
    private let token: String

    func request<T: Decodable>(_ endpoint: String) async throws -> T {
        var request = URLRequest(url: baseURL.appendingPathComponent(endpoint))
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, _) = try await URLSession.shared.data(for: request)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(T.self, from: data)
    }
}
```

## Core Endpoints

### Servers

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/servers` | List all servers |
| GET | `/servers/{uuid}` | Get server by UUID |
| GET | `/servers/{uuid}/resources` | Get server resources |
| GET | `/servers/{uuid}/domains` | Get server domains |
| POST | `/servers` | Create server |
| PATCH | `/servers/{uuid}` | Update server |
| DELETE | `/servers/{uuid}` | Delete server |

### Applications

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/applications` | List all applications |
| GET | `/applications/{uuid}` | Get application by UUID |
| GET | `/applications/{uuid}/envs` | Get environment variables |
| POST | `/applications` | Create application |
| PATCH | `/applications/{uuid}` | Update application |
| DELETE | `/applications/{uuid}` | Delete application |
| GET/POST | `/applications/{uuid}/start` | Start application |
| GET/POST | `/applications/{uuid}/stop` | Stop application |
| GET/POST | `/applications/{uuid}/restart` | Restart application |

### Databases

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/databases` | List all databases |
| GET | `/databases/{uuid}` | Get database by UUID |
| POST | `/databases/postgresql` | Create PostgreSQL |
| POST | `/databases/mysql` | Create MySQL |
| POST | `/databases/redis` | Create Redis |
| POST | `/databases/mongodb` | Create MongoDB |
| POST | `/databases/mariadb` | Create MariaDB |
| POST | `/databases/keydb` | Create KeyDB |
| POST | `/databases/dragonfly` | Create Dragonfly |
| POST | `/databases/clickhouse` | Create ClickHouse |
| GET/POST | `/databases/{uuid}/start` | Start database |
| GET/POST | `/databases/{uuid}/stop` | Stop database |
| GET/POST | `/databases/{uuid}/restart` | Restart database |

### Services

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/services` | List all services |
| GET | `/services/{uuid}` | Get service by UUID |
| GET | `/services/{uuid}/envs` | Get environment variables |
| POST | `/services` | Create service |
| PATCH | `/services/{uuid}` | Update service |
| DELETE | `/services/{uuid}` | Delete service |
| GET/POST | `/services/{uuid}/start` | Start service |
| GET/POST | `/services/{uuid}/stop` | Stop service |
| GET/POST | `/services/{uuid}/restart` | Restart service |

### Deployments

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/deployments` | List all deployments |
| GET | `/deployments/{uuid}` | Get deployment by UUID |
| GET | `/deployments/applications/{uuid}` | List deployments for app |
| POST | `/deploy` | Trigger deployment |

### Projects

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/projects` | List all projects |
| GET | `/projects/{uuid}` | Get project by UUID |
| GET | `/projects/{uuid}/environments` | Get environments |
| POST | `/projects` | Create project |
| PATCH | `/projects/{uuid}` | Update project |
| DELETE | `/projects/{uuid}` | Delete project |

### Teams

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/teams` | List all teams |
| GET | `/teams/{id}` | Get team by ID |
| GET | `/teams/{id}/members` | Get team members |
| GET | `/teams/current` | Get current team |
| GET | `/teams/current/members` | Get current team members |

## Response Formats

### Success Response
```json
{
  "id": 1,
  "uuid": "abc123-def456",
  "name": "my-resource",
  "status": "running",
  "created_at": "2024-01-15T10:00:00Z",
  "updated_at": "2024-01-15T10:30:00Z"
}
```

### Action Response (Start/Stop/Restart)
```json
{
  "message": "Restart request queued.",
  "deployment_uuid": "doogksw"
}
```

### Error Response
```json
{
  "message": "Resource not found",
  "error": "Not Found"
}
```

## Status Values

### Resource Status
- `running` - Resource is active
- `stopped` - Resource is stopped
- `exited` - Container has exited
- `restarting` - Resource is restarting
- `starting` - Resource is starting up

### Deployment Status
- `queued` - Deployment is queued
- `in_progress` - Deployment is running
- `finished` - Deployment completed successfully
- `failed` - Deployment failed
- `cancelled` - Deployment was cancelled

## Common Patterns

### Pagination
Some list endpoints support pagination:
```
GET /deployments/applications/{uuid}?skip=0&take=10
```

### UUID vs ID
- Most resources use `uuid` (string) for API identification
- Some legacy endpoints use `id` (integer)
- Always prefer `uuid` when available

### Snake Case
API responses use snake_case. Configure your decoder:
```swift
decoder.keyDecodingStrategy = .convertFromSnakeCase
```

## Detailed Reference

For complete endpoint documentation including all request/response fields, see:
- [API-REFERENCE.md](API-REFERENCE.md) - Full endpoint specifications
