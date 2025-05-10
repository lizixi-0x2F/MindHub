import SwiftUI

struct JournalDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var journalViewModel: JournalViewModel
    
    @State private var entry: JournalEntry
    @State private var isEditing = false
    @State private var showingEmotionView = false
    
    init(entry: JournalEntry) {
        _entry = State(initialValue: entry)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // 标题和日期
                HStack {
                    Text(entry.title)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button(action: {
                        journalViewModel.toggleFavorite(for: entry.id)
                        entry.isFavorite.toggle()
                    }) {
                        Image(systemName: entry.isFavorite ? "star.fill" : "star")
                            .foregroundColor(entry.isFavorite ? .yellow : .gray)
                    }
                }
                
                Text(formattedDate)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // 心情
                HStack {
                    Text("心情:")
                        .font(.headline)
                    
                    Text(entry.mood.icon)
                        .font(.title2)
                    
                    Text(entry.mood.rawValue)
                        .font(.body)
                        .foregroundColor(entry.mood.color)
                }
                
                Divider()
                
                // 内容
                Text(entry.content)
                    .font(.body)
                    .padding(.vertical, 8)
                
                // 标签
                if !entry.tags.isEmpty {
                    HStack {
                        Text("标签:")
                            .font(.headline)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(entry.tags, id: \.self) { tag in
                                    Text("#\(tag)")
                                        .font(.subheadline)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(Color.blue.opacity(0.2))
                                        .cornerRadius(10)
                                }
                            }
                        }
                    }
                }
                
                Divider()
                
                // 情感分析结果
                VStack(alignment: .leading) {
                    HStack {
                        Text("情感分析")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button(action: {
                            showingEmotionView = true
                        }) {
                            Text("查看详情")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    if let results = entry.emotionAnalysisResults, !results.isEmpty {
                        // 显示前三个情感分析结果
                        ForEach(results.prefix(3)) { result in
                            HStack {
                                Text(result.emotion)
                                    .font(.subheadline)
                                
                                Spacer()
                                
                                Text(String(format: "%.1f%%", result.score * 100))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    } else {
                        Text("尚未进行情感分析")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 4)
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationBarTitle("", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    isEditing = true
                }) {
                    Text("编辑")
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            EditJournalEntryView(entry: $entry) { updatedEntry in
                // 更新日记
                journalViewModel.updateEntry(updatedEntry)
                isEditing = false
            }
        }
        .sheet(isPresented: $showingEmotionView) {
            EmotionDetailView(emotionResults: entry.emotionAnalysisResults ?? [])
        }
    }
    
    // 格式化日期
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: entry.date)
    }
}

// 情感详情视图
struct EmotionDetailView: View {
    let emotionResults: [EmotionAnalysisResult]
    
    var body: some View {
        NavigationView {
            List {
                if emotionResults.isEmpty {
                    Text("尚未进行情感分析")
                        .font(.body)
                        .foregroundColor(.secondary)
                } else {
                    ForEach(emotionResults) { result in
                        HStack {
                            Text(result.emotion)
                                .font(.headline)
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text(String(format: "%.1f%%", result.score * 100))
                                    .font(.subheadline)
                                
                                ProgressView(value: result.score)
                                    .frame(width: 100)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("情感分析结果")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// 编辑日记视图
struct EditJournalEntryView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var entry: JournalEntry
    
    @State private var title: String
    @State private var content: String
    @State private var mood: Mood
    @State private var tags: String
    @State private var isFavorite: Bool
    
    let onSave: (JournalEntry) -> Void
    
    init(entry: Binding<JournalEntry>, onSave: @escaping (JournalEntry) -> Void) {
        self._entry = entry
        self._title = State(initialValue: entry.wrappedValue.title)
        self._content = State(initialValue: entry.wrappedValue.content)
        self._mood = State(initialValue: entry.wrappedValue.mood)
        self._tags = State(initialValue: entry.wrappedValue.tags.joined(separator: ", "))
        self._isFavorite = State(initialValue: entry.wrappedValue.isFavorite)
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("标题")) {
                    TextField("标题", text: $title)
                }
                
                Section(header: Text("内容")) {
                    TextEditor(text: $content)
                        .frame(minHeight: 150)
                }
                
                Section(header: Text("心情")) {
                    Picker("选择心情", selection: $mood) {
                        ForEach(Mood.allCases) { mood in
                            HStack {
                                Text(mood.icon)
                                Text(mood.rawValue)
                            }
                            .tag(mood)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section(header: Text("标签")) {
                    TextField("使用逗号分隔标签", text: $tags)
                }
                
                Section {
                    Toggle("收藏", isOn: $isFavorite)
                }
            }
            .navigationTitle("编辑日记")
            .navigationBarItems(
                leading: Button("取消") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("保存") {
                    // 更新日记
                    var updatedEntry = entry
                    updatedEntry.title = title
                    updatedEntry.content = content
                    updatedEntry.mood = mood
                    updatedEntry.tags = tags.split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) }
                    updatedEntry.isFavorite = isFavorite
                    
                    onSave(updatedEntry)
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

struct JournalDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleEntry = JournalEntry(
            title: "美好的一天",
            content: "今天天气很好，我早上去公园散步，感觉很放松。下午见了老朋友，我们一起喝咖啡聊天，分享了各自的近况。",
            date: Date(),
            mood: .happy,
            tags: ["散步", "朋友", "咖啡"],
            isFavorite: true
        )
        
        JournalDetailView(entry: sampleEntry)
    }
} 