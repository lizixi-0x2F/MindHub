import SwiftUI
import Charts
import Foundation
import UserNotifications

// 导入组件
@_exported import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var journalViewModel: JournalViewModel
    @State private var analysisResults: [UUID: EmotionResult] = [:]
    @State private var isAnalyzing: Bool = false
    @State private var selectedTimeRange: String = "本周"
    @State private var selectedDate: Date? = nil
    @State private var showingJournalDetail: Bool = false
    @State private var showingWeeklyReportDetail: Bool = false
    
    // 快速日记创建
    @State private var showingQuickEntrySheet = false
    
    // 时间范围选项
    private let timeRanges = ["今天", "本周", "本月", "本年"]
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 16) {
                // 头部标题
                DashboardHeaderView(dateString: getCurrentDateString())
                
                // 时间段选择器
                TimeRangeSelectorView(
                    timeRanges: timeRanges,
                    selectedTimeRange: $selectedTimeRange
                )
                
                // 周报卡片 - 新增
                WeeklyReportCardView(
                    report: journalViewModel.getLatestWeeklyReport(),
                    onTapViewDetails: {
                        showingWeeklyReportDetail = true
                    }
                )
                .padding(.horizontal, 16)
                
                // GitHub风格贡献热力图
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "calendar.day.timeline.left")
                            .foregroundColor(ThemeColors.accent)
                            .font(.headline)
                        
                        Text("记录热力图 📊")
                            .font(.headline)
                            .foregroundColor(ThemeColors.textPrimary)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    GitHubStyleContributionView(
                        entries: journalViewModel.entries,
                        onTapDay: { date in
                            selectedDate = date
                            showingJournalDetail = true
                        }
                    )
                    .padding(.horizontal)
                    .padding(.bottom)
                }
                .background(ThemeColors.surface1)
                .cornerRadius(12)
                .shadow(color: ThemeColors.shadow, radius: 2, x: 0, y: 1)
                .padding(.horizontal, 16)
                
                // 快速操作卡片行
                QuickActionsRowView(
                    showingQuickEntrySheet: $showingQuickEntrySheet
                )
                
                // 情绪趋势卡片
                DashboardEmotionTrendCardView(
                    entries: journalViewModel.entries,
                    analysisResults: analysisResults
                )
                
                // 情绪象限卡片
                DashboardEmotionQuadrantCardView(
                    entries: journalViewModel.entries,
                    analysisResults: analysisResults
                )
                
                // 数据卡片网格
                DashboardStatsGridView(
                    journalViewModel: journalViewModel,
                    analysisResults: analysisResults,
                    entriesThisWeek: entriesThisWeek(),
                    averageValence: calculateAverageValence(),
                    streak: calculateStreak()
                )
                .padding(.top, 8)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
        .background(ThemeColors.base)
        .navigationTitle("情绪健康")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingQuickEntrySheet) {
            // 使用新日记条目视图
            NewJournalEntryView(onSave: { newEntry in
                journalViewModel.addEntry(newEntry)
            })
                .environmentObject(journalViewModel)
        }
        .sheet(isPresented: $showingJournalDetail) {
            // 显示选中日期的日记详情
            if let date = selectedDate {
                JournalDetailSheet(date: date, entries: journalViewModel.entriesForDate(date))
                    .environmentObject(journalViewModel)
            }
        }
        .sheet(isPresented: $showingWeeklyReportDetail) {
            // 显示完整周报
            WeeklyReportView()
                .environmentObject(journalViewModel)
        }
        .onAppear {
            analyzeEmotions()
            Task {
                await checkAndGenerateWeeklyReport()
            }
        }
        .onChange(of: selectedTimeRange) { oldValue, newValue in
            analyzeEmotions()
        }
        .onChange(of: journalViewModel.entries.count) { oldCount, newCount in
            // 当日记条目数量变化时重新分析
            analyzeEmotions()
        }
    }
    
    // 检查是否需要生成周报
    private func checkAndGenerateWeeklyReport() async {
        // 检查是否需要自动生成
        if journalViewModel.shouldGenerateNewWeeklyReport() {
            // 异步生成周报
            Task {
                await journalViewModel.createAndSaveWeeklyReport(for: 0)
            }
        }
    }
    
    // 获取当前日期的格式化字符串
    private func getCurrentDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日 EEEE"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: Date())
    }
    
    // 获取本周日记
    private func entriesThisWeek() -> [JournalEntry] {
        let calendar = Calendar.current
        let today = Date()
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
        
        return journalViewModel.entries.filter { entry in
            entry.date >= startOfWeek && entry.date <= today
        }
    }
    
    // 计算平均情绪值
    private func calculateAverageValence() -> Double {
        let relevantEntries = entriesThisWeek()
        let validResults = relevantEntries.compactMap { entry in
            analysisResults[entry.id]?.valence
        }
        
        if validResults.isEmpty {
            return 0.0
        }
        
        return validResults.reduce(0, +) / Double(validResults.count)
    }
    
    // 计算连续记录天数
    private func calculateStreak() -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let sortedDates = journalViewModel.entries
            .map { calendar.startOfDay(for: $0.date) }
            .sorted(by: >)
        
        guard let lastEntryDate = sortedDates.first else { return 0 }
        
        // 如果最后一条记录不是今天或昨天，则连续记录中断
        if calendar.dateComponents([.day], from: lastEntryDate, to: today).day! > 1 {
            return 0
        }
        
        var streak = 1
        var currentDate = lastEntryDate
        
        for date in sortedDates.dropFirst() {
            let expectedPrevDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
            
            if calendar.isDate(date, inSameDayAs: expectedPrevDate) {
                streak += 1
                currentDate = date
            } else {
                break
            }
        }
        
        return streak
    }
    
    private func analyzeEmotions() {
        isAnalyzing = true
        
        // 模拟分析过程
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            analysisResults = [:]
            
            for entry in journalViewModel.entries {
                // 生成随机情绪分析结果或真实分析
                let valence = Double.random(in: -1...1)
                let arousal = Double.random(in: -1...1)
                
                let emotions = ["喜悦", "悲伤", "愤怒", "恐惧", "惊讶", "厌恶", "兴奋", "满足", "平静", "沮丧", "忧虑", "紧张"]
                let dominantEmotion = emotions.randomElement() ?? "中性"
                
                let result = EmotionResult(
                    valence: valence,
                    arousal: arousal,
                    dominantEmotion: dominantEmotion
                )
                
                analysisResults[entry.id] = result
            }
            
            isAnalyzing = false
        }
    }
}

// 日记详情表单（用于点击热力图某日后显示）
struct JournalDetailSheet: View {
    let date: Date
    let entries: [JournalEntry]
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var journalViewModel: JournalViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                if entries.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 60))
                            .foregroundColor(ThemeColors.secondaryText)
                            .padding(.bottom, 8)
                        
                        Text("该日没有日记")
                            .font(.title2)
                            .foregroundColor(ThemeColors.primaryText)
                        
                        Text("点击下方按钮创建日记")
                            .foregroundColor(ThemeColors.secondaryText)
                        
                        Button(action: {
                            // 创建新日记
                            dismiss()
                            // 此处应该有导航到创建日记页面的逻辑
                        }) {
                            Text("创建日记")
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(ThemeColors.accent)
                                .foregroundColor(ThemeColors.primaryText)
                                .cornerRadius(12)
                        }
                        .padding(.top, 8)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(entries) { entry in
                            NavigationLink(destination: JournalDetailView(entry: entry, journalViewModel: journalViewModel)) {
                                DashboardJournalEntryRow(entry: entry)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle(formattedDate(date))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(ThemeColors.secondaryText)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    // 格式化日期
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }
}

// 日记条目行
struct DashboardJournalEntryRow: View {
    let entry: JournalEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(entry.title)
                    .font(.headline)
                    .foregroundColor(ThemeColors.primaryText)
                
                Spacer()
                
                Text(entry.moodIconName)
                    .font(.headline)
            }
            
            Text(entry.summary)
                .font(.subheadline)
                .foregroundColor(ThemeColors.secondaryText)
                .lineLimit(2)
            
            HStack {
                Text(entry.formattedDate)
                    .font(.caption)
                    .foregroundColor(ThemeColors.secondaryText)
                
                Spacer()
                
                if !entry.tags.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(entry.tags.prefix(2), id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.caption)
                                .foregroundColor(ThemeColors.accent)
                        }
                        
                        if entry.tags.count > 2 {
                            Text("+\(entry.tags.count - 2)")
                                .font(.caption)
                                .foregroundColor(ThemeColors.secondaryText)
                        }
                    }
                }
                
                Text(entry.emotionScoreText)
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(entry.emotionScoreColor.opacity(0.2))
                    .foregroundColor(entry.emotionScoreColor)
                    .cornerRadius(4)
            }
        }
        .padding(.vertical, 8)
    }
}

// 仪表盘头部视图
struct DashboardHeaderView: View {
    let dateString: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("情绪健康 🧠")
                .font(.title)
                .foregroundColor(ThemeColors.textPrimary)
            
            Text(dateString)
                .font(.caption)
                .foregroundColor(ThemeColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.top, 10)
    }
}

// 时间范围选择器
struct TimeRangeSelectorView: View {
    let timeRanges: [String]
    @Binding var selectedTimeRange: String
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(timeRanges, id: \.self) { period in
                    Button(action: {
                        withAnimation(.easeInOut) {
                            selectedTimeRange = period
                        }
                    }) {
                        Text(period)
                            .font(.system(size: 14, weight: period == selectedTimeRange ? .semibold : .regular))
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(
                                period == selectedTimeRange ? 
                                    ThemeColors.accent.opacity(0.2) : 
                                    ThemeColors.surface2
                            )
                            .foregroundColor(period == selectedTimeRange ? ThemeColors.accent : ThemeColors.textSecondary)
                            .cornerRadius(8)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

// 快速操作卡片行
struct QuickActionsRowView: View {
    @Binding var showingQuickEntrySheet: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // 写日记卡片
            Button(action: {
                showingQuickEntrySheet = true
            }) {
                QuickActionCard(
                    title: "写日记",
                    subtitle: "记录今天的情绪",
                    icon: "square.and.pencil",
                    color: ThemeColors.accent,
                    width: (UIScreen.main.bounds.width - 48) / 2
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            // 周报卡片
            NavigationLink(destination: WeeklyReportView()) {
                QuickActionCard(
                    title: "查看周报",
                    subtitle: "了解情绪变化",
                    icon: "chart.xyaxis.line",
                    color: ThemeColors.accentAlt,
                    width: (UIScreen.main.bounds.width - 48) / 2
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 16)
    }
}

// 情绪趋势卡片 (仪表盘版本)
struct DashboardEmotionTrendCardView: View {
    let entries: [JournalEntry]
    let analysisResults: [UUID: EmotionResult]
    
    // 根据设备尺寸获取适当的高度
    private var adaptiveHeight: CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        if screenHeight < 600 { // 非常小的屏幕（SE等）
            return 190
        } else if screenHeight < 700 { // 小屏幕
            return 220
        } else if screenHeight < 800 { // 中等屏幕
            return 250
        } else { // 大屏幕
            return 280
        }
    }
    
    // 根据设备尺寸获取适当的卡片容器高度
    private var containerHeight: CGFloat {
        return adaptiveHeight + 30
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "waveform.path.ecg")
                    .foregroundColor(ThemeColors.accent)
                    .font(.headline)
                
                Text("情绪趋势 📈")
                    .font(.headline)
                    .foregroundColor(ThemeColors.textPrimary)
                
                Spacer()
                
                NavigationLink(destination: WeeklyReportView()) {
                    Text("详情")
                        .font(.caption)
                        .foregroundColor(ThemeColors.accent)
                }
            }
            .padding(.horizontal)
            .padding(.top)
            .padding(.bottom, 4)
            
            GeometryReader { geometry in
                EmotionTrendChartView(entries: entries, analysisResults: analysisResults)
                    .frame(height: adaptiveHeight)
                    .padding(.horizontal, 10)
                    .padding(.bottom)
            }
            .frame(height: containerHeight)
        }
        .background(ThemeColors.surface1)
        .cornerRadius(12)
        .shadow(color: ThemeColors.shadow, radius: 2, x: 0, y: 1)
        .padding(.horizontal, 16)
    }
}

// 情绪象限卡片 (仪表盘版本)
struct DashboardEmotionQuadrantCardView: View {
    let entries: [JournalEntry]
    let analysisResults: [UUID: EmotionResult]
    
    // 根据设备尺寸获取适当的高度
    private var adaptiveHeight: CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        if screenHeight < 600 { // 非常小的屏幕（SE等）
            return 220
        } else if screenHeight < 700 { // 小屏幕
            return 250
        } else if screenHeight < 800 { // 中等屏幕
            return 280
        } else { // 大屏幕
            return 300
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "square.grid.2x2")
                    .foregroundColor(ThemeColors.accent)
                    .font(.headline)
                
                Text("情绪分布 🧩")
                    .font(.headline)
                    .foregroundColor(ThemeColors.textPrimary)
                
                Spacer()
                
                Button(action: {
                    // 查看详情操作
                }) {
                    Text("详情")
                        .font(.caption)
                        .foregroundColor(ThemeColors.accent)
                }
            }
            .padding(.horizontal)
            .padding(.top)
            .padding(.bottom, 4)
            
            GeometryReader { geometry in
                let width = geometry.size.width
                // 宽度越小，相对显示越高一些，保持近似正方形
                let quadrantHeight = min(adaptiveHeight - 30, width * 0.9)
                
                EmotionQuadrantView(entries: entries, analysisResults: analysisResults)
                    .frame(height: quadrantHeight)
                    .padding(.horizontal, 10)
                    .padding(.bottom)
            }
            .frame(height: adaptiveHeight)
        }
        .background(ThemeColors.surface1)
        .cornerRadius(12)
        .shadow(color: ThemeColors.shadow, radius: 2, x: 0, y: 1)
        .padding(.horizontal, 16)
    }
}

// 仪表盘统计网格
struct DashboardStatsGridView: View {
    let journalViewModel: JournalViewModel
    let analysisResults: [UUID: EmotionResult]
    let entriesThisWeek: [JournalEntry]
    let averageValence: Double
    let streak: Int
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            // 总日记数
            DataCard(
                title: "日记总数",
                value: "\(journalViewModel.entries.count)",
                subtitle: "累计记录 📝",
                icon: "doc.text.fill",
                color: .blue
            )
            
            // 本周日记数
            DataCard(
                title: "本周日记",
                value: "\(entriesThisWeek.count)",
                subtitle: "持续坚持 📅",
                icon: "calendar",
                color: .green
            )
            
            // 平均情绪值
            DataCard(
                title: "平均情绪值",
                value: String(format: "%.1f", averageValence),
                subtitle: "整体情绪 ☯️",
                icon: "heart.fill",
                color: .pink
            )
            
            // 日记频率
            DataCard(
                title: "连续记录",
                value: "\(streak)天",
                subtitle: "坚持不懈 🔥",
                icon: "flame.fill",
                color: .orange
            )
        }
        .padding(.horizontal, 16)
    }
}

// 快速操作卡片
struct QuickActionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let width: CGFloat
    
    @State private var isPressed: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 图标
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
            }
            
            // 标题和副标题
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(ThemeColors.textPrimary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(ThemeColors.textSecondary)
            }
        }
        .padding(16)
        .frame(width: width, height: 120, alignment: .leading)
        .background(ThemeColors.surface1)
        .cornerRadius(12)
        .shadow(color: ThemeColors.shadow, radius: isPressed ? 1 : 2, x: 0, y: isPressed ? 0 : 2)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut, value: isPressed)
        .onLongPressGesture(minimumDuration: 0.01, maximumDistance: 0.01, pressing: { pressing in
            withAnimation(.easeInOut) {
                isPressed = pressing
            }
        }, perform: { })
    }
}

// 数据卡片
struct DataCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    var destination: AnyView? = nil
    
    var body: some View {
        ZStack {
            if let dest = destination {
                NavigationLink(destination: dest) {
                    cardContent
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                cardContent
            }
        }
    }
    
    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 图标
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
            }
            
            // 数值
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(ThemeColors.textPrimary)
            
            // 标题和副标题
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(ThemeColors.textPrimary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(ThemeColors.textSecondary)
            }
        }
        .padding(16)
        .background(ThemeColors.surface1)
        .cornerRadius(12)
        .shadow(color: ThemeColors.shadow, radius: 2, x: 0, y: 1)
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DashboardView()
                .environmentObject(JournalViewModel())
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - WeeklyReportCardView Component
struct WeeklyReportCardView: View {
    let report: WeeklyReport?
    var onTapViewDetails: () -> Void
    @State private var isExpanded: Bool = false
    
    private var hasReport: Bool {
        return report != nil
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 标题栏
            HStack {
                Image(systemName: "chart.bar.doc.horizontal")
                    .foregroundColor(ThemeColors.accent)
                    .font(.system(size: 18))
                
                Text("周报")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(ThemeColors.textPrimary)
                
                Spacer()
                
                if hasReport {
                    Text(report!.dateRangeText)
                        .font(.system(size: 12))
                        .foregroundColor(ThemeColors.textSecondary)
                }
                
                Button(action: {
                    withAnimation(.easeOut(duration: 0.25)) {
                        isExpanded.toggle()
                    }
                }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(ThemeColors.textSecondary)
                        .frame(width: 28, height: 28)
                        .background(ThemeColors.surface2)
                        .cornerRadius(14)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            if isExpanded && hasReport {
                Divider()
                    .opacity(0.15)
                    .padding(.horizontal, 16)
                
                // 报告内容
                VStack(alignment: .leading, spacing: 16) {
                    // 情绪概览
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("情绪概览")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(ThemeColors.textPrimary)
                            
                            Text("•")
                                .foregroundColor(ThemeColors.textSecondary)
                            
                            Text("主导情绪: \(report!.dominantEmotion)")
                                .font(.system(size: 13))
                                .foregroundColor(ThemeColors.textSecondary)
                        }
                        
                        // GitHub风格热力图预览
                        GitHubStyleContributionPreview(intensity: report!.averageValence)
                    }
                    
                    // 摘要文本
                    Text(report!.summary)
                        .font(.system(size: 14))
                        .lineSpacing(5)
                        .foregroundColor(ThemeColors.textPrimary)
                    
                    // 查看详情按钮
                    Button(action: onTapViewDetails) {
                        Text("查看完整周报")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(ThemeColors.accent)
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            } else if !hasReport {
                // 无报告状态
                VStack(spacing: 12) {
                    Text("本周尚未生成周报")
                        .font(.system(size: 14))
                        .foregroundColor(ThemeColors.textSecondary)
                    
                    Text("每周日自动生成，记录越多，分析越准确")
                        .font(.system(size: 12))
                        .foregroundColor(ThemeColors.textSecondary.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            }
        }
        .background(ThemeColors.surface1)
        .cornerRadius(16)
        .shadow(color: ThemeColors.shadow, radius: 4, x: 0, y: 2)
    }
}

// GitHub风格贡献热力图预览组件
struct GitHubStyleContributionPreview: View {
    let intensity: Double // -1 到 1 的值
    
    private func intensityColor(_ value: Double) -> Color {
        let normalizedValue = (value + 1) / 2 // 将 -1 到 1 转换为 0 到 1
        
        if normalizedValue < 0.25 {
            return Color(red: 0.1, green: 0.3, blue: 0.5).opacity(0.5 + normalizedValue)
        } else if normalizedValue < 0.5 {
            return Color(red: 0.1, green: 0.5, blue: 0.7).opacity(0.6 + normalizedValue/2)
        } else if normalizedValue < 0.75 {
            return Color(red: 0.1, green: 0.7, blue: 0.9).opacity(0.7 + normalizedValue/3)
        } else {
            return Color(red: 0.2, green: 0.8, blue: 1.0).opacity(0.8 + normalizedValue/5)
        }
    }
    
    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<7, id: \.self) { index in
                let scaledIntensity = intensity * Double(index + 1) / 7.0
                Rectangle()
                    .fill(intensityColor(scaledIntensity))
                    .frame(width: 15, height: 15)
                    .cornerRadius(2)
            }
            
            Spacer()
            
            // 说明文本
            Text("活跃度")
                .font(.system(size: 12))
                .foregroundColor(ThemeColors.textSecondary)
        }
    }
}


