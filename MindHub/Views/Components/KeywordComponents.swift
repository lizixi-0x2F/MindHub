import SwiftUI

// 关键词卡片子视图
struct KeywordCard: View {
    let entry: JournalEntry
    
    var body: some View {
        KeywordCardContent(keywords: generateKeywords(from: entry.content, and: entry.tags))
    }
    
    // 根据内容和标签生成关键词
    private func generateKeywords(from content: String, and tags: [String]) -> [String] {
        var keywords = Set<String>()
        
        // 添加标签作为关键词
        keywords.formUnion(tags)
        
        // 简单的内容分析，提取可能的关键词
        let words = content.split(separator: " ")
        let significantWords = words.filter { word in
            let cleaned = word.trimmingCharacters(in: .punctuationCharacters).lowercased()
            
            // 关键词需要长度大于3且不是常见的虚词
            return cleaned.count > 3 && !["的", "了", "和", "是", "在", "有", "这", "我", "他", "她", "它", "们", "你", "我们", "你们", "他们", "她们", "它们"].contains(cleaned)
        }
        
        // 添加内容中的关键词，最多5个
        for word in significantWords {
            let cleaned = word.trimmingCharacters(in: .punctuationCharacters)
            if !cleaned.isEmpty {
                keywords.insert(String(cleaned))
                if keywords.count >= 8 {
                    break
                }
            }
        }
        
        return Array(keywords)
    }
}

struct KeywordCardContent: View {
    let keywords: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标题
            Text("关键词")
                .font(.headline)
                .foregroundColor(ThemeColors.primaryText)
            
            if !keywords.isEmpty {
                KeywordList(keywords: keywords)
            } else {
                KeywordPlaceholder()
            }
        }
        .padding()
        .background(ThemeColors.cardBackground)
        .cornerRadius(16)
        .shadow(color: ThemeColors.shadow, radius: 4, x: 0, y: 2)
    }
}

struct KeywordList: View {
    let keywords: [String]
    private let columns: [GridItem] = [GridItem(.adaptive(minimum: 60), spacing: 8)]

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
            ForEach(keywords, id: \.self) { keyword in
                KeywordBadge(keyword: keyword)
            }
        }
    }
}

struct KeywordBadge: View {
    let keyword: String
    
    var body: some View {
        Text(keyword)
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(ThemeColors.accent.opacity(0.2))
            .foregroundColor(ThemeColors.accent)
            .cornerRadius(12)
    }
}

struct KeywordPlaceholder: View {
    var body: some View {
        Text("暂无关键词")
            .font(.subheadline)
            .foregroundColor(ThemeColors.tertiaryText)
    }
} 