import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var spotifyAuthManager: SpotifyAuthManager
    @StateObject private var viewModel = MoodInputViewModel()
    @State private var showingEmojiPicker = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: Config.padding) {
                // Mood Input Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("How are you feeling?")
                        .font(.headline)
                    
                    HStack {
                        TextField("Enter your mood...", text: $viewModel.moodInput)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onChange(of: viewModel.moodInput) { newValue in
                                if newValue.count > Config.maxMoodInputLength {
                                    viewModel.moodInput = String(newValue.prefix(Config.maxMoodInputLength))
                                }
                            }
                        
                        Button(action: { showingEmojiPicker.toggle() }) {
                            Image(systemName: "face.smiling")
                                .font(.title2)
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(Config.cornerRadius)
                .shadow(radius: 2)
                
                // Generate Button
                Button(action: viewModel.generatePlaylist) {
                    HStack {
                        Image(systemName: "music.note.list")
                        Text("Generate Playlist")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(Config.cornerRadius)
                }
                .disabled(viewModel.moodInput.isEmpty)
                
                // History Section
                if !viewModel.moodHistory.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Recent Moods")
                            .font(.headline)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(viewModel.moodHistory, id: \.self) { mood in
                                    Button(action: { viewModel.moodInput = mood }) {
                                        Text(mood)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Color.blue.opacity(0.1))
                                            .cornerRadius(Config.cornerRadius)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Mood Matcher")
            .sheet(isPresented: $showingEmojiPicker) {
                EmojiPickerView(selectedEmoji: $viewModel.selectedEmoji)
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(SpotifyAuthManager())
} 