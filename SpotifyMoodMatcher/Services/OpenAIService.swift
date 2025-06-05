import Foundation

class OpenAIService {
    private let baseURL = "https://api.openai.com/v1"
    
    func generatePlaylistDescription(mood: String, emoji: String?) async throws -> String {
        var request = URLRequest(url: URL(string: "\(baseURL)/chat/completions")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(Config.openAIApiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let prompt = """
        Generate a playlist description for a Spotify playlist based on the following mood and emoji:
        Mood: \(mood)
        Emoji: \(emoji ?? "none")
        
        The description should be concise (max 100 characters) and capture the emotional essence of the playlist.
        Include relevant genres and musical characteristics that would match this mood.
        """
        
        let requestBody = ChatCompletionRequest(
            model: "gpt-3.5-turbo",
            messages: [
                Message(role: "system", content: "You are a music expert who creates engaging playlist descriptions."),
                Message(role: "user", content: prompt)
            ],
            maxTokens: 150
        )
        
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(ChatCompletionResponse.self, from: data)
        
        guard let description = response.choices.first?.message.content else {
            throw OpenAIError.invalidResponse
        }
        
        return description
    }
    
    func generateTrackSuggestions(mood: String, emoji: String?) async throws -> [String] {
        var request = URLRequest(url: URL(string: "\(baseURL)/chat/completions")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(Config.openAIApiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let prompt = """
        Generate a list of 10 song titles and artists that would match the following mood and emoji:
        Mood: \(mood)
        Emoji: \(emoji ?? "none")
        
        Format each suggestion as: "Song Title - Artist"
        Return only the list, one song per line.
        """
        
        let requestBody = ChatCompletionRequest(
            model: "gpt-3.5-turbo",
            messages: [
                Message(role: "system", content: "You are a music expert who creates perfect playlists."),
                Message(role: "user", content: prompt)
            ],
            maxTokens: 300
        )
        
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(ChatCompletionResponse.self, from: data)
        
        guard let suggestions = response.choices.first?.message.content else {
            throw OpenAIError.invalidResponse
        }
        
        return suggestions.components(separatedBy: .newlines)
            .filter { !$0.isEmpty }
    }
}

// MARK: - Request Models
struct ChatCompletionRequest: Codable {
    let model: String
    let messages: [Message]
    let maxTokens: Int
    
    enum CodingKeys: String, CodingKey {
        case model
        case messages
        case maxTokens = "max_tokens"
    }
}

struct Message: Codable {
    let role: String
    let content: String
}

// MARK: - Response Models
struct ChatCompletionResponse: Codable {
    let choices: [Choice]
    
    struct Choice: Codable {
        let message: Message
    }
}

// MARK: - Errors
enum OpenAIError: Error {
    case invalidResponse
    case requestFailed
} 