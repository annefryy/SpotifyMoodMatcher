import SwiftUI

struct EmojiPickerView: View {
    @Binding var selectedEmoji: String?
    @Environment(\.dismiss) private var dismiss
    
    private let moodEmojis = [
        "😊", "😌", "😴", "😢", "😡",
        "😎", "🥳", "😍", "😔", "😤",
        "🎵", "🎸", "🎹", "🎻", "🎤",
        "💃", "🕺", "🎧", "🎼", "🎶"
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 60))
                ], spacing: 20) {
                    ForEach(moodEmojis, id: \.self) { emoji in
                        Button(action: {
                            selectedEmoji = emoji
                            dismiss()
                        }) {
                            Text(emoji)
                                .font(.system(size: 40))
                                .frame(width: 60, height: 60)
                                .background(
                                    RoundedRectangle(cornerRadius: Config.cornerRadius)
                                        .fill(Color(.systemBackground))
                                        .shadow(radius: 2)
                                )
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Select Mood")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    EmojiPickerView(selectedEmoji: .constant(nil))
} 