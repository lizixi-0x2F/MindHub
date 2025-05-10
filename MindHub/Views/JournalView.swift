import SwiftUI

struct JournalView: View {
    @EnvironmentObject var emotionAnalysisManager: EmotionAnalysisManager
    @StateObject private var journalViewModel = JournalViewModel()
    
    @State private var showingNewEntrySheet = false
    @State private var searchText = ""
    @State private var selectedFilter: JournalFilter = .all
    
    var body: some View {
        NavigationView {
            VStack {
                // 过滤选项
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(JournalFilter.allCases, id: \.self) { filter in
                            FilterButton(
                                title: filter.displayName,
                                isSelected: selectedFilter == filter,
                                action: {
                                    selectedFilter = filter
                                }
                            )
                            .accessibilityIdentifier("filter-\(filter)")
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 8)
                
                // 日记列表
                List {
                    ForEach(filteredEntries) { entry in
                        NavigationLink(destination: JournalDetailView(entry: entry)) {
                            JournalEntryRow(entry: entry)
                                .accessibilityIdentifier("journal-entry-\(entry.id)")
                        }
                    }
                    .onDelete(perform: deleteEntries)
                }
                .listStyle(InsetGroupedListStyle())
                .searchable(text: $searchText, prompt: "搜索日记...")
                .accessibilityIdentifier("journal-entries-list")
            }
            .navigationTitle("日记")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingNewEntrySheet = true
                    }) {
                        Image(systemName: "square.and.pencil")
                    }
                    .accessibilityIdentifier("new-journal-entry")
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button("按日期排序", action: { journalViewModel.sortByDate() })
                            .accessibilityIdentifier("sort-by-date")
                        Button("按心情排序", action: { journalViewModel.sortByMood() })
                            .accessibilityIdentifier("sort-by-mood")
                        Button("按情感分析排序", action: { journalViewModel.sortByEmotion() })
                            .accessibilityIdentifier("sort-by-emotion")
                        Divider()
                        Button("执行情感分析", action: {
                            journalViewModel.analyzeAllEntries()
                        })
                        .accessibilityIdentifier("analyze-all-entries")
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                    .accessibilityIdentifier("journal-options-menu")
                }
            }
            .sheet(isPresented: $showingNewEntrySheet) {
                NewJournalEntryView(emotionAnalysisManager: emotionAnalysisManager) { newEntry in
                    journalViewModel.addEntry(newEntry)
                    showingNewEntrySheet = false
                }
            }
        }
        .onAppear {
            journalViewModel.loadEntries()
        }
    }
    
    // 根据过滤条件筛选日记
    private var filteredEntries: [JournalEntry] {
        var entries = journalViewModel.entries
        
        // 应用搜索筛选
        if !searchText.isEmpty {
            entries = entries.filter { entry in
                entry.title.localizedCaseInsensitiveContains(searchText) ||
                entry.content.localizedCaseInsensitiveContains(searchText) ||
                entry.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        // 应用类别筛选
        switch selectedFilter {
        case .all:
            return entries
        case .favorites:
            return entries.filter { $0.isFavorite }
        case .today:
            let calendar = Calendar.current
            return entries.filter { calendar.isDateInToday($0.date) }
        case .thisWeek:
            let calendar = Calendar.current
            let oneWeekAgo = calendar.date(byAdding: .weekOfYear, value: -1, to: Date())!
            return entries.filter { $0.date >= oneWeekAgo }
        case .thisMonth:
            let calendar = Calendar.current
            let oneMonthAgo = calendar.date(byAdding: .month, value: -1, to: Date())!
            return entries.filter { $0.date >= oneMonthAgo }
        case .positive:
            return entries.filter { entry in
                if let primaryEmotion = entry.getPrimaryEmotion() {
                    return ["joy", "happy", "excited", "trust", "喜悦", "开心", "兴奋", "信任"].contains { primaryEmotion.localizedCaseInsensitiveContains($0) }
                }
                return false
            }
        case .negative:
            return entries.filter { entry in
                if let primaryEmotion = entry.getPrimaryEmotion() {
                    return ["sad", "angry", "fear", "disgust", "悲伤", "愤怒", "恐惧", "厌恶"].contains { primaryEmotion.localizedCaseInsensitiveContains($0) }
                }
                return false
            }
        }
    }
    
    // 删除日记
    private func deleteEntries(at offsets: IndexSet) {
        journalViewModel.deleteEntries(at: offsets)
    }
}

// 日记列表项
struct JournalEntryRow: View {
    let entry: JournalEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(entry.title)
                    .font(.headline)
                
                Spacer()
                
                Text(entry.mood.icon)
                    .font(.title3)
            }
            
            Text(entry.content.prefix(100) + (entry.content.count > 100 ? "..." : ""))
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            HStack {
                Text(formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if !entry.tags.isEmpty {
                    ForEach(entry.tags.prefix(2), id: \.self) { tag in
                        Text("#\(tag)")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    
                    if entry.tags.count > 2 {
                        Text("+\(entry.tags.count - 2)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                if entry.isFavorite {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    // 格式化日期
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: entry.date)
    }
}

// 过滤按钮
struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

// 日记过滤类型
enum JournalFilter: CaseIterable {
    case all
    case favorites
    case today
    case thisWeek
    case thisMonth
    case positive
    case negative
    
    var displayName: String {
        switch self {
        case .all: return "全部"
        case .favorites: return "收藏"
        case .today: return "今天"
        case .thisWeek: return "本周"
        case .thisMonth: return "本月"
        case .positive: return "积极情绪"
        case .negative: return "消极情绪"
        }
    }
}

struct JournalView_Previews: PreviewProvider {
    static var previews: some View {
        JournalView()
            .environmentObject(EmotionAnalysisManager())
    }
} 