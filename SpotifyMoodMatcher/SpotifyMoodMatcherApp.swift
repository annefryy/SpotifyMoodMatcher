import SwiftUI

@main
struct SpotifyMoodMatcherApp: App {
    @StateObject private var spotifyAuthManager = SpotifyAuthManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(spotifyAuthManager)
        }
    }
} 