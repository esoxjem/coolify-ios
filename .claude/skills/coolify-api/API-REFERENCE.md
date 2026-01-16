# Coolify API v1 - Detailed Reference

This document contains complete specifications for all Coolify REST API endpoints.

## Table of Contents
- [Servers](#servers)
- [Applications](#applications)
- [Databases](#databases)
- [Services](#services)
- [Deployments](#deployments)
- [Projects](#projects)
- [Teams](#teams)

---

## Servers

### GET /servers

List all servers.

**Response Fields:**
| Field | Type | Description |
|-------|------|-------------|
| `id` | integer | Unique identifier |
| `uuid` | string | UUID identifier |
| `name` | string | Server name |
| `description` | string | Server description |
| `ip` | string | IP address |
| `user` | string | SSH username |
| `port` | integer | SSH port |
| `proxy_type` | string | Proxy type (traefik, caddy, etc.) |
| `settings.is_reachable` | boolean | Server reachability |
| `settings.is_usable` | boolean | Server usability |
| `settings.is_build_server` | boolean | Is build server |
| `settings.is_swarm_manager` | boolean | Is Swarm manager |
| `settings.is_swarm_worker` | boolean | Is Swarm worker |
| `settings.concurrent_builds` | integer | Max concurrent builds |

**Example Response:**
```json
[
  {
    "id": 1,
    "uuid": "server-uuid-123",
    "name": "production-server",
    "description": "Main production server",
    "ip": "192.168.1.100",
    "user": "root",
    "port": 22,
    "proxy_type": "traefik",
    "settings": {
      "is_reachable": true,
      "is_usable": true,
      "is_build_server": false,
      "concurrent_builds": 2
    }
  }
]
```

### GET /servers/{uuid}

Get server details by UUID.

**Path Parameters:**
- `uuid` (string, required) - Server UUID

### GET /servers/{uuid}/resources

Get all resources on a server (applications, databases, services).

---

## Applications

### GET /applications

List all applications.

**Response Fields:**
| Field | Type | Description |
|-------|------|-------------|
| `id` | integer | Unique identifier |
| `uuid` | string | UUID identifier |
| `name` | string | Application name |
| `fqdn` | string | Fully qualified domain name |
| `status` | string | Current status |
| `git_repository` | string | Git repository URL |
| `git_branch` | string | Git branch |
| `git_commit_sha` | string | Current commit SHA |
| `build_pack` | string | Build pack (nodejs, static, dockerfile, etc.) |
| `install_command` | string | Install command |
| `build_command` | string | Build command |
| `start_command` | string | Start command |
| `ports_exposes` | string | Exposed ports |
| `health_check_enabled` | boolean | Health check enabled |
| `health_check_path` | string | Health check path |
| `limits_memory` | string | Memory limit |
| `limits_cpus` | string | CPU limit |
| `environment_id` | integer | Environment ID |
| `destination_id` | integer | Destination ID |
| `created_at` | string | Creation timestamp |
| `updated_at` | string | Last update timestamp |

**Example Response:**
```json
[
  {
    "id": 1,
    "uuid": "app-uuid-123",
    "name": "my-web-app",
    "fqdn": "app.example.com",
    "status": "running",
    "git_repository": "git@github.com:user/repo.git",
    "git_branch": "main",
    "git_commit_sha": "abc123def456",
    "build_pack": "nodejs",
    "install_command": "npm install",
    "build_command": "npm run build",
    "start_command": "npm start",
    "ports_exposes": "3000",
    "health_check_enabled": true,
    "health_check_path": "/health",
    "limits_memory": "512Mi",
    "limits_cpus": "1",
    "environment_id": 1,
    "destination_id": 1,
    "created_at": "2024-01-15T10:00:00Z",
    "updated_at": "2024-01-15T10:30:00Z"
  }
]
```

### GET /applications/{uuid}

Get application by UUID.

### POST /applications/{uuid}/start

Start an application.

**Response:**
```json
{
  "message": "Application starting request queued."
}
```

### POST /applications/{uuid}/stop

Stop an application.

**Response:**
```json
{
  "message": "Application stopping request queued."
}
```

### POST /applications/{uuid}/restart

Restart an application.

**Response:**
```json
{
  "message": "Restart request queued.",
  "deployment_uuid": "deployment-uuid-123"
}
```

### GET /applications/{uuid}/envs

Get environment variables for an application.

**Response Fields:**
| Field | Type | Description |
|-------|------|-------------|
| `id` | integer | Unique identifier |
| `uuid` | string | UUID identifier |
| `key` | string | Environment variable key |
| `value` | string | Environment variable value |
| `is_runtime` | boolean | Available at runtime |
| `is_buildtime` | boolean | Available at build time |
| `is_literal` | boolean | Literal value (not interpolated) |
| `is_multiline` | boolean | Multiline value |
| `is_preview` | boolean | Available in preview deployments |

---

## Databases

### GET /databases

List all databases.

**Response Fields:**
| Field | Type | Description |
|-------|------|-------------|
| `id` | integer | Unique identifier |
| `uuid` | string | UUID identifier |
| `name` | string | Database name |
| `type` | string | Database type (postgresql, mysql, redis, etc.) |
| `status` | string | Current status |
| `image` | string | Docker image |
| `is_public` | boolean | Publicly accessible |
| `public_port` | integer | Public port (if is_public) |
| `limits_memory` | string | Memory limit |
| `limits_cpus` | string | CPU limit |

### POST /databases/postgresql

Create a PostgreSQL database.

**Request Body:**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `server_uuid` | string | Yes | Target server UUID |
| `project_uuid` | string | Yes | Project UUID |
| `environment_name` | string | Yes | Environment name |
| `environment_uuid` | string | Yes | Environment UUID |
| `destination_uuid` | string | Yes | Destination UUID |
| `name` | string | Yes | Database instance name |
| `postgres_user` | string | Yes | PostgreSQL username |
| `postgres_password` | string | Yes | PostgreSQL password |
| `postgres_db` | string | Yes | Database name |
| `image` | string | No | Docker image |
| `is_public` | boolean | No | Make publicly accessible |
| `public_port` | integer | No | Public port |
| `limits_memory` | string | No | Memory limit |
| `limits_cpus` | string | No | CPU limit |
| `instant_deploy` | boolean | No | Deploy immediately |

**Example Request:**
```json
{
  "server_uuid": "server-uuid-123",
  "project_uuid": "project-uuid-456",
  "environment_name": "production",
  "environment_uuid": "env-uuid-789",
  "destination_uuid": "dest-uuid-abc",
  "name": "my-postgres",
  "postgres_user": "app_user",
  "postgres_password": "secure_password",
  "postgres_db": "app_database",
  "image": "postgres:16",
  "instant_deploy": true
}
```

### POST /databases/mysql

Create a MySQL database.

**Request Body:**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `server_uuid` | string | Yes | Target server UUID |
| `project_uuid` | string | Yes | Project UUID |
| `environment_name` | string | Yes | Environment name |
| `environment_uuid` | string | Yes | Environment UUID |
| `destination_uuid` | string | Yes | Destination UUID |
| `name` | string | Yes | Database instance name |
| `mysql_root_password` | string | Yes | Root password |
| `mysql_user` | string | No | MySQL username |
| `mysql_password` | string | No | MySQL password |
| `mysql_database` | string | No | Database name |

### POST /databases/redis

Create a Redis database.

**Request Body:**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `server_uuid` | string | Yes | Target server UUID |
| `project_uuid` | string | Yes | Project UUID |
| `environment_name` | string | Yes | Environment name |
| `environment_uuid` | string | Yes | Environment UUID |
| `destination_uuid` | string | Yes | Destination UUID |
| `name` | string | Yes | Instance name |
| `redis_password` | string | Yes | Redis password |
| `redis_conf` | string | No | Custom Redis config |

### POST /databases/mongodb

Create a MongoDB database.

### POST /databases/mariadb

Create a MariaDB database.

### Database Actions

All database types support:
- `GET/POST /databases/{uuid}/start` - Start database
- `GET/POST /databases/{uuid}/stop` - Stop database
- `GET/POST /databases/{uuid}/restart` - Restart database

---

## Services

### GET /services

List all services.

**Response Fields:**
| Field | Type | Description |
|-------|------|-------------|
| `id` | integer | Unique identifier |
| `uuid` | string | UUID identifier |
| `name` | string | Service name |
| `service_type` | string | Service type |
| `status` | string | Current status |
| `docker_compose` | string | Docker Compose content |
| `docker_compose_raw` | string | Raw Docker Compose |
| `environment_id` | integer | Environment ID |
| `server_id` | integer | Server ID |

### GET /services/{uuid}

Get service details.

### GET /services/{uuid}/envs

Get service environment variables.

**Response Fields:**
| Field | Type | Description |
|-------|------|-------------|
| `id` | integer | Unique identifier |
| `uuid` | string | UUID identifier |
| `key` | string | Environment variable key |
| `value` | string | Environment variable value |
| `real_value` | string | Resolved value |
| `is_runtime` | boolean | Available at runtime |
| `is_buildtime` | boolean | Available at build time |
| `is_literal` | boolean | Literal value |
| `is_shared` | boolean | Shared across containers |

### Service Actions

- `GET/POST /services/{uuid}/start` - Start service
- `GET/POST /services/{uuid}/stop` - Stop service
- `GET/POST /services/{uuid}/restart` - Restart service

---

## Deployments

### GET /deployments

List all deployments.

**Query Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `skip` | integer | Skip N results (pagination) |
| `take` | integer | Take N results (pagination) |

### GET /deployments/{uuid}

Get deployment details.

**Response Fields:**
| Field | Type | Description |
|-------|------|-------------|
| `id` | integer | Unique identifier |
| `deployment_uuid` | string | Deployment UUID |
| `application_id` | string | Application ID |
| `application_name` | string | Application name |
| `status` | string | Deployment status |
| `commit` | string | Git commit SHA |
| `commit_message` | string | Git commit message |
| `logs` | string | Deployment logs |
| `is_webhook` | boolean | Triggered by webhook |
| `is_api` | boolean | Triggered by API |
| `force_rebuild` | boolean | Forced rebuild |
| `restart_only` | boolean | Restart only (no rebuild) |
| `rollback` | boolean | Is rollback deployment |
| `server_id` | integer | Server ID |
| `server_name` | string | Server name |
| `deployment_url` | string | Deployment URL |
| `created_at` | string | Creation timestamp |
| `updated_at` | string | Last update timestamp |

**Example Response:**
```json
{
  "id": 123,
  "deployment_uuid": "deploy-uuid-123",
  "application_id": "app-uuid-456",
  "application_name": "my-app",
  "status": "finished",
  "commit": "abc123def456",
  "commit_message": "Fix authentication bug",
  "logs": "Building application...\nDeployed successfully.",
  "is_webhook": true,
  "is_api": false,
  "force_rebuild": false,
  "restart_only": false,
  "rollback": false,
  "server_id": 1,
  "server_name": "production-server",
  "deployment_url": "https://app.example.com",
  "created_at": "2024-01-15T10:00:00Z",
  "updated_at": "2024-01-15T10:05:00Z"
}
```

### GET /deployments/applications/{uuid}

List deployments for a specific application.

**Path Parameters:**
- `uuid` (string, required) - Application UUID

**Query Parameters:**
- `skip` (integer) - Skip N results
- `take` (integer) - Take N results

---

## Projects

### GET /projects

List all projects.

**Response Fields:**
| Field | Type | Description |
|-------|------|-------------|
| `id` | integer | Unique identifier |
| `uuid` | string | UUID identifier |
| `name` | string | Project name |
| `description` | string | Project description |
| `environments` | array | List of environments |

### GET /projects/{uuid}

Get project details with environments.

**Example Response:**
```json
{
  "id": 1,
  "uuid": "project-uuid-123",
  "name": "my-project",
  "description": "Main project",
  "environments": [
    {
      "id": 1,
      "name": "production",
      "project_id": 1,
      "description": "Production environment",
      "created_at": "2024-01-15T10:00:00Z",
      "updated_at": "2024-01-15T10:00:00Z"
    },
    {
      "id": 2,
      "name": "staging",
      "project_id": 1,
      "description": "Staging environment",
      "created_at": "2024-01-15T10:00:00Z",
      "updated_at": "2024-01-15T10:00:00Z"
    }
  ]
}
```

### GET /projects/{uuid}/environments

List environments for a project.

---

## Teams

### GET /teams

List all teams.

### GET /teams/{id}

Get team details.

### GET /teams/{id}/members

Get team members.

### GET /teams/current

Get the current team.

### GET /teams/current/members

Get current team members.

---

## Error Handling

### HTTP Status Codes

| Code | Description |
|------|-------------|
| 200 | Success |
| 201 | Created |
| 400 | Bad Request - Invalid parameters |
| 401 | Unauthorized - Invalid or missing token |
| 403 | Forbidden - Insufficient permissions |
| 404 | Not Found - Resource doesn't exist |
| 422 | Unprocessable Entity - Validation failed |
| 500 | Internal Server Error |

### Error Response Format

```json
{
  "message": "Error description",
  "error": "Error type"
}
```

---

## Swift Model Examples

### Server Model
```swift
struct Server: Codable, Identifiable {
    let id: Int
    let uuid: String
    let name: String
    let description: String?
    let ip: String
    let user: String
    let port: Int
    let proxyType: String?
    let settings: ServerSettings?
}

struct ServerSettings: Codable {
    let isReachable: Bool
    let isUsable: Bool
    let isBuildServer: Bool
    let concurrentBuilds: Int
}
```

### Application Model
```swift
struct Application: Codable, Identifiable {
    let id: Int
    let uuid: String
    let name: String
    let fqdn: String?
    let status: String
    let gitRepository: String?
    let gitBranch: String?
    let gitCommitSha: String?
    let buildPack: String?
    let portsExposes: String?
    let healthCheckEnabled: Bool?
    let healthCheckPath: String?
    let limitsMemory: String?
    let limitsCpus: String?
    let createdAt: String
    let updatedAt: String
}
```

### Deployment Model
```swift
struct Deployment: Codable, Identifiable {
    let id: Int
    let deploymentUuid: String
    let applicationId: String?
    let applicationName: String?
    let status: String
    let commit: String?
    let commitMessage: String?
    let logs: String?
    let isWebhook: Bool?
    let isApi: Bool?
    let serverName: String?
    let deploymentUrl: String?
    let createdAt: String
    let updatedAt: String
}
```

### Database Model
```swift
struct Database: Codable, Identifiable {
    let id: Int
    let uuid: String
    let name: String
    let type: String?
    let status: String
    let image: String?
    let isPublic: Bool?
    let publicPort: Int?
    let limitsMemory: String?
    let limitsCpus: String?
}
```

### Service Model
```swift
struct Service: Codable, Identifiable {
    let id: Int
    let uuid: String
    let name: String
    let serviceType: String?
    let description: String?
    let environmentId: Int?
    let serverId: Int?
    let createdAt: String
    let updatedAt: String
}
```
