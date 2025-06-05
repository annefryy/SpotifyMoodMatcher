import Foundation

enum Config {
    // MARK: - API Keys
    static let spotifyClientId = "YOUR_SPOTIFY_CLIENT_ID"
    static let spotifyClientSecret = "YOUR_SPOTIFY_CLIENT_SECRET"
    static let openAIApiKey = "YOUR_OPENAI_API_KEY"
    
    // MARK: - URLs
    static let spotifyRedirectURI = "spotifymoodmatcher://callback"
    static let spotifyAuthURL = "https://accounts.spotify.com/authorize"
    static let spotifyTokenURL = "https://accounts.spotify.com/api/token"
    
    // MARK: - App Settings
    static let maxMoodInputLength = 50
    static let minPlaylistSongs = 10
    static let maxSimilarPlaylists = 3
    
    // MARK: - UI Constants
    static let cornerRadius: CGFloat = 12
    static let padding: CGFloat = 16
    static let animationDuration: Double = 0.3
} 