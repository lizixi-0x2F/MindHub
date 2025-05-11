import SwiftUI

/// Emoji选择器组件
struct EmojiPicker: View {
    @Binding var selectedEmoji: String?
    @State private var searchText: String = ""
    
    // Emoji分类
    private let categories = [
        ("笑脸", "😀", emojiRange(start: 0x1F600, end: 0x1F64F)),
        ("动物", "🐱", emojiRange(start: 0x1F400, end: 0x1F43F)),
        ("食物", "🍎", emojiRange(start: 0x1F345, end: 0x1F37F)),
        ("活动", "⚽️", emojiRange(start: 0x1F3BD, end: 0x1F3D3)),
        ("旅行", "🚗", emojiRange(start: 0x1F680, end: 0x1F6FF)),
        ("物品", "💡", emojiRange(start: 0x1F4A1, end: 0x1F4FF)),
        ("符号", "❤️", emojiRange(start: 0x2764, end: 0x27BF)),
        ("旗帜", "🏳️", emojiRange(start: 0x1F1E6, end: 0x1F1FF)),
    ]
    
    // 常用Emoji
    private let frequentlyUsed = ["😊", "👍", "❤️", "🎉", "🔥", "✨", "🙏", "😂", "🥰", "👏"]
    
    // 搜索结果
    private var filteredEmojis: [String] {
        if searchText.isEmpty {
            return []
        }
        
        let allEmojis = categories.flatMap { $0.2 }
        return allEmojis.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 拖动指示器
            HStack {
                Spacer()
                RoundedRectangle(cornerRadius: 2)
                    .fill(ThemeColors.surface2)
                    .frame(width: 40, height: 4)
                Spacer()
            }
            .padding(.top, 8)
            .padding(.bottom, 12)
            
            // 搜索栏
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(ThemeColors.textSecondary)
                
                TextField("搜索表情", text: $searchText)
                    .foregroundColor(ThemeColors.textPrimary)
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(ThemeColors.textSecondary)
                    }
                }
            }
            .padding(10)
            .background(ThemeColors.surface2)
            .cornerRadius(8)
            .padding(.horizontal, 16)
            
            // 常用表情
            if searchText.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("常用")
                        .font(.caption)
                        .foregroundColor(ThemeColors.textSecondary)
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 12) {
                        ForEach(frequentlyUsed, id: \.self) { emoji in
                            emojiButton(emoji)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            
            // 搜索结果
            if !searchText.isEmpty && !filteredEmojis.isEmpty {
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 12) {
                        ForEach(filteredEmojis, id: \.self) { emoji in
                            emojiButton(emoji)
                        }
                    }
                    .padding(16)
                }
            }
            
            // 分类表情
            else if searchText.isEmpty {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(categories, id: \.0) { category in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(category.1)
                                        .font(.title3)
                                    
                                    Text(category.0)
                                        .font(.caption)
                                        .foregroundColor(ThemeColors.textSecondary)
                                }
                                .padding(.horizontal, 16)
                                
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 12) {
                                    ForEach(category.2.prefix(24), id: \.self) { emoji in
                                        emojiButton(emoji)
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                            
                            Divider()
                                .background(ThemeColors.surface2)
                                .padding(.vertical, 4)
                        }
                    }
                    .padding(.bottom, 16)
                }
            }
            // 无搜索结果
            else {
                VStack {
                    Text("未找到表情")
                        .foregroundColor(ThemeColors.textSecondary)
                        .padding()
                    
                    Spacer()
                }
            }
        }
        .frame(height: 350)
        .background(ThemeColors.base)
    }
    
    // Emoji按钮
    private func emojiButton(_ emoji: String) -> some View {
        Button(action: {
            selectedEmoji = emoji
        }) {
            Text(emoji)
                .font(.system(size: 28))
                .frame(width: 44, height: 44)
                .background(
                    selectedEmoji == emoji ?
                        ThemeColors.accent.opacity(0.2) : Color.clear
                )
                .cornerRadius(8)
        }
    }
    
    // 生成Emoji范围
    private static func emojiRange(start: Int, end: Int) -> [String] {
        return (start...end).compactMap { UnicodeScalar($0) }.map { String($0) }
    }
}

// 预览
struct EmojiPicker_Previews: PreviewProvider {
    static var previews: some View {
        EmojiPicker(selectedEmoji: .constant("😀"))
            .background(ThemeColors.base)
            .preferredColorScheme(.dark)
    }
} 