# Spotify Mood Matcher

An iOS app that generates personalized Spotify playlists based on your mood or activity using AI.

## Features

- Mood/Activity input via text and emoji selection
- AI-powered playlist generation
- Direct Spotify integration for playback
- Playlist saving and rating
- History tracking
- Similar playlist suggestions

## Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+
- Spotify Developer Account
- OpenAI API Key (for AI playlist generation)

## Setup

1. Clone the repository
2. Open `SpotifyMoodMatcher.xcodeproj` in Xcode
3. Install dependencies using Swift Package Manager
4. Configure your Spotify API credentials in `Config.swift`
5. Configure your OpenAI API key in `Config.swift`
6. Build and run the project

## Dependencies

- Spotify iOS SDK
- OpenAI API Client
- SwiftUI
- Combine

## Architecture

The app follows the MVVM (Model-View-ViewModel) architecture pattern:

- **Views**: SwiftUI views for the user interface
- **ViewModels**: Business logic and state management
- **Models**: Data models and entities
- **Services**: API clients and business services
- **Utils**: Helper functions and extensions
