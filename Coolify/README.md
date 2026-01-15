# Coolify iOS App

A native iOS application for managing your Coolify self-hosted PaaS instance from your iPhone or iPad.

## Features

- **Dashboard**: Overview of all servers, applications, databases, and services with quick stats
- **Server Management**: View server details, status, and all resources deployed on each server
- **Application Management**: Start, stop, restart, and deploy applications with swipe actions
- **Database Monitoring**: View database status and manage database lifecycle
- **Service Control**: Manage Docker Compose-based services
- **Deployment Tracking**: Monitor active and historical deployments with logs
- **Environment Variables**: View and manage application environment variables
- **Multi-Instance Support**: Connect to multiple Coolify instances
- **Secure Storage**: API tokens stored securely in iOS Keychain

## Requirements

- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+
- A Coolify instance (self-hosted or cloud)

## Installation

### From Source

1. Clone the repository:
```bash
git clone https://github.com/your-repo/coolify-ios.git
cd coolify-ios/Coolify
```

2. Open in Xcode:
```bash
open Coolify.xcodeproj
```

3. Select your development team in Signing & Capabilities

4. Build and run on your device or simulator

### Using XcodeGen (Optional)

If you prefer to regenerate the Xcode project:

```bash
brew install xcodegen
cd coolify-ios/Coolify
xcodegen generate
open Coolify.xcodeproj
```

## Configuration

### Getting Your API Token

1. Log in to your Coolify instance
2. Go to **Settings** > **Keys & Tokens** > **API tokens**
3. Click **Create New Token**
4. Give it a name and select permissions:
   - **Read-only**: View resources only
   - **Full access**: View and manage resources
5. Copy the token (it's only shown once!)

### Connecting the App

1. Open the Coolify iOS app
2. Tap **Get Started**
3. Enter:
   - **Instance Name**: A friendly name (e.g., "Production")
   - **Coolify URL**: Your instance URL (e.g., `https://coolify.example.com`)
   - **API Token**: The token you created
4. Tap **Connect**

## Project Structure

```
Coolify/
├── Sources/
│   ├── CoolifyApp.swift          # App entry point
│   ├── Core/
│   │   ├── AppState.swift        # Global app state
│   │   └── KeychainManager.swift # Secure token storage
│   ├── Models/
│   │   ├── Application.swift
│   │   ├── Database.swift
│   │   ├── Deployment.swift
│   │   ├── Server.swift
│   │   ├── Service.swift
│   │   └── ...
│   ├── API/
│   │   └── CoolifyAPIClient.swift # API client
│   ├── ViewModels/
│   │   ├── DashboardViewModel.swift
│   │   ├── ServersViewModel.swift
│   │   └── ...
│   └── Views/
│       ├── MainTabView.swift
│       ├── Onboarding/
│       ├── Dashboard/
│       ├── Servers/
│       ├── Applications/
│       ├── Databases/
│       ├── Services/
│       ├── Deployments/
│       └── Settings/
└── Resources/
    └── Assets.xcassets
```

## Architecture

- **SwiftUI**: Modern declarative UI framework
- **MVVM**: Model-View-ViewModel architecture
- **Swift Concurrency**: async/await for network operations
- **Keychain**: Secure storage for API tokens

## API Coverage

The app supports the following Coolify API endpoints:

| Category | Operations |
|----------|------------|
| Servers | List, details, validate, resources |
| Applications | List, CRUD, start/stop/restart, deploy, logs, env vars |
| Databases | List, details, start/stop/restart |
| Services | List, details, start/stop/restart |
| Deployments | List, details |
| Projects | List, details |
| Teams | List, current team |

## Screenshots

*Coming soon*

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

MIT License - see LICENSE file for details

## Acknowledgments

- [Coolify](https://coolify.io/) - The amazing self-hosted PaaS
- [Coolify API Documentation](https://coolify.io/docs/api-reference/api/)
