# Privacy Policy for Coolify iOS

**Last Updated: January 18, 2026**

## Introduction

Coolify iOS ("the App") is an open-source mobile application that allows you to manage your self-hosted [Coolify](https://coolify.io) instances. This privacy policy explains how the App handles your information.

**The key principle**: Coolify iOS is designed with privacy at its core. The App does not collect, track, or transmit any data to us or any third parties. All data stays on your device and your own self-hosted Coolify server.

## Information We Collect

### Information You Provide

When you add a Coolify instance to the App, you provide:

- **Instance URL**: The web address of your self-hosted Coolify server
- **API Token**: Your Coolify API authentication token
- **Instance Name**: A friendly name you choose to identify your instance

This information is stored **locally on your device only** and is used solely to connect to your Coolify server.

### Information We Do NOT Collect

The App does **not** collect:

- Analytics or usage data
- Crash reports or diagnostics
- Device identifiers (IDFA, IDFV, etc.)
- Location data
- Contacts or personal information
- Browsing history
- Any form of telemetry

## How We Use Information

The information you provide is used exclusively to:

1. **Authenticate** with your self-hosted Coolify instance
2. **Display** your servers, applications, databases, and services
3. **Execute** management actions (start, stop, restart) on your resources

All data fetched from your Coolify server (server status, application logs, deployment history, etc.) is held in memory only and is not persisted to disk.

## Data Storage & Security

### Local Storage

Your Coolify instance credentials are stored securely using:

- **iOS Keychain**: Apple's hardware-backed secure enclave
- **Device-only encryption**: Data is encrypted at rest and protected by your device passcode/biometrics
- **No cloud sync**: Keychain data is not synced to iCloud

### Network Security

- All communication with your Coolify server uses **HTTPS** encryption
- API tokens are transmitted via secure **Bearer authentication** headers
- The App validates SSL/TLS certificates

## Third-Party Services

**The App connects to no third-party services.**

The only network connections made by the App are to your own self-hosted Coolify server(s). We do not use:

- Analytics services (Google Analytics, Mixpanel, etc.)
- Crash reporting services (Crashlytics, Sentry, etc.)
- Advertising networks
- Social media SDKs
- Any external APIs

## Data Sharing

**We do not share any data with anyone.**

Since we don't collect any data, there is nothing to share. Your Coolify credentials and server data never leave your device except to communicate directly with your own Coolify server.

## Your Rights & Data Control

You have complete control over your data:

- **View**: All stored instances are visible in the App's settings
- **Delete**: Remove any instance at any time, which immediately deletes its credentials from Keychain
- **Delete All**: Logging out or deleting the App removes all stored data
- **Audit**: The App is [open source](https://github.com/ArunSasiworksolutions/coolify-ios)—you can verify exactly what data is stored and transmitted

## Children's Privacy

Coolify iOS is not designed for or directed at children under 13. The App is a technical tool for managing server infrastructure and requires access to a self-hosted Coolify instance.

## Changes to This Policy

If we make changes to this privacy policy, we will:

1. Update the "Last Updated" date at the top of this document
2. Include a summary of changes in the App's release notes
3. For significant changes, display an in-app notification

## Open Source Transparency

Coolify iOS is open source. You can:

- Review the complete source code
- Verify our privacy claims by examining the codebase
- See exactly what data is stored and how it's transmitted
- Contribute improvements or report concerns

## Contact

If you have questions about this privacy policy or the App's data practices:

- **GitHub Issues**: [Report an issue or ask a question](https://github.com/ArunSasiworksolutions/coolify-ios/issues)

---

## Summary

| Category | What We Do |
|----------|------------|
| Data Collection | None—zero analytics, zero telemetry |
| Data Storage | Device-only, Keychain-encrypted credentials |
| Data Transmission | Only to your own Coolify server |
| Third Parties | None—no SDKs, no external services |
| Data Sharing | None—we have no data to share |
| Your Control | Full—delete anytime, audit the code |

**Your data is yours. We don't want it, we don't collect it, and we've designed the App so we never see it.**
