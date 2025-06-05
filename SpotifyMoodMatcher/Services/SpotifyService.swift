import Foundation

class SpotifyService {
    private let baseURL = "https://api.spotify.com/v1"
    
    func createPlaylist(name: String, description: String) async throws -> Playlist {
        guard let accessToken = SpotifyAuthManager().accessToken else {
            throw SpotifyError.notAuthenticated
        }
        
        // First, get the user's ID
        let userProfile = try await getUserProfile(accessToken: accessToken)
        
        // Create the playlist
        var request = URLRequest(url: URL(string: "\(baseURL)/users/\(userProfile.id)/playlists")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let playlistData = CreatePlaylistRequest(name: name, description: description)
        request.httpBody = try JSONEncoder().encode(playlistData)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(Playlist.self, from: data)
    }
    
    func addTracksToPlaylist(playlistId: String, trackUris: [String]) async throws {
        guard let accessToken = SpotifyAuthManager().accessToken else {
            throw SpotifyError.notAuthenticated
        }
        
        var request = URLRequest(url: URL(string: "\(baseURL)/playlists/\(playlistId)/tracks")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let trackData = AddTracksRequest(uris: trackUris)
        request.httpBody = try JSONEncoder().encode(trackData)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw SpotifyError.requestFailed
        }
    }
    
    private func getUserProfile(accessToken: String) async throws -> UserProfile {
        var request = URLRequest(url: URL(string: "\(baseURL)/me")!)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(UserProfile.self, from: data)
    }
}

// MARK: - Models
struct UserProfile: Codable {
    let id: String
    let displayName: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case displayName = "display_name"
    }
}

struct Playlist: Codable {
    let id: String
    let name: String
    let description: String
    let tracks: TrackCollection
    
    struct TrackCollection: Codable {
        let items: [TrackItem]
    }
    
    struct TrackItem: Codable {
        let track: Track
    }
    
    struct Track: Codable {
        let id: String
        let name: String
        let artists: [Artist]
        let uri: String
    }
    
    struct Artist: Codable {
        let id: String
        let name: String
    }
}

// MARK: - Request Models
struct CreatePlaylistRequest: Codable {
    let name: String
    let description: String
    let `public`: Bool = false
}

struct AddTracksRequest: Codable {
    let uris: [String]
}

// MARK: - Errors
enum SpotifyError: Error {
    case notAuthenticated
    case requestFailed
    case invalidResponse
} 