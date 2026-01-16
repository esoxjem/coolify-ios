# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Coolify iOS is a native iOS app for managing [Coolify](https://coolify.io) self-hosted instances. It connects to the Coolify REST API to monitor and control servers, applications, databases, services, and deployments.

## Build and Test Commands

**Always use the `/xcode-test` skill to build and test the app.** This skill handles simulator setup, build configuration, and test execution automatically.



## Architecture

### State Management Pattern
- Uses Swift's `@Observable` macro (iOS 17+) instead of ObservableObject/Combine
- `AppState` is the root observable injected via SwiftUI's `.environment()` modifier
- Each feature has its own `@Observable` ViewModel (e.g., `ApplicationsViewModel`, `ServersViewModel`)
- ViewModels receive a `CoolifyInstance` via `setInstance()` to create their API client

### Data Flow
```
AppState (global auth/instance state)
    ↓
MainTabView → Feature Views
    ↓
FeatureViewModel.setInstance(currentInstance)
    ↓
CoolifyAPIClient (actor) → Coolify REST API
```

### Key Architectural Decisions

**CoolifyAPIClient as Actor**: The API client is an `actor` for thread-safe concurrent API calls. Each ViewModel creates its own client instance.

**Multi-Instance Support**: Users can configure multiple Coolify instances. `KeychainManager` persists instances securely, with one marked as "current".

**Tab-Based Navigation**: Uses iOS 18's Tab API for a standard iPhone tab bar interface.

## Directory Structure

```
coolify/
├── App/           # App entry point, ContentView, MainTabView
├── Core/          # AppState, CoolifyInstance, KeychainManager, Theme
├── Features/      # Feature modules (each has Model, View, ViewModel)
│   ├── Applications/
│   ├── Databases/
│   ├── Deployments/
│   ├── Onboarding/
│   ├── Servers/
│   ├── Services/
│   └── Settings/
├── Shared/
│   ├── API/       # CoolifyAPIClient
│   └── Components/ # Reusable UI components
└── Resources/     # Assets
```

## Coolify API

The app communicates with Coolify's REST API (v1). Key patterns:

- **Base URL**: `{instance.baseURL}/api/v1`
- **Auth**: Bearer token in Authorization header
- **Endpoints**: `/servers`, `/applications`, `/databases`, `/services`, `/deployments`, `/projects`, `/teams`
- **Actions**: Resources support `/start`, `/stop`, `/restart` endpoints

API models use snake_case CodingKeys to match the JSON response format.

## Theme System

Custom Coolify brand colors defined in `Theme.swift`:
- Primary: `.coolifyPurple` (#6B16ED)
- Status colors: `.coolifySuccess`, `.coolifyError`, `.coolifyWarning`
- Resource colors: `.coolifyServer`, `.coolifyApplication`, `.coolifyDatabase`, etc.
- MeshGradient helpers for feature-specific backgrounds
