---
title: Coolify API Response Decoding Failure - Missing ID Field
category: runtime-errors
tags:
  - swift
  - codable
  - api-decoding
  - json
  - coolify-api
  - ios
component: Shared/API/Models
severity: high
date_solved: 2026-01-16
symptoms:
  - "Failed to decode response: The data couldn't be read because it is missing"
  - API calls return successfully but model decoding fails
  - App cannot display servers, applications, databases, services, or deployments
root_cause: Swift models defined `let id: Int` as required property but Coolify API responses use `uuid` field instead of numeric `id` at top level
---

# Coolify API Response Decoding Failure - Missing ID Field

## Problem Description

The Coolify iOS app Swift models failed to decode API responses from the Coolify REST API. When fetching servers, applications, databases, services, and deployments, the JSON decoder threw errors because the models expected fields that did not exist in the actual API responses.

**Error message:**
```
Failed to decode response: The data couldn't be read because it is missing.
```

The app would show empty lists or error dialogs when trying to display resources, despite the API returning valid data.

## Root Cause Analysis

The Swift models were designed based on assumptions about the Coolify API response structure rather than the actual API contract. Two key mismatches were discovered using the NetworkLogger debugging tool:

### 1. Missing `id` Integer Field

The models expected a required `id: Int` field at the top level of each resource:

```swift
// What the model expected
struct Server: Identifiable, Codable {
    let id: Int      // Required integer ID
    let uuid: String
    // ...
}
```

However, the Coolify API returns `uuid` as the primary identifier with no `id` field at the resource level:

```json
{
  "uuid": "abc123-def456-...",
  "name": "My Server",
  "ip": "192.168.1.1"
  // No "id" field exists here
}
```

### 2. Server Proxy Field Type Mismatch

The Server model expected `proxyType: String?` but the API returns a nested `proxy` object:

```json
{
  "proxy": {
    "redirect_enabled": true
  }
}
```

### Impact

Because `id` was declared as a required `let` constant, Swift's `Codable` decoder threw a `keyNotFound` error when trying to parse any API response, causing all resource fetches to fail.

## Solution

### Pattern: Use Computed Property for Identifiable Conformance

Convert the `id` property from a stored property to a computed property that returns the `uuid`:

**Before (Broken):**
```swift
struct Server: Identifiable, Codable, Hashable {
    let id: Int           // Required field that doesn't exist in API
    let uuid: String
    let name: String
    // ...

    enum CodingKeys: String, CodingKey {
        case id, uuid, name  // Includes 'id' for decoding
        // ...
    }
}
```

**After (Fixed):**
```swift
struct Server: Identifiable, Codable, Hashable {
    let uuid: String
    let name: String
    // ...

    // Use uuid as the Identifiable id
    var id: String { uuid }

    enum CodingKeys: String, CodingKey {
        case uuid, name  // 'id' removed - not decoded from JSON
        // ...
    }
}
```

### Key Changes

1. **Remove `let id: Int`** - Delete the stored property
2. **Add computed `var id: String { uuid }`** - Satisfies `Identifiable` protocol using existing `uuid`
3. **Remove `id` from CodingKeys** - Prevents decoder from looking for non-existent field
4. **Change `id` type from `Int` to `String`** - Matches `uuid` type

### Server Model Additional Fix

The Server model also required fixing the proxy field:

**Before:**
```swift
let proxyType: String?

enum CodingKeys: String, CodingKey {
    case proxyType = "proxy_type"
}
```

**After:**
```swift
let proxy: ServerProxy?

enum CodingKeys: String, CodingKey {
    case proxy
}

// New nested struct
struct ServerProxy: Codable, Hashable {
    let redirectEnabled: Bool?

    enum CodingKeys: String, CodingKey {
        case redirectEnabled = "redirect_enabled"
    }
}
```

### Deployment Model Variation

The Deployment model uses `deploymentUuid` instead of `uuid`:

```swift
struct Deployment: Identifiable, Codable, Hashable {
    let deploymentUuid: String

    // Use deploymentUuid as Identifiable id
    var id: String { deploymentUuid }

    enum CodingKeys: String, CodingKey {
        case deploymentUuid = "deployment_uuid"
        // 'id' not included
    }
}
```

## Files Modified

| File | Changes |
|------|---------|
| `coolify/Features/Servers/Server.swift` | Changed `let id: Int` to `var id: String { uuid }`, removed `id` from CodingKeys, changed `proxyType: String?` to `proxy: ServerProxy?`, added `ServerProxy` struct, updated `ServerSettings` fields |
| `coolify/Features/Applications/Application.swift` | Changed `let id: Int` to `var id: String { uuid }`, removed `id` from CodingKeys |
| `coolify/Features/Databases/Database.swift` | Changed `let id: Int` to `var id: String { uuid }`, removed `id` from CodingKeys |
| `coolify/Features/Services/Service.swift` | Changed `let id: Int` to `var id: String { uuid }`, removed `id` from CodingKeys |
| `coolify/Features/Deployments/Deployment.swift` | Changed `let id: Int?` to `var id: String { deploymentUuid }`, removed `id` from CodingKeys |

Preview files also updated to remove `id:` parameter from mock initializers.

## Debugging Approach

The issue was diagnosed using the `NetworkLogger` class (enabled only in DEBUG builds) which logs the full JSON response body:

```swift
// NetworkLogger output showed:
[825D8B9F] --> GET https://coolify.example.com/api/v1/servers
[825D8B9F] <-- 200 (234ms)
[825D8B9F] Body: [
  {
    "uuid": "qw04wc0kssgo4s8ckkko4w0s",
    "name": "localhost",
    "ip": "host.docker.internal",
    "is_reachable": true,
    // No "id" field present!
  }
]
```

## Prevention Strategies

### 1. Always Validate Models Against Live API Responses

Never trust API documentation alone. Use NetworkLogger to capture actual API responses before implementing models.

### 2. Prefer `uuid` Over `id` for Primary Identifiers

The Coolify API consistently uses `uuid: String` as the primary identifier. Always use `uuid` for `Identifiable` conformance:

```swift
// Correct approach
struct Resource: Codable, Identifiable {
    let uuid: String
    var id: String { uuid }  // Computed property
}
```

### 3. Make Non-Critical Fields Optional

Any field that isn't absolutely required should be optional:

```swift
struct Application: Codable, Identifiable {
    let uuid: String       // Required
    let name: String       // Required
    let description: String?  // Optional - app works without it
    let gitBranch: String?    // Optional
}
```

### 4. Document API Field Sources

Add comments documenting where each field comes from and whether it's always present.

## Testing Recommendations

### Write Decoding Tests for Every Model

```swift
func testDecodesFromActualAPIResponse() throws {
    let json = """
    {
        "uuid": "abc123",
        "name": "Production Server",
        "ip": "192.168.1.1"
    }
    """.data(using: .utf8)!

    let server = try JSONDecoder().decode(Server.self, from: json)

    XCTAssertEqual(server.uuid, "abc123")
    XCTAssertEqual(server.id, "abc123")  // Computed from uuid
}

func testDecodesWithMissingOptionalFields() throws {
    let json = """
    { "uuid": "abc123", "name": "Minimal" }
    """.data(using: .utf8)!

    let server = try JSONDecoder().decode(Server.self, from: json)
    XCTAssertNil(server.description)
}
```

## Related Documentation

- [CLAUDE.md](../../../CLAUDE.md) - Project architecture guidelines
- [API-REFERENCE.md](../../../.claude/skills/coolify-api/API-REFERENCE.md) - Coolify API endpoint specifications
- [NetworkLogger.swift](../../../coolify/Shared/API/NetworkLogger.swift) - Debug logging for API responses

## Key Takeaway

When Swift Codable shows "The data couldn't be read because it is missing", it means a **non-optional field** in your model doesn't exist in the JSON. The fix is either:

1. Make the property optional (`let id: Int?`)
2. Remove the property entirely if not needed
3. Use a computed property for protocol conformance (`var id: String { uuid }`)
