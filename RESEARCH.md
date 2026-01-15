# Coolify iOS App - Feasibility Research

## Executive Summary

**Verdict: YES, building an iOS app for Coolify is absolutely feasible.**

Coolify provides a comprehensive REST API with full CRUD operations, making it well-suited for a mobile client. The API uses Bearer token authentication and covers all the functionality needed for server management, deployments, and monitoring.

---

## Coolify API Overview

### Authentication
- **Method**: Bearer Token (Laravel Sanctum)
- **Base URL**: `http://<your-instance>:8000/api/v1` (self-hosted) or `https://app.coolify.io/api/v1` (cloud)
- **Token Generation**: Users create tokens in the Coolify UI under "Keys & Tokens / API tokens"
- **Permissions**:
  - Read-only: Can only read data
  - Read-sensitive: Can read data including sensitive info (passwords, keys)
  - Full access: Can create, update, delete resources

### OpenAPI Specification
Coolify provides an OpenAPI 3.1 specification at:
- https://github.com/coollabsio/coolify/blob/v4.x/openapi.yaml

This can be used to **auto-generate Swift API clients** using tools like:
- OpenAPI Generator
- Swift OpenAPI Generator (Apple's official tool)
- CreateAPI

---

## Available API Endpoints

### 1. Servers (`/servers`)
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/servers` | GET | List all servers |
| `/servers` | POST | Create a new server |
| `/servers/{uuid}` | GET | Get server details |
| `/servers/{uuid}` | PATCH | Update server |
| `/servers/{uuid}` | DELETE | Delete server |
| `/servers/{uuid}/validate` | GET | Validate server connectivity |
| `/servers/{uuid}/resources` | GET | Get all resources on server |
| `/servers/{uuid}/domains` | GET | List domains on server |

### 2. Applications (`/applications`)
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/applications` | GET | List all applications |
| `/applications/public` | POST | Create app from public repo |
| `/applications/private-github-app` | POST | Create app via GitHub App |
| `/applications/private-deploy-key` | POST | Create app via deploy key |
| `/applications/dockerfile` | POST | Create app from Dockerfile |
| `/applications/dockerimage` | POST | Create app from Docker image |
| `/applications/dockercompose` | POST | Create app from docker-compose |
| `/applications/{uuid}` | GET | Get application details |
| `/applications/{uuid}` | PATCH | Update application |
| `/applications/{uuid}` | DELETE | Delete application |
| `/applications/{uuid}/start` | GET/POST | Start application |
| `/applications/{uuid}/stop` | GET/POST | Stop application |
| `/applications/{uuid}/restart` | GET/POST | Restart application |
| `/applications/{uuid}/logs` | GET | Get application logs |
| `/applications/{uuid}/envs` | GET | List environment variables |
| `/applications/{uuid}/envs` | POST | Create environment variable |
| `/applications/{uuid}/envs` | PATCH | Update environment variable |
| `/applications/{uuid}/envs/bulk` | PATCH | Bulk update env vars |
| `/applications/{uuid}/envs/{env_uuid}` | DELETE | Delete env variable |

### 3. Databases (`/databases`)
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/databases` | GET | List all databases |
| `/databases/{uuid}` | GET | Get database details |
| `/databases/{uuid}` | PATCH | Update database |
| `/databases/{uuid}` | DELETE | Delete database |
| `/databases/{uuid}/backups` | GET | Get backup details |
| `/databases/{uuid}/backups` | POST | Create backup config |
| `/databases/{uuid}/start` | GET/POST | Start database |
| `/databases/{uuid}/stop` | GET/POST | Stop database |
| `/databases/{uuid}/restart` | GET/POST | Restart database |

### 4. Services (`/services`)
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/services` | GET | List all services |
| `/services/{uuid}` | GET | Get service details |
| `/services/{uuid}` | PATCH | Update service |
| `/services/{uuid}` | DELETE | Delete service |
| `/services/{uuid}/start` | GET/POST | Start service |
| `/services/{uuid}/stop` | GET/POST | Stop service |
| `/services/{uuid}/restart` | GET/POST | Restart service |
| `/services/{uuid}/envs` | GET | List environment variables |

### 5. Deployments (`/deployments`)
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/deployments` | GET | List all running deployments |
| `/deployments/{uuid}` | GET | Get deployment details |
| `/deploy` | GET/POST | Deploy by tag or UUID |

### 6. Projects (`/projects`)
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/projects` | GET | List all projects |
| `/projects/{uuid}` | GET | Get project details |
| `/projects/{uuid}/{environment_name}` | GET | Get project environment |

### 7. Teams (`/teams`)
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/teams` | GET | List all teams |
| `/teams/current` | GET | Get current team |
| `/teams/current/members` | GET | Get team members |
| `/teams/{id}` | GET | Get team by ID |
| `/teams/{id}/members` | GET | Get team members |

### 8. Private Keys (`/security/keys`)
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/security/keys` | GET | List private keys |
| `/security/keys` | POST | Create private key |
| `/security/keys/{uuid}` | GET | Get key details |
| `/security/keys/{uuid}` | PATCH | Update key |
| `/security/keys/{uuid}` | DELETE | Delete key |

### 9. System Endpoints
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/health` | GET | Health check (no auth) |
| `/version` | GET | Get API version |
| `/enable` | GET | Enable API |
| `/disable` | GET | Disable API |

---

## iOS App Feature Mapping

Based on the available API, here's what features can be built:

### Core Features (Fully Supported)
| Feature | API Support | Notes |
|---------|-------------|-------|
| Add API Key | ✅ | User enters their Bearer token |
| View Servers | ✅ | `GET /servers` |
| Server Status | ✅ | `GET /servers/{uuid}` includes status |
| View Applications | ✅ | `GET /applications` |
| App Status | ✅ | Status included in response |
| Start/Stop/Restart Apps | ✅ | Action endpoints available |
| View Deployments | ✅ | `GET /deployments` |
| Trigger Deployments | ✅ | `POST /deploy` |
| View Logs | ✅ | `GET /applications/{uuid}/logs` |
| View Databases | ✅ | `GET /databases` |
| Database Start/Stop | ✅ | Action endpoints available |
| View Services | ✅ | `GET /services` |
| Service Start/Stop | ✅ | Action endpoints available |
| Environment Variables | ✅ | Full CRUD support |
| Projects Overview | ✅ | `GET /projects` |
| Team Management | ✅ | Team endpoints available |

### Advanced Features
| Feature | API Support | Notes |
|---------|-------------|-------|
| Create Applications | ✅ | Multiple creation endpoints |
| Create Databases | ✅ | Database creation endpoints |
| Create Servers | ✅ | Server creation + cloud providers |
| Database Backups | ✅ | Backup management endpoints |
| Push Notifications | ⚠️ | Would need webhook integration |
| Real-time Updates | ⚠️ | Would need polling (no WebSocket) |

---

## Recommended Tech Stack

### Swift/iOS
```
- SwiftUI (UI Framework)
- Swift Concurrency (async/await)
- URLSession or Alamofire (Networking)
- Swift OpenAPI Generator (API Client Generation)
- KeychainSwift (Secure token storage)
- SwiftUI Charts (Metrics visualization)
```

### Architecture
```
- MVVM or TCA (The Composable Architecture)
- Repository Pattern for API abstraction
- Combine for reactive data flow
```

### Minimum iOS Version
- iOS 16+ recommended (for latest SwiftUI features)
- iOS 15+ if broader compatibility needed

---

## API Client Generation

You can auto-generate a Swift API client from the OpenAPI spec:

### Option 1: Swift OpenAPI Generator (Apple Official)
```bash
# Install the generator
swift package add swift-openapi-generator
swift package add swift-openapi-runtime
swift package add swift-openapi-urlsession

# Generate client from openapi.yaml
```

### Option 2: OpenAPI Generator
```bash
# Install
brew install openapi-generator

# Generate Swift client
openapi-generator generate \
  -i https://raw.githubusercontent.com/coollabsio/coolify/v4.x/openapi.yaml \
  -g swift5 \
  -o ./CoolifyAPI
```

---

## Sample API Usage

### Authentication Header
```swift
let request = URLRequest(url: url)
request.setValue("Bearer \(apiToken)", forHTTPHeaderField: "Authorization")
request.setValue("application/json", forHTTPHeaderField: "Content-Type")
```

### Example: List Servers
```swift
// GET /api/v1/servers
func fetchServers() async throws -> [Server] {
    let url = URL(string: "\(baseURL)/api/v1/servers")!
    var request = URLRequest(url: url)
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

    let (data, _) = try await URLSession.shared.data(for: request)
    return try JSONDecoder().decode([Server].self, from: data)
}
```

### Example: Deploy Application
```swift
// GET /api/v1/applications/{uuid}/start
func deployApplication(uuid: String) async throws -> DeploymentResponse {
    let url = URL(string: "\(baseURL)/api/v1/applications/\(uuid)/start")!
    var request = URLRequest(url: url)
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

    let (data, _) = try await URLSession.shared.data(for: request)
    return try JSONDecoder().decode(DeploymentResponse.self, from: data)
}
```

---

## Potential Challenges

### 1. Real-time Updates
- **Issue**: No WebSocket support for real-time status updates
- **Solution**: Implement polling with configurable intervals, or use iOS background refresh

### 2. Push Notifications
- **Issue**: No native push notification support in Coolify API
- **Solutions**:
  - Set up webhook to your own server that forwards to APNs
  - Use Coolify's notification system (Discord, Telegram, Email) as workarounds

### 3. Self-Hosted Instances
- **Issue**: Users have different base URLs
- **Solution**: Allow users to configure their Coolify instance URL in app settings

### 4. Token Security
- **Issue**: API tokens need secure storage
- **Solution**: Use iOS Keychain for secure token storage

### 5. Large Log Files
- **Issue**: Logs can be very large
- **Solution**: Use pagination with `lines` parameter, implement lazy loading

---

## Suggested App Screens

1. **Onboarding/Setup**
   - Enter Coolify instance URL
   - Enter API token
   - Validate connection

2. **Dashboard**
   - Overview of all servers
   - Quick stats (total apps, databases, services)
   - Recent deployments

3. **Servers List**
   - All servers with status indicators
   - Server details (resources, uptime)
   - Quick actions (validate connection)

4. **Applications List**
   - All applications grouped by project
   - Status indicators (running, stopped, deploying)
   - Quick actions (start, stop, restart, deploy)

5. **Application Detail**
   - Deployment status & history
   - Live logs viewer
   - Environment variables management
   - Resource usage

6. **Databases List**
   - All databases with status
   - Connection details (masked)
   - Backup status

7. **Deployments**
   - Current/active deployments
   - Deployment history
   - Deployment logs

8. **Settings**
   - Multiple Coolify instances support
   - Notification preferences
   - Polling interval configuration

---

## Conclusion

Building a Coolify iOS app is **highly feasible** because:

1. **Comprehensive API**: Coolify provides a well-documented REST API covering all essential features
2. **OpenAPI Spec**: Official OpenAPI 3.1 specification enables automatic client generation
3. **Standard Auth**: Bearer token authentication is simple to implement
4. **Full CRUD**: Complete create, read, update, delete operations are available
5. **Action Endpoints**: Start, stop, restart, and deploy operations are fully supported

The main limitations are the lack of real-time updates (WebSocket) and native push notifications, but these can be worked around with polling and external notification services.

---

## Sources

- [Coolify API Reference](https://coolify.io/docs/api-reference/api/)
- [Coolify Authorization Guide](https://coolify.io/docs/api-reference/authorization)
- [Coolify OpenAPI Spec](https://github.com/coollabsio/coolify/blob/v4.x/openapi.yaml)
- [Coolify GitHub Repository](https://github.com/coollabsio/coolify)
- [Application API Endpoints - DeepWiki](https://deepwiki.com/coollabsio/coolify/8.2-application-api-endpoints)
- [Server and Infrastructure API - DeepWiki](https://deepwiki.com/coollabsio/coolify/8.4-server-and-infrastructure-api)
