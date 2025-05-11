import SwiftUI

// 编辑日记条目的视图
struct EditJournalEntryView: View {
    let entry: JournalEntry
    var onSave: (JournalEntry) -> Void
    
    @State private var title: String
    @State private var content: String
    @State private var mood: Mood
    @State private var isFavorite: Bool
    @State private var tags: [String]
    @State private var currentTag: String = ""
    @State private var location: String?
    @Environment(\.presentationMode) var presentationMode
    
    init(entry: JournalEntry, onSave: @escaping (JournalEntry) -> Void) {
        self.entry = entry
        self.onSave = onSave
        _title = State(initialValue: entry.title)
        _content = State(initialValue: entry.content)
        _mood = State(initialValue: entry.mood)
        _isFavorite = State(initialValue: entry.isFavorite)
        _tags = State(initialValue: entry.tags)
        _location = State(initialValue: entry.location)
    }
    
    var body: some View {
        NavigationView {
            EditJournalContent(
                title: $title,
                content: $content,
                mood: $mood,
                isFavorite: $isFavorite,
                tags: $tags,
                currentTag: $currentTag,
                location: $location,
                addTag: addTag,
                saveEntry: saveEntry,
                presentationMode: presentationMode
            )
            .navigationTitle("编辑日记")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveEntry()
                    }
                    .disabled(title.isEmpty || content.isEmpty)
                }
            }
        }
    }
    
    private func addTag() {
        let trimmedTag = currentTag.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedTag.isEmpty && !tags.contains(trimmedTag) {
            tags.append(trimmedTag)
            currentTag = ""
        }
    }
    
    private func saveEntry() {
        let updatedEntry = JournalEntry(
            id: entry.id,
            title: title,
            content: content,
            date: entry.date,
            mood: mood,
            tags: tags,
            isFavorite: isFavorite,
            location: location
        )
        onSave(updatedEntry)
        presentationMode.wrappedValue.dismiss()
    }
}

// 编辑日记内容组件
struct EditJournalContent: View {
    @Binding var title: String
    @Binding var content: String
    @Binding var mood: Mood
    @Binding var isFavorite: Bool
    @Binding var tags: [String]
    @Binding var currentTag: String
    @Binding var location: String?
    let addTag: () -> Void
    let saveEntry: () -> Void
    var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        ZStack {
            ThemeColors.background.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 16) {
                    // 标题输入
                    TitleInputField(title: $title)
                    
                    // 正文输入
                    ContentInputField(content: $content)
                    
                    // 心情选择
                    MoodSelectionField(mood: $mood)
                    
                    // 标签输入
                    TagsInputField(
                        tags: $tags,
                        currentTag: $currentTag,
                        addTag: addTag
                    )
                    
                    // 收藏切换
                    FavoriteToggle(isFavorite: $isFavorite)
                    
                    // 位置输入
                    LocationInputField(location: $location)
                }
                .padding()
            }
        }
    }
} 