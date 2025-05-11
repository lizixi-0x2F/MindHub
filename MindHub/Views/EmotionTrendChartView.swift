import SwiftUI
import Charts

// 主视图
struct EmotionTrendChartView: View {
    var entries: [JournalEntry]
    var analysisResults: [UUID: EmotionResult]
    var weekNumber: Int = 0
    
    @State private var selectedTimeRange: TimeRange = .week
    @State private var chartData: [(date: Date, valence: Double, arousal: Double, dominantEmotion: String)] = []
    
    // 获取日期范围的格式化字符串
    private var dateRangeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        
        if let firstDate = chartData.first?.date,
           let lastDate = chartData.last?.date {
            return "\(formatter.string(from: firstDate)) - \(formatter.string(from: lastDate))"
        }
        return ""
    }
    
    // 根据屏幕高度获取合适的图表高度
    private func adaptiveChartHeight() -> CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        if screenHeight < 600 {
            return 140  // 非常小的屏幕（SE等）
        } else if screenHeight < 700 {
            return 170  // 小屏幕
        } else if screenHeight < 800 {
            return 200  // 中等屏幕
        } else {
            return 220  // 大屏幕
        }
    }
    
    // 判断是否为小屏幕设备
    private var isSmallDevice: Bool {
        return UIScreen.main.bounds.width < 375
    }
    
    var body: some View {
        VStack(spacing: 5) {
            if weekNumber == 0 {
                EmotionTimeRangeSelectorView(selectedTimeRange: $selectedTimeRange)
                    .padding(.bottom, 5)
            }
            
            if chartData.isEmpty {
                EmotionChartEmptyView()
            } else {
                VStack(spacing: isSmallDevice ? 5 : 15) {
                    // 效价趋势（积极/消极）
                    EmotionValenceChartView(
                        chartData: chartData,
                        dateRangeText: dateRangeText,
                        selectedTimeRange: selectedTimeRange
                    )
                    .frame(height: adaptiveChartHeight())
                    
                    // 唤醒度趋势（活跃/平静）
                    EmotionArousalChartView(
                        chartData: chartData, 
                        selectedTimeRange: selectedTimeRange
                    )
                    .frame(height: adaptiveChartHeight())
                }
            }
        }
        .padding(10)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .onAppear {
            loadData()
        }
        .onChange(of: selectedTimeRange) { oldValue, newValue in
            loadData()
        }
        .onChange(of: analysisResults) { oldValue, newValue in
            loadData()
        }
    }
    
    private func loadData() {
        // 过滤有情绪分析结果的日记
        let entriesWithResults = entries.filter { entry in
            analysisResults[entry.id] != nil
        }
        
        if entriesWithResults.isEmpty {
            chartData = []
            return
        }
        
        let calendar = Calendar.current
        let now = Date()
        var filteredEntries: [JournalEntry]
        
        // 根据所选时间范围过滤日记
        switch selectedTimeRange {
        case .week:
            // 获取过去一周的日记
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: now)!
            filteredEntries = entriesWithResults.filter { $0.date >= weekAgo }
            
        case .month:
            // 获取过去一个月的日记
            let monthAgo = calendar.date(byAdding: .month, value: -1, to: now)!
            filteredEntries = entriesWithResults.filter { $0.date >= monthAgo }
            
        case .year:
            // 获取过去一年的日记
            let yearAgo = calendar.date(byAdding: .year, value: -1, to: now)!
            filteredEntries = entriesWithResults.filter { $0.date >= yearAgo }
        }
        
        // 如果指定了周数，则获取指定周的日记
        if weekNumber > 0 {
            let currentWeekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
            let targetWeekStart = calendar.date(byAdding: .weekOfYear, value: -weekNumber, to: currentWeekStart)!
            let targetWeekEnd = calendar.date(byAdding: .day, value: 6, to: targetWeekStart)!
            
            filteredEntries = entriesWithResults.filter { entry in
                entry.date >= targetWeekStart && entry.date <= targetWeekEnd
            }
        }
        
        // 按日期排序
        let sortedEntries = filteredEntries.sorted { $0.date < $1.date }
        
        // 转换为图表数据格式
        chartData = sortedEntries.compactMap { entry in
            if let result = analysisResults[entry.id] {
                return (date: entry.date, valence: result.valence, arousal: result.arousal, dominantEmotion: result.dominantEmotion)
            }
            return nil
        }
    }
}

// 时间范围选择器组件
struct EmotionTimeRangeSelectorView: View {
    @Binding var selectedTimeRange: TimeRange
    
    // 根据屏幕尺寸计算适当的间距和内边距
    private var horizontalSpacing: CGFloat {
        return UIScreen.main.bounds.width < 375 ? 12 : 20 // 小屏幕减少间距
    }
    
    private var buttonPadding: (h: CGFloat, v: CGFloat) {
        let isSmallScreen = UIScreen.main.bounds.width < 375
        return (isSmallScreen ? 14 : 20, isSmallScreen ? 6 : 8)
    }
    
    var body: some View {
        HStack(spacing: horizontalSpacing) {
            ForEach([TimeRange.week, TimeRange.month, TimeRange.year], id: \.self) { range in
                Button(action: {
                    selectedTimeRange = range
                }) {
                    Text(range.rawValue)
                        .font(.system(size: UIScreen.main.bounds.width < 375 ? 12 : 14))
                        .fontWeight(selectedTimeRange == range ? .bold : .regular)
                        .foregroundColor(selectedTimeRange == range ? .white : .secondary)
                        .padding(.horizontal, buttonPadding.h)
                        .padding(.vertical, buttonPadding.v)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(selectedTimeRange == range ? Color.accentColor : Color(.secondarySystemBackground))
                        )
                }
            }
        }
    }
}

// 效价趋势图表组件
struct EmotionValenceChartView: View {
    let chartData: [(date: Date, valence: Double, arousal: Double, dominantEmotion: String)]
    let dateRangeText: String
    let selectedTimeRange: TimeRange
    
    // 判断是否为小屏幕设备
    private var isSmallDevice: Bool {
        return UIScreen.main.bounds.width < 375
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("积极/消极情绪变化")
                    .font(.system(size: isSmallDevice ? 12 : 14, weight: .medium))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(dateRangeText)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 5)
            
            // 健康应用风格折线图
            ValenceChartContent(chartData: chartData, selectedTimeRange: selectedTimeRange)
                .padding(.bottom, 5)
                .padding(.top, 5)
        }
    }
}

// 唤醒度趋势图表组件
struct EmotionArousalChartView: View {
    let chartData: [(date: Date, valence: Double, arousal: Double, dominantEmotion: String)]
    let selectedTimeRange: TimeRange
    
    // 判断是否为小屏幕设备
    private var isSmallDevice: Bool {
        return UIScreen.main.bounds.width < 375
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("活跃/平静情绪变化")
                .font(.system(size: isSmallDevice ? 12 : 14, weight: .medium))
                .foregroundColor(.primary)
                .padding(.bottom, 5)
            
            // 健康应用风格折线图
            ArousalChartContent(chartData: chartData, selectedTimeRange: selectedTimeRange)
                .padding(.bottom, 5)
                .padding(.top, 5)
        }
    }
}

// 效价趋势图表内容
struct ValenceChartContent: View {
    let chartData: [(date: Date, valence: Double, arousal: Double, dominantEmotion: String)]
    let selectedTimeRange: TimeRange
    
    // 添加格式化坐标轴日期的函数
    private func formatAxisDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        
        if selectedTimeRange == .week {
            // 周视图显示日期
            formatter.dateFormat = "d日"
        } else if selectedTimeRange == .month {
            // 月视图显示"周X"
            formatter.dateFormat = "d日"
        } else {
            // 年视图显示月份
            formatter.dateFormat = "M月"
        }
        
        return formatter.string(from: date)
    }
    
    var body: some View {
        Chart {
            ForEach(chartData.indices, id: \.self) { index in
                let item = chartData[index]
                
                LineMark(
                    x: .value("日期", item.date),
                    y: .value("积极度", item.valence)
                )
                .foregroundStyle(Color.green.gradient)
                .symbol {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                }
                .lineStyle(StrokeStyle(lineWidth: 2))
                
                PointMark(
                    x: .value("日期", item.date),
                    y: .value("积极度", item.valence)
                )
                .foregroundStyle(Color.green)
                .symbolSize(CGSize(width: 10, height: 10))
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic) { value in
                if let date = value.as(Date.self) {
                    AxisValueLabel {
                        Text(formatAxisDate(date))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading, values: [-1.0, 0.0, 1.0]) { value in
                AxisGridLine()
                
                if let val = value.as(Double.self) {
                    AxisValueLabel {
                        if val == 1.0 {
                            Text("积极")
                        } else if val == 0.0 {
                            Text("中性")
                        } else {
                            Text("消极")
                        }
                    }
                }
            }
        }
        .chartYScale(domain: -1...1)
    }
}

// 唤醒度趋势图表内容
struct ArousalChartContent: View {
    let chartData: [(date: Date, valence: Double, arousal: Double, dominantEmotion: String)]
    let selectedTimeRange: TimeRange
    
    // 添加格式化坐标轴日期的函数
    private func formatAxisDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        
        if selectedTimeRange == .week {
            // 周视图显示日期
            formatter.dateFormat = "d日"
        } else if selectedTimeRange == .month {
            // 月视图显示"周X"
            formatter.dateFormat = "d日"
        } else {
            // 年视图显示月份
            formatter.dateFormat = "M月"
        }
        
        return formatter.string(from: date)
    }
    
    var body: some View {
        Chart {
            ForEach(chartData.indices, id: \.self) { index in
                let item = chartData[index]
                
                LineMark(
                    x: .value("日期", item.date),
                    y: .value("活跃度", item.arousal)
                )
                .foregroundStyle(Color.blue.gradient)
                .symbol {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 8, height: 8)
                }
                .lineStyle(StrokeStyle(lineWidth: 2))
                
                PointMark(
                    x: .value("日期", item.date),
                    y: .value("活跃度", item.arousal)
                )
                .foregroundStyle(Color.blue)
                .symbolSize(CGSize(width: 10, height: 10))
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic) { value in
                if let date = value.as(Date.self) {
                    AxisValueLabel {
                        Text(formatAxisDate(date))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading, values: [-1.0, 0.0, 1.0]) { value in
                AxisGridLine()
                
                if let val = value.as(Double.self) {
                    AxisValueLabel {
                        if val == 1.0 {
                            Text("活跃")
                        } else if val == 0.0 {
                            Text("中等")
                        } else {
                            Text("平静")
                        }
                    }
                }
            }
        }
        .chartYScale(domain: -1...1)
    }
}

// 无数据视图
struct EmotionChartEmptyView: View {
    var body: some View {
        let height: CGFloat = UIScreen.main.bounds.height < 700 ? 90 : 120
        
        VStack {
            Spacer()
            Text("暂无情绪数据")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            Spacer()
        }
        .frame(height: height)
    }
}

struct EmotionTrendChartView_Previews: PreviewProvider {
    // 创建示例日记数据
    static var sampleEntries: [JournalEntry] = [
        JournalEntry(
            id: UUID(),
            title: "今天很开心",
            content: "今天是个愉快的一天，遇到了很多有趣的事情。",
            date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
            mood: .happy
        ),
        JournalEntry(
            id: UUID(),
            title: "工作压力大",
            content: "今天工作遇到了很多问题，感到有些沮丧。",
            date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
            mood: .sad
        ),
        JournalEntry(
            id: UUID(),
            title: "放松的一天",
            content: "周末休息，看了一本好书，很放松。",
            date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
            mood: .relaxed
        )
    ]
    
    static var previews: some View {
        EmotionTrendChartView(
            entries: sampleEntries,
            analysisResults: [
                sampleEntries[0].id: EmotionResult(valence: 0.7, arousal: 0.5, dominantEmotion: "喜悦"),
                sampleEntries[1].id: EmotionResult(valence: -0.3, arousal: 0.8, dominantEmotion: "悲伤"),
                sampleEntries[2].id: EmotionResult(valence: 0.2, arousal: -0.1, dominantEmotion: "平静")
            ]
        )
        .environmentObject(JournalViewModel())
        .environmentObject(AppSettings())
        .preferredColorScheme(.dark)
        .padding()
        .background(Color.black)
    }
} 