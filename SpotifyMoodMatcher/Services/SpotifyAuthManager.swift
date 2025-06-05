import Foundation
import Combine

class SpotifyAuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var accessToken: String?
    @Published var refreshToken: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadTokens()
    }
    
    func authenticate() {
        let scope = "playlist-modify-public playlist-modify-private user-read-private"
        let authURL = "\(Config.spotifyAuthURL)?client_id=\(Config.spotifyClientId)&response_type=code&redirect_uri=\(Config.spotifyRedirectURI)&scope=\(scope)"
        
        if let url = URL(string: authURL) {
            UIApplication.shared.open(url)
        }
    }
    
    func handleCallback(url: URL) {
        guard let code = url.queryParameters?["code"] else { return }
        
        Task {
            do {
                let tokens = try await exchangeCodeForTokens(code: code)
                await MainActor.run {
                    self.accessToken = tokens.accessToken
                    self.refreshToken = tokens.refreshToken
                    self.isAuthenticated = true
                    self.saveTokens()
                }
            } catch {
                print("Error exchanging code for tokens: \(error)")
            }
        }
    }
    
    private func exchangeCodeForTokens(code: String) async throws -> (accessToken: String, refreshToken: String) {
        var request = URLRequest(url: URL(string: Config.spotifyTokenURL)!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let parameters = [
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": Config.spotifyRedirectURI,
            "client_id": Config.spotifyClientId,
            "client_secret": Config.spotifyClientSecret
        ]
        
        request.httpBody = parameters
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .data(using: .utf8)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(SpotifyTokenResponse.self, from: data)
        
        return (response.accessToken, response.refreshToken)
    }
    
    private func loadTokens() {
        accessToken = UserDefaults.standard.string(forKey: "spotifyAccessToken")
        refreshToken = UserDefaults.standard.string(forKey: "spotifyRefreshToken")
        isAuthenticated = accessToken != nil
    }
    
    private func saveTokens() {
        UserDefaults.standard.set(accessToken, forKey: "spotifyAccessToken")
        UserDefaults.standard.set(refreshToken, forKey: "spotifyRefreshToken")
    }
}

// MARK: - Helper Extensions
extension URL {
    var queryParameters: [String: String]? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems else { return nil }
        
        var parameters = [String: String]()
        for item in queryItems {
            parameters[item.name] = item.value
        }
        
        return parameters
    }
}

// MARK: - Response Models
struct SpotifyTokenResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
    }
} 