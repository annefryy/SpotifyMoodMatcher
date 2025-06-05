import Foundation
import Combine

class MoodInputViewModel: ObservableObject {
    @Published var moodInput = ""
    @Published var selectedEmoji: String?
    @Published var moodHistory: [String] = []
    @Published var showError = false
    @Published var errorMessage = ""
    
    private var cancellables = Set<AnyCancellable>()
    private let spotifyService: SpotifyService
    private let openAIService: OpenAIService
    
    init(spotifyService: SpotifyService = SpotifyService(),
         openAIService: OpenAIService = OpenAIService()) {
        self.spotifyService = spotifyService
        self.openAIService = openAIService
        loadMoodHistory()
    }
    
    func generatePlaylist() {
        guard !moodInput.isEmpty else { return }
        
        // Save to history
        if !moodHistory.contains(moodInput) {
            moodHistory.insert(moodInput, at: 0)
            if moodHistory.count > 10 {
                moodHistory.removeLast()
            }
            saveMoodHistory()
        }
        
        // Generate playlist using AI
        Task {
            do {
                let playlistDescription = try await openAIService.generatePlaylistDescription(
                    mood: moodInput,
                    emoji: selectedEmoji
                )
                
                let playlist = try await spotifyService.createPlaylist(
                    name: "Mood: \(moodInput)",
                    description: playlistDescription
                )
                
                // Update UI on main thread
                await MainActor.run {
                    // Handle successful playlist creation
                }
            } catch {
                await MainActor.run {
                    showError = true
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func loadMoodHistory() {
        if let savedHistory = UserDefaults.standard.stringArray(forKey: "moodHistory") {
            moodHistory = savedHistory
        }
    }
    
    private func saveMoodHistory() {
        UserDefaults.standard.set(moodHistory, forKey: "moodHistory")
    }
} 