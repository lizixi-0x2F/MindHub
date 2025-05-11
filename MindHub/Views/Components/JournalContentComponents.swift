import SwiftUI

// 日记内容卡片组件
struct JournalContentCard: View {
    let entry: JournalEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 标题和日期
            TitleDateHeader(title: entry.title, date: entry.date)
            
            // 内容
            ContentText(content: entry.content)
        }
        .padding()
        .background(ThemeColors.cardBackground)
        .cornerRadius(16)
        .shadow(color: ThemeColors.shadow, radius: 4, x: 0, y: 2)
    }
}

// 标题和日期头部组件
struct TitleDateHeader: View {
    let title: String
    let date: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(ThemeColors.primaryText)
            
            Text(dateFormatter.string(from: date))
                .font(.subheadline)
                .foregroundColor(ThemeColors.secondaryText)
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter
    }
}

// 内容文本组件
struct ContentText: View {
    let content: String
    
    var body: some View {
        Text(content)
            .font(.body)
            .foregroundColor(ThemeColors.primaryText)
            .lineSpacing(6)
            .fixedSize(horizontal: false, vertical: true)
    }
}

// 标题卡片子视图
struct JournalTitleCard: View {
    let entry: JournalEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标题部分
            HStack {
                Text(entry.title)
                    .font(.title)
                    .foregroundColor(ThemeColors.primaryText)
                
                Spacer()
                
                if entry.isFavorite {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                }
            }
            
            // 日期和心情
            HStack {
                Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.subheadline)
                    .foregroundColor(ThemeColors.secondaryText)
                
                Spacer()
                
                Text(entry.mood.rawValue)
                    .font(.subheadline)
                    .foregroundColor(ThemeColors.secondaryText)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(moodColor(for: entry.mood).opacity(0.3))
                    )
            }
            
            // 标签
            if !entry.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(entry.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .foregroundColor(ThemeColors.primaryText)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(ThemeColors.accent.opacity(0.2))
                                )
                        }
                    }
                }
            }
        }
        .padding()
        .background(ThemeColors.cardBackground)
        .cornerRadius(16)
        .shadow(color: ThemeColors.shadow, radius: 4, x: 0, y: 2)
    }
    
    // 根据心情返回颜色
    private func moodColor(for mood: Mood) -> Color {
        switch mood {
        case .happy:
            return ThemeColors.joyColor
        case .sad:
            return ThemeColors.sadnessColor
        case .angry:
            return ThemeColors.angerColor
        case .anxious:
            return ThemeColors.fearColor
        case .excited:
            return ThemeColors.surpriseColor
        case .neutral:
            return ThemeColors.neutralColor
        case .relaxed:
            return ThemeColors.neutralColor
        }
    }
}

// 输入相关组件
// 标题输入字段
struct TitleInputField: View {
    @Binding var title: String
    
    var body: some View {
        TextField("标题", text: $title)
            .font(.title3)
            .padding()
            .background(ThemeColors.cardBackground)
            .cornerRadius(8)
    }
}

// 内容输入字段
struct ContentInputField: View {
    @Binding var content: String
    
    var body: some View {
        #if os(iOS)
        TextEditor(text: $content)
            .frame(minHeight: 200)
            .padding()
            .background(ThemeColors.cardBackground)
            .cornerRadius(8)
        #else
        TextField("内容", text: $content, axis: .vertical)
            .lineLimit(10...)
            .frame(minHeight: 200)
            .padding()
            .background(ThemeColors.cardBackground)
            .cornerRadius(8)
        #endif
    }
}

// 心情选择字段
struct MoodSelectionField: View {
    @Binding var mood: Mood
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("心情")
                .font(.headline)
                .foregroundColor(ThemeColors.primaryText)
            
            Picker("心情", selection: $mood) {
                ForEach(Mood.allCases, id: \.self) { mood in
                    Text(mood.rawValue).tag(mood)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
        .padding()
        .background(ThemeColors.cardBackground)
        .cornerRadius(8)
    }
}

// 收藏切换
struct FavoriteToggle: View {
    @Binding var isFavorite: Bool
    
    var body: some View {
        Toggle("收藏", isOn: $isFavorite)
            .padding()
            .background(ThemeColors.cardBackground)
            .cornerRadius(8)
    }
} 