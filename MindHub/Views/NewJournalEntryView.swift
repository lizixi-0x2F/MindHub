import SwiftUI

struct NewJournalEntryView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var tags: [String] = []
    @State private var currentTag: String = ""
    @State private var isFavorite: Bool = false
    @State private var location: String = ""
    @State private var showLocationInput = false
    
    var onSave: (JournalEntry) -> Void
    
    // 常用标签
    private var commonTags: [String] {
        ["工作", "学习", "家庭", "朋友", "旅行", "爱好", "健康", "阅读", "电影", "音乐", "美食", "运动"]
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // 莫奈风格的深蓝色背景
                ThemeColors.background.edgesIgnoringSafeArea(.all)
                
                Form {
                    // 标题
                    Section(header: Text("标题")) {
                        TextField("给您的日记起个标题", text: $title)
                    }
                    
                    // 内容
                    Section(header: Text("内容")) {
                        TextEditor(text: $content)
                            .frame(minHeight: 200)
                    }
                    
                    // 标签
                    Section(header: Text("标签")) {
                        HStack {
                            TextField("添加标签", text: $currentTag)
                            
                            Button(action: addTag) {
                                Text("添加")
                                    .foregroundColor(ThemeColors.accent)
                            }
                            .disabled(currentTag.isEmpty)
                        }
                        
                        // 常用标签选择
                        VStack(alignment: .leading) {
                            Text("常用标签")
                                .font(.caption)
                                .foregroundColor(ThemeColors.secondaryText)
                                .padding(.vertical, 4)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(commonTags, id: \.self) { tag in
                                        Button(action: {
                                            if !tags.contains(tag) {
                                                tags.append(tag)
                                            }
                                        }) {
                                            Text(tag)
                                                .font(.caption)
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 5)
                                                .background(tags.contains(tag) ? ThemeColors.accent : Color.gray.opacity(0.2))
                                                .foregroundColor(tags.contains(tag) ? .white : .primary)
                                                .cornerRadius(8)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 4)
                        
                        if !tags.isEmpty {
                            Text("已选标签")
                                .font(.caption)
                                .foregroundColor(ThemeColors.secondaryText)
                                .padding(.top, 8)
                                .padding(.bottom, 4)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(tags, id: \.self) { tag in
                                        TagView(tag: tag) {
                                            if let index = tags.firstIndex(of: tag) {
                                                tags.remove(at: index)
                                            }
                                        }
                                    }
                                }
                            }
                            .frame(height: 35)
                        }
                    }
                    
                    // 位置
                    Section(header: Text("位置")) {
                        Toggle("添加位置", isOn: $showLocationInput)
                        
                        if showLocationInput {
                            TextField("输入位置", text: $location)
                        }
                    }
                    
                    // 其他选项
                    Section {
                        Toggle("收藏此日记", isOn: $isFavorite)
                        
                        Text("情绪分析：将在保存后自动分析日记内容的情绪")
                            .font(.caption)
                            .foregroundColor(ThemeColors.secondaryText)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("新建日记")
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
    
    // 添加标签
    private func addTag() {
        let trimmedTag = currentTag.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedTag.isEmpty && !tags.contains(trimmedTag) {
            tags.append(trimmedTag)
            currentTag = ""
        }
    }
    
    // 保存日记
    private func saveEntry() {
        // 通过Apple NLP分析模型推断情绪 (暂时使用默认值，实际应该由服务分析)
        let newEntry = JournalEntry(
            title: title,
            content: content,
            date: Date(),
            mood: .neutral, // 将默认使用neutral，之后会由情感分析服务更新
            tags: tags,
            isFavorite: isFavorite,
            location: showLocationInput ? location : nil
        )
        
        onSave(newEntry)
        presentationMode.wrappedValue.dismiss()
    }
}

// 标签视图
struct TagView: View {
    let tag: String
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(tag)
                .font(.subheadline)
                .foregroundColor(.white)
            
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(ThemeColors.accent.opacity(0.8))
        .cornerRadius(12)
    }
}

struct NewJournalEntryView_Previews: PreviewProvider {
    static var previews: some View {
        NewJournalEntryView() { _ in }
    }
} 