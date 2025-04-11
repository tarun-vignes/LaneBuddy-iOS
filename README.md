# LaneBuddy iOS

A next-generation navigation app focused on lane-level guidance and enhanced driving experience.

## Features
- Real-time lane-level guidance
- Personalized preferred lane switching
- Visual and audio driving cues
- Parking garage interior visibility
- Future CarPlay support

## Setup Requirements
- Xcode 14.0+
- iOS 15.0+
- Swift 5.5+
- Apple Developer Account (free)
- Physical iOS device or Simulator

## Getting Started
1. Clone the repository
2. Open the project in Xcode
3. Select your development team in project settings
4. Build and run on a device or simulator

Note: Location services will only work on a physical device or in the iOS simulator with a simulated location.

## Project Structure
```
LaneBuddy-iOS/
├── Views/
│   ├── NavigationView.swift    - Main navigation interface
│   ├── SettingsView.swift      - App settings
│   └── TripHistoryView.swift   - Trip history display
├── LaneBuddyApp.swift         - Main app entry point
└── Package.swift              - Dependencies
```

## Development Status
- [x] Basic project setup
- [x] Mapbox integration
- [ ] Lane guidance implementation
- [ ] Preferred lane logic
- [ ] Garage mapping
- [ ] CarPlay integration
