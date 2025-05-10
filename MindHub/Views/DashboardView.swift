import SwiftUI
import Charts

// 暂时不导入组件，先定义空的组件结构体，使编译通过
struct GitHubStyleContributionView: View {
    var entries: [JournalEntry]
    
    var body: some View {
        Text("GitHub风格贡献图")
    }
}

struct EmotionQuadrantView: View {
    var entries: [JournalEntry]
    
    var body: some View {
        Text("情绪象限图")
    }
}

struct EmotionTrendChartView: View {
    var entries: [JournalEntry]
    
    var body: some View {
        Text("情绪趋势图")
    }
}

struct DashboardView: View {
    @EnvironmentObject var journalViewModel: JournalViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 统计卡片
                    StatisticsCard(
                        title: "日记统计",
                        items: [
                            ("总日记数", "\(journalViewModel.entries.count)"),
                            ("收藏数量", "\(journalViewModel.entries.filter { $0.isFavorite }.count)"),
                            ("本周日记", "\(getEntriesCount(days: 7))")
                        ]
                    )
                    
                    // 心情分布
                    MoodDistributionCard(
                        title: "心情分布",
                        entries: journalViewModel.entries
                    )
                    
                    // 写作日历
                    WritingCalendarCard(
                        title: "写作日历",
                        entries: journalViewModel.entries
                    )
                }
                .padding()
            }
            .navigationTitle("统计")
            .onAppear {
                journalViewModel.loadEntries()
            }
        }
    }
    
    // 获取指定天数内的日记数量
    private func getEntriesCount(days: Int) -> Int {
        let calendar = Calendar.current
        let today = Date()
        let startDate = calendar.date(byAdding: .day, value: -days, to: today)!
        
        return journalViewModel.entries.filter { 
            $0.date >= startDate && $0.date <= today 
        }.count
    }
}

// 统计卡片视图
struct StatisticsCard: View {
    let title: String
    let items: [(String, String)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .padding(.bottom, 5)
            
            ForEach(items, id: \.0) { item in
                HStack {
                    Text(item.0)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(item.1)
                        .fontWeight(.medium)
                }
                .padding(.vertical, 5)
                
                if item.0 != items.last?.0 {
                    Divider()
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// 心情分布卡片
struct MoodDistributionCard: View {
    let title: String
    let entries: [JournalEntry]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .padding(.bottom, 5)
            
            if entries.isEmpty {
                Text("暂无数据")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                VStack(spacing: 15) {
                    ForEach(moodCounts.sorted(by: { $0.value > $1.value }), id: \.key) { mood, count in
                        HStack {
                            Text("\(mood.emoji) \(mood.rawValue)")
                            
                            Spacer()
                            
                            Text("\(count)")
                                .foregroundColor(.secondary)
                            
                            ProgressView(value: Double(count), total: Double(entries.count))
                                .frame(width: 100)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    // 计算各种心情的数量
    private var moodCounts: [Mood: Int] {
        var counts: [Mood: Int] = [:]
        
        for mood in Mood.allCases {
            counts[mood] = 0
        }
        
        for entry in entries {
            counts[entry.mood, default: 0] += 1
        }
        
        return counts
    }
}

// 写作日历卡片
struct WritingCalendarCard: View {
    let title: String
    let entries: [JournalEntry]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .padding(.bottom, 5)
            
            if entries.isEmpty {
                Text("暂无数据")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                HStack(spacing: 4) {
                    ForEach(0..<7) { index in
                        let date = Calendar.current.date(byAdding: .day, value: -6 + index, to: Date())!
                        let count = entriesCount(for: date)
                        
                        VStack(spacing: 4) {
                            Text(weekdaySymbol(for: date))
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(cellColor(for: count))
                                .frame(height: 30)
                            
                            Text("\(count)")
                                .font(.caption)
                        }
                    }
                }
                .padding(.vertical)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    // 获取指定日期的日记数量
    private func entriesCount(for date: Date) -> Int {
        let calendar = Calendar.current
        return entries.filter { entry in
            calendar.isDate(entry.date, inSameDayAs: date)
        }.count
    }
    
    // 获取星期几的缩写
    private func weekdaySymbol(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
    
    // 根据日记数量决定单元格颜色
    private func cellColor(for count: Int) -> Color {
        switch count {
        case 0:
            return Color.gray.opacity(0.2)
        case 1:
            return Color.blue.opacity(0.3)
        case 2:
            return Color.blue.opacity(0.5)
        default:
            return Color.blue.opacity(0.8)
        }
    }
}

// 欢迎卡片
struct WelcomeCard: View {
    @EnvironmentObject var appSettings: AppSettings
    @EnvironmentObject var journalViewModel: JournalViewModel
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        if hour < 12 {
            return "早上好"
        } else if hour < 18 {
            return "下午好"
        } else {
            return "晚上好"
        }
    }
    
    private var date: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy年MM月dd日 EEEE"
        return formatter.string(from: Date())
    }
    
    private var journalingStreak: Int {
        // 简单实现：计算连续几天有日记
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var streakDays = 0
        
        for day in 0..<30 { // 最多检查30天
            let checkDate = calendar.date(byAdding: .day, value: -day, to: today)!
            let entriesForDay = journalViewModel.getEntries(for: checkDate)
            
            if entriesForDay.isEmpty {
                if day > 0 { // 如果不是今天，中断连续记录
                    break
                }
            } else {
                streakDays += 1
            }
        }
        
        return streakDays
    }
    
    private var activePercentage: Double {
        return journalViewModel.getActiveJournalingPercentage(for: 30) * 100
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(greeting)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    if !appSettings.userName.isEmpty {
                        Text(appSettings.userName)
                            .font(.title2)
                            .fontWeight(.medium)
                    }
                    
                    Text(date)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "sun.max.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.yellow)
            }
            
            Spacer().frame(height: 10)
            
            Text("今天是记录和反思的好时机，关注自己的情绪变化。")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Divider()
                .padding(.vertical, 5)
            
            HStack(spacing: 16) {
                VStack(alignment: .leading) {
                    Text("连续记录")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(journalingStreak) 天")
                        .font(.headline)
                }
                
                Divider()
                    .frame(height: 30)
                
                VStack(alignment: .leading) {
                    Text("30天活跃度")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(String(format: "%.0f%%", activePercentage))
                        .font(.headline)
                }
                
                Spacer()
                
                Button(action: {
                    // 日记按钮点击
                }) {
                    Text("写日记")
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// 今日日记视图
struct TodayJournalsView: View {
    @EnvironmentObject var journalViewModel: JournalViewModel
    
    let onNewEntry: () -> Void
    
    private var todayEntries: [JournalEntry] {
        let calendar = Calendar.current
        return journalViewModel.entries.filter { calendar.isDateInToday($0.date) }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            if todayEntries.isEmpty {
                VStack(spacing: 10) {
                    Text("今天还没有记录日记")
                        .font(.headline)
                    
                    Text("记录您的想法和感受，跟踪您的情绪变化")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button(action: onNewEntry) {
                        Text("写日记")
                            .font(.headline)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.top, 5)
                }
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity)
            } else {
                ForEach(todayEntries) { entry in
                    NavigationLink(destination: JournalDetailView(entry: entry)) {
                        JournalEntryCard(entry: entry)
                    }
                }
                
                Button(action: onNewEntry) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("添加日记")
                    }
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
                }
            }
        }
    }
}

// 日记条目卡片
struct JournalEntryCard: View {
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
            
            Text(entry.content.prefix(80) + (entry.content.count > 80 ? "..." : ""))
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            HStack {
                Text(formattedTime)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // 显示唤起度和价效度
                if let arousal = entry.arousal, let valence = entry.valence {
                    Text("A: \(Int(arousal * 100)) V: \(Int(valence * 100))")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(.systemGray5))
                        )
                }
                
                if !entry.tags.isEmpty {
                    Text("#\(entry.tags.first!)")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                if entry.isFavorite {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
    
    // 格式化时间
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: entry.date)
    }
}

// 情感洞察视图
struct EmotionInsightsView: View {
    @EnvironmentObject var journalViewModel: JournalViewModel
    
    private var insights: [EmotionInsight] {
        var result: [EmotionInsight] = []
        
        // 获取过去30天的日记
        let calendar = Calendar.current
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: Date())!
        
        let recentEntries = journalViewModel.entries.filter { $0.date >= thirtyDaysAgo }
        
        // 统计情感分析结果
        var emotionCounts: [String: Int] = [:]
        
        for entry in recentEntries {
            if let primaryEmotion = entry.getPrimaryEmotion() {
                emotionCounts[primaryEmotion, default: 0] += 1
            }
        }
        
        // 找出最常见的情感
        if let mostCommon = emotionCounts.max(by: { $0.value < $1.value }) {
            result.append(EmotionInsight(
                title: "最常见情绪",
                description: "您最常表达的情绪是「\(mostCommon.key)」，在过去30天中出现了\(mostCommon.value)次。",
                icon: "chart.bar.fill"
            ))
        }
        
        // 积极/消极情绪比例
        let positiveEmotions = ["joy", "happiness", "excited", "trust", "喜悦", "开心", "兴奋", "信任"]
        let negativeEmotions = ["sadness", "anger", "fear", "disgust", "悲伤", "愤怒", "恐惧", "厌恶"]
        
        var positiveCount = 0
        var negativeCount = 0
        
        for (emotion, count) in emotionCounts {
            if positiveEmotions.contains(where: { emotion.localizedCaseInsensitiveContains($0) }) {
                positiveCount += count
            } else if negativeEmotions.contains(where: { emotion.localizedCaseInsensitiveContains($0) }) {
                negativeCount += count
            }
        }
        
        let total = positiveCount + negativeCount
        
        if total > 0 {
            let positivePercentage = Double(positiveCount) / Double(total) * 100
            
            if positivePercentage >= 70 {
                result.append(EmotionInsight(
                    title: "积极心态",
                    description: "您的记录显示，在过去30天中有\(Int(positivePercentage))%的日记表达了积极情绪。",
                    icon: "sun.max.fill"
                ))
            } else if positivePercentage <= 30 {
                result.append(EmotionInsight(
                    title: "情绪提醒",
                    description: "您的记录显示，在过去30天中有\(100 - Int(positivePercentage))%的日记表达了消极情绪。",
                    icon: "cloud.rain.fill"
                ))
            } else {
                result.append(EmotionInsight(
                    title: "情绪平衡",
                    description: "您的情绪记录相对平衡，积极情绪占\(Int(positivePercentage))%，消极情绪占\(100 - Int(positivePercentage))%。",
                    icon: "equal.circle.fill"
                ))
            }
        }
        
        // 唤起度和价效度分析
        var totalArousal = 0.0
        var totalValence = 0.0
        var count = 0
        
        for entry in recentEntries {
            totalArousal += entry.getArousal()
            totalValence += entry.getValence()
            count += 1
        }
        
        if count > 0 {
            let avgArousal = totalArousal / Double(count)
            let avgValence = totalValence / Double(count)
            
            if avgArousal > 0.7 && avgValence > 0.7 {
                result.append(EmotionInsight(
                    title: "高唤起高价效",
                    description: "您的记录显示高度的积极兴奋情绪，这表明您最近经历了令人愉快的活跃时光。",
                    icon: "bolt.fill"
                ))
            } else if avgArousal > 0.7 && avgValence < 0.3 {
                result.append(EmotionInsight(
                    title: "高唤起低价效",
                    description: "您的记录显示高度的紧张和压力情绪，建议尝试一些减压活动和放松练习。",
                    icon: "exclamationmark.triangle.fill"
                ))
            } else if avgArousal < 0.3 && avgValence > 0.7 {
                result.append(EmotionInsight(
                    title: "低唤起高价效",
                    description: "您的记录显示平静满足的情绪状态，继续保持这种平和的心态。",
                    icon: "leaf.fill"
                ))
            } else if avgArousal < 0.3 && avgValence < 0.3 {
                result.append(EmotionInsight(
                    title: "低唤起低价效",
                    description: "您的记录显示低落或沮丧的情绪状态，建议增加社交活动和寻求支持。",
                    icon: "cloud.rain.fill"
                ))
            }
        }
        
        // 如果没有足够的数据，添加默认洞察
        if result.isEmpty {
            result.append(EmotionInsight(
                title: "开始记录",
                description: "每天记录您的感受和情绪，我们将为您提供个性化的情感洞察。",
                icon: "pencil.circle.fill"
            ))
        }
        
        return result
    }
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(insights) { insight in
                InsightCard(insight: insight)
            }
        }
    }
}

// 情感洞察结构
struct EmotionInsight: Identifiable {
    var id = UUID()
    var title: String
    var description: String
    var icon: String
}

// 洞察卡片
struct InsightCard: View {
    let insight: EmotionInsight
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: insight.icon)
                .font(.system(size: 30))
                .foregroundColor(.blue)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(insight.title)
                    .font(.headline)
                
                Text(insight.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

// 带标题的部分卡片
struct SectionCard<Content: View>: View {
    let title: String
    let content: Content
    var showDivider: Bool = true
    
    init(title: String, showDivider: Bool = true, @ViewBuilder content: () -> Content) {
        self.title = title
        self.showDivider = showDivider
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            
            if showDivider {
                Divider()
            }
            
            content
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .environmentObject(JournalViewModel())
    }
} 