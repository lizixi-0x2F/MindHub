import SwiftUI

struct DiaryEditorView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var journalViewModel: JournalViewModel
    @EnvironmentObject var appSettings: AppSettings
    
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var showEmojiPicker: Bool = false
    @State private var selectedEmoji: String? = "😊"
    @State private var tags: [String] = []
    @State private var currentTag: String = ""
    @State private var isFavorite: Bool = false
    @State private var showLocationInput = false
    @State private var location: String = ""
    
    // 编辑模式
    var editMode: Bool = false
    var existingEntry: JournalEntry? = nil
    
    // 常用标签
    private var commonTags: [String] {
        ["工作", "学习", "家庭", "朋友", "旅行", "爱好", "健康", "阅读", "电影", "音乐", "美食", "运动"]
    }
    
    var body: some View {
        ZStack {
            // 背景
            ThemeColors.base.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 导航栏
                customNavigationBar
                
                // 内容区域
                ScrollView {
                    VStack(spacing: 16) {
                        // 标题和表情选择
                        titleAndEmojiSection
                        
                        // Markdown编辑器
                        markdownEditorSection
                        
                        // 标签选择
                        tagsSection
                        
                        // 其他选项
                        optionsSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
                }
                .padding(.top, 16)
            }
            
            // Emoji选择器底部弹出
            if showEmojiPicker {
                emojiPickerOverlay
            }
        }
        .onAppear {
            // 如果是编辑模式，加载现有数据
            if let entry = existingEntry {
                title = entry.title
                content = entry.content
                selectedEmoji = entry.moodIconName
                tags = entry.tags
                isFavorite = entry.isFavorite
                if let loc = entry.location {
                    location = loc
                    showLocationInput = true
                }
            }
        }
    }
    
    // 自定义导航栏
    private var customNavigationBar: some View {
        HStack {
            // 返回按钮
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                    
                    Text("返回")
                        .font(.body.weight(.medium))
                }
                .foregroundColor(ThemeColors.accent)
                .padding(8)
            }
            
            Spacer()
            
            Text(editMode ? "编辑日记" : "新建日记")
                .font(.h2)
                .foregroundColor(ThemeColors.textPrimary)
            
            Spacer()
            
            // 保存按钮
            Button(action: saveEntry) {
                Text("保存")
                    .font(.body.weight(.medium))
                    .foregroundColor(ThemeColors.accent)
                    .padding(8)
            }
            .disabled(title.isEmpty || content.isEmpty)
            .opacity(title.isEmpty || content.isEmpty ? 0.5 : 1.0)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(ThemeColors.base)
    }
    
    // 标题和表情选择区域
    private var titleAndEmojiSection: some View {
        HStack(alignment: .top, spacing: 16) {
            // 表情选择按钮
            Button(action: {
                withAnimation(.mindHubStandard) {
                    showEmojiPicker.toggle()
                }
            }) {
                Text(selectedEmoji ?? "😐")
                    .font(.system(size: 48))
                    .frame(width: 70, height: 70)
                    .background(ThemeColors.surface1)
                    .cornerRadius(12)
            }
            
            // 标题输入
            VStack(alignment: .leading, spacing: 8) {
                Text("标题")
                    .font(.caption)
                    .foregroundColor(ThemeColors.textSecondary)
                
                TextField("给您的日记起个标题", text: $title)
                    .font(.bodyText)
                    .foregroundColor(ThemeColors.textPrimary)
                    .padding(12)
                    .background(ThemeColors.surface1)
                    .cornerRadius(12)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.bottom, 8)
    }
    
    // Markdown编辑器区域
    private var markdownEditorSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("内容")
                .font(.caption)
                .foregroundColor(ThemeColors.textSecondary)
            
            MarkdownEditor(text: $content)
                .frame(minHeight: 200)
        }
    }
    
    // 标签选择区域
    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("标签")
                .font(.caption)
                .foregroundColor(ThemeColors.textSecondary)
            
            // 标签输入
            HStack {
                TextField("添加标签", text: $currentTag)
                    .padding(12)
                    .background(ThemeColors.surface1)
                    .cornerRadius(12)
                
                Button(action: addTag) {
                    Text("添加")
                        .font(.body.weight(.medium))
                        .foregroundColor(ThemeColors.accent)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(ThemeColors.surface1)
                        .cornerRadius(12)
                }
                .disabled(currentTag.isEmpty)
            }
            
            // 常用标签
            VStack(alignment: .leading, spacing: 8) {
                Text("常用标签")
                    .font(.caption)
                    .foregroundColor(ThemeColors.textSecondary)
                
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
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        tags.contains(tag) ?
                                            ThemeColors.accent.opacity(0.2) :
                                            ThemeColors.surface1
                                    )
                                    .foregroundColor(
                                        tags.contains(tag) ?
                                            ThemeColors.accent :
                                            ThemeColors.textSecondary
                                    )
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
            }
            
            // 已选标签
            if !tags.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("已选标签")
                        .font(.caption)
                        .foregroundColor(ThemeColors.textSecondary)
                    
                    FlowLayout(spacing: 8) {
                        ForEach(tags, id: \.self) { tag in
                            TagView(tag: tag) {
                                if let index = tags.firstIndex(of: tag) {
                                    tags.remove(at: index)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // 其他选项区域
    private var optionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 位置
            VStack(alignment: .leading, spacing: 8) {
                Toggle("添加位置", isOn: $showLocationInput)
                    .foregroundColor(ThemeColors.textPrimary)
                    .toggleStyle(SwitchToggleStyle(tint: ThemeColors.accent))
                
                if showLocationInput {
                    TextField("输入位置", text: $location)
                        .padding(12)
                        .background(ThemeColors.surface1)
                        .cornerRadius(12)
                }
            }
            .padding(.vertical, 4)
            
            // 收藏
            Toggle("收藏此日记", isOn: $isFavorite)
                .foregroundColor(ThemeColors.textPrimary)
                .toggleStyle(SwitchToggleStyle(tint: ThemeColors.accent))
                .padding(.vertical, 4)
            
            // 情绪分析提示
            if appSettings.emotionAnalysisEnabled {
                HStack(spacing: 8) {
                    Image(systemName: "brain")
                        .foregroundColor(ThemeColors.accent)
                    
                    Text("情绪分析：将在保存后自动分析日记内容的情绪")
                        .font(.caption)
                        .foregroundColor(ThemeColors.textSecondary)
                }
                .padding(12)
                .background(ThemeColors.surface1)
                .cornerRadius(12)
            }
        }
    }
    
    // Emoji选择器覆盖层
    private var emojiPickerOverlay: some View {
        ZStack(alignment: .bottom) {
            // 半透明背景
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    withAnimation(.mindHubStandard) {
                        showEmojiPicker = false
                    }
                }
            
            // Emoji选择器
            EmojiPicker(selectedEmoji: $selectedEmoji)
                .transition(.move(edge: .bottom))
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
        if editMode, let existingId = existingEntry?.id {
            // 更新现有日记
            let updatedEntry = JournalEntry(
                id: existingId,
                title: title,
                content: content,
                date: existingEntry?.date ?? Date(),
                mood: .custom(icon: selectedEmoji ?? "😐"),
                tags: tags,
                isFavorite: isFavorite,
                location: showLocationInput ? location : nil
            )
            
            journalViewModel.updateEntry(updatedEntry)
        } else {
            // 创建新日记
            let newEntry = JournalEntry(
                title: title,
                content: content,
                date: Date(),
                mood: .custom(icon: selectedEmoji ?? "😐"),
                tags: tags,
                isFavorite: isFavorite,
                location: showLocationInput ? location : nil
            )
            
            journalViewModel.addEntry(newEntry)
        }
        
        presentationMode.wrappedValue.dismiss()
    }
}

// 与现有项目中的标签流布局一起使用
// 如果FlowLayout组件不存在，请创建或调整此代码
struct FlowLayout: Layout {
    var spacing: CGFloat
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? .infinity
        var height: CGFloat = 0
        let rows = arrangeSubviews(proposal: proposal, subviews: subviews)
        
        for row in rows {
            if let last = row.last {
                height += subviews[last].sizeThatFits(.unspecified).height
            }
        }
        
        return CGSize(width: width, height: height + CGFloat(rows.count - 1) * spacing)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = arrangeSubviews(proposal: proposal, subviews: subviews)
        
        var y = bounds.minY
        
        for row in rows {
            var x = bounds.minX
            
            for index in row {
                let subview = subviews[index]
                let size = subview.sizeThatFits(.unspecified)
                
                subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
                x += size.width + spacing
            }
            
            if let lastIndex = row.last {
                y += subviews[lastIndex].sizeThatFits(.unspecified).height + spacing
            }
        }
    }
    
    private func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> [[Int]] {
        let width = proposal.width ?? .infinity
        var currentRow: [Int] = []
        var currentRowWidth: CGFloat = 0
        var rows: [[Int]] = []
        
        for (index, subview) in subviews.enumerated() {
            let size = subview.sizeThatFits(.unspecified)
            
            if currentRowWidth + size.width > width && !currentRow.isEmpty {
                rows.append(currentRow)
                currentRow = []
                currentRowWidth = 0
            }
            
            currentRow.append(index)
            currentRowWidth += size.width + (currentRow.count > 1 ? spacing : 0)
        }
        
        if !currentRow.isEmpty {
            rows.append(currentRow)
        }
        
        return rows
    }
}

// 预览
struct DiaryEditorView_Previews: PreviewProvider {
    static var previews: some View {
        DiaryEditorView()
            .environmentObject(JournalViewModel())
            .environmentObject(AppSettings())
            .preferredColorScheme(.dark)
    }
} 