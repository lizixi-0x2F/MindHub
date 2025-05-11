import SwiftUI

struct GitHubStyleContributionView: View {
    let entries: [JournalEntry]
    var onTapDay: ((Date) -> Void)?
    
    // 周和日标签
    private let weekdays = ["一", "三", "五", "日"]
    private let months = ["1月", "2月", "3月", "4月", "5月", "6月", "7月", "8月", "9月", "10月", "11月", "12月"]
    
    // 配色方案 - 使用蓝-青渐变
    private func colorForLevel(_ level: Int) -> Color {
        switch level {
        case 0:
            return ThemeColors.surface2 // 无记录
        case 1:
            return Color(red: 0.09, green: 0.33, blue: 0.5) // 低频
        case 2:
            return Color(red: 0.09, green: 0.47, blue: 0.61)
        case 3:
            return Color(red: 0.09, green: 0.61, blue: 0.72)
        case 4:
            return Color(red: 0.09, green: 0.8, blue: 0.85) // 高频
        default:
            return ThemeColors.surface2
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 月份标签
            HStack(alignment: .center, spacing: 0) {
                Text("") // 为周标签留空白
                    .frame(width: 20)
                
                // 月份标签
                contributionMonthsView()
            }
            .padding(.leading, 4)
            
            HStack(alignment: .top, spacing: 4) {
                // 周标签
                VStack(alignment: .leading, spacing: 13) {
                    ForEach(weekdays, id: \.self) { day in
                        Text(day)
                            .font(.system(size: 10))
                            .foregroundColor(ThemeColors.textSecondary)
                    }
                }
                .padding(.top, 4)
                
                // 热力图
                contributionGridView()
            }
            
            // 图例
            HStack(spacing: 4) {
                Text("少")
                    .font(.caption2)
                    .foregroundColor(ThemeColors.textTertiary)
                
                ForEach(0..<5) { level in
                    Rectangle()
                        .fill(colorForLevel(level))
                        .frame(width: 12, height: 12)
                        .cornerRadius(2)
                }
                
                Text("多")
                    .font(.caption2)
                    .foregroundColor(ThemeColors.textTertiary)
                
                Spacer()
                
                Text("活跃度 (点击查看详情)")
                    .font(.caption2)
                    .foregroundColor(ThemeColors.textSecondary)
            }
            .padding(.horizontal, 4)
            .padding(.top, 2)
        }
    }
    
    // 月份标签视图
    private func contributionMonthsView() -> some View {
        let monthPositions = calculateMonthPositions()
        return ZStack(alignment: .leading) {
            HStack(spacing: 0) {
                ForEach(0..<7*7, id: \.self) { _ in
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: 14, height: 1)
                }
            }
            
            ForEach(monthPositions) { position in
                Text(position.month)
                    .font(.system(size: 9))
                    .foregroundColor(ThemeColors.textSecondary)
                    .offset(x: CGFloat(position.column) * 14)
            }
        }
    }
    
    // 热力图网格视图
    private func contributionGridView() -> some View {
        let calendar = Calendar.current
        let today = Date()
        let dateInterval = calendar.dateInterval(of: .day, for: today)!
        let startOfToday = dateInterval.start
        
        // 计算49天前的日期
        let startDate = calendar.date(byAdding: .day, value: -48, to: startOfToday)!
        
        return LazyVGrid(columns: Array(repeating: GridItem(.fixed(14), spacing: 4), count: 7), spacing: 4) {
            ForEach(0..<7*7) { index in
                let day = calendar.date(byAdding: .day, value: index, to: startDate)!
                let level = activityLevelForDate(day)
                
                Button(action: {
                    onTapDay?(day)
                }) {
                    Rectangle()
                        .fill(colorForLevel(level))
                        .frame(width: 14, height: 14)
                        .cornerRadius(2)
                }
                .buttonStyle(PlainButtonStyle())
                .help(formattedDateString(day) + " (\(level > 0 ? "\(level)条记录" : "无记录"))")
            }
        }
    }
    
    // 计算月份位置
    private func calculateMonthPositions() -> [MonthPosition] {
        let calendar = Calendar.current
        let today = Date()
        let dateInterval = calendar.dateInterval(of: .day, for: today)!
        let startOfToday = dateInterval.start
        
        // 计算49天前的日期
        let startDate = calendar.date(byAdding: .day, value: -48, to: startOfToday)!
        
        var positions: [MonthPosition] = []
        var currentMonth = -1
        
        for i in 0..<7*7 {
            let day = calendar.date(byAdding: .day, value: i, to: startDate)!
            let month = calendar.component(.month, from: day) - 1 // 0-based month
            
            if month != currentMonth {
                currentMonth = month
                positions.append(MonthPosition(id: i, month: months[month], column: i % 7))
            }
        }
        
        return positions
    }
    
    // 格式化日期字符串
    private func formattedDateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }
    
    // 计算日期的活动强度
    private func activityLevelForDate(_ date: Date) -> Int {
        let calendar = Calendar.current
        
        // 查找该日期的所有记录
        let dayEntries = entries.filter { entry in
            calendar.isDate(entry.date, inSameDayAs: date)
        }
        
        // 根据记录数量返回活动级别
        let count = dayEntries.count
        if count == 0 {
            return 0
        } else if count == 1 {
            return 1
        } else if count == 2 {
            return 2
        } else if count <= 4 {
            return 3
        } else {
            return 4
        }
    }
}

// 月份位置模型
struct MonthPosition: Identifiable {
    let id: Int
    let month: String
    let column: Int
}

// 预览
struct GitHubStyleContributionView_Previews: PreviewProvider {
    static var previews: some View {
        GitHubStyleContributionView(entries: mockEntries(), onTapDay: { _ in })
            .padding()
            .background(ThemeColors.background)
            .previewLayout(.sizeThatFits)
    }
    
    // 生成模拟数据
    static func mockEntries() -> [JournalEntry] {
        let calendar = Calendar.current
        let today = Date()
        var entries: [JournalEntry] = []
        
        for i in 0..<30 {
            let randomCount = Int.random(in: 0...3)
            let date = calendar.date(byAdding: .day, value: -i, to: today)!
            
            for j in 0..<randomCount {
                entries.append(
                    JournalEntry(
                        id: UUID(),
                        title: "记录 \(i)-\(j)",
                        content: "内容示例",
                        date: date,
                        mood: Mood.allCases.randomElement()!
                    )
                )
            }
        }
        
        return entries
    }
} 