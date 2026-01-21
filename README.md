# Ciel - Coolify Client

A minimal iOS client for managing your Coolify instances.

<p><b>Join Beta</b> - https://testflight.apple.com/join/Pb6DwcqP</p>

> **Disclaimer**: Ciel is an unofficial third-party client. It is not affiliated with, endorsed by, or connected to Coolify or coolLabs in any way. Coolify is open-source software licensed under [Apache 2.0](https://github.com/coollabsio/coolify/blob/v4.x/LICENSE).

## Screenshots

<p>
  <img src="docs/screenshots/dashboard.png" width="180" />
  <img src="docs/screenshots/deployments.png" width="180" />
  <img src="docs/screenshots/deployment-detail.png" width="180" />
  <img src="docs/screenshots/settings.png" width="180" />
</p>

## What is Coolify?

[Coolify](https://coolify.io) is an open-source, self-hostable alternative to platforms like Heroku, Netlify, and Vercel. It lets you deploy applications, databases, and services on your own servers with just a few clicks.

Ciel gives you the power to monitor and manage your Coolify instance right from your iPhone.

## Getting Started

### Prerequisites
- An iPhone running iOS 26.0 or later
- A running Coolify instance (v4 or later)
- An API token from your Coolify instance

### How to Connect

1. **Get your API Token**
   - Log into your Coolify web dashboard
   - Go to **Settings** → **API Tokens**
   - Create a new token with appropriate permissions
   - Copy the token (you'll only see it once!)

2. **Add Your Instance**
   - Open Ciel
   - Tap **Get Started** (or **Try Demo Mode** to explore first)
   - Enter a name for your instance (e.g., "Production Server")
   - Enter your Coolify URL (e.g., `https://coolify.example.com`)
   - Paste your API token
   - Tap **Connect**

3. **Start Managing!**
   - Once connected, you'll see your Dashboard
   - Use the tab bar to navigate between features
   - Pull down on any screen to refresh data

## Demo Mode

Ciel includes a demo mode that lets you explore the app without connecting to a real Coolify instance:

1. Launch the app
2. On the onboarding screen, tap **Try Demo Mode**
3. Explore the dashboard, deployments, and settings with sample data

Demo mode uses static sample data and does not connect to any server.

## Settings & Preferences

Access Settings from the tab bar to:
- View your current connected instance
- Switch between multiple instances
- Add new Coolify instances
- Set auto-refresh intervals (15s, 30s, 1min, 5min)
- Access Coolify documentation
- Sign out and remove all stored credentials

## Security

- All API tokens are stored securely in the iOS Keychain
- Connections to your Coolify instance use HTTPS
- No data is stored on external servers—the app connects directly to your instance

## Requirements

| Requirement | Version |
|-------------|---------|
| iOS | 26.0+ |
| Coolify | v4+ |

## Support

### Getting Help

If you need assistance with Ciel:

1. **Check the FAQ below** for common questions
2. **Search existing issues** on [GitHub Issues](https://github.com/esoxjem/coolify-ios/issues)
3. **Open a new issue** if your problem isn't already reported

### FAQ

**Q: Why can't I connect to my Coolify instance?**
A: Ensure your Coolify URL is correct (including `https://`), your API token is valid, and your server is accessible from your network. Self-signed certificates may cause connection issues.

**Q: How do I get a Coolify API token?**
A: Log into your Coolify web dashboard, go to Settings → API Tokens, create a new token, and copy it immediately (it's only shown once).

**Q: Does the app work offline?**
A: No. Ciel requires an active connection to your Coolify instance to display data and perform actions.

**Q: How do I manage multiple Coolify instances?**
A: Go to Settings, tap "Add Instance", and configure additional instances. You can switch between them by tapping on an instance in the list.

**Q: Is my data secure?**
A: Yes. API tokens are stored in the iOS Keychain (hardware-encrypted). The app connects directly to your server—no data passes through external servers.

### Contact

- **GitHub Issues**: [Report bugs or request features](https://github.com/esoxjem/coolify-ios/issues)
- **Developer**: [@ES0XJEM on X](https://x.com/ES0XJEM)

### Coolify Resources

For help with Coolify itself (not this app):
- **Coolify Documentation**: [coolify.io/docs](https://coolify.io/docs)
- **Coolify GitHub**: [github.com/coollabsio/coolify](https://github.com/coollabsio/coolify)
- **Coolify Discord**: [Join the community](https://discord.com/invite/coollabs-459365938081431553)

## License

This project is open source. See the LICENSE file for details.
