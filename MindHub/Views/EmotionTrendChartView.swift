import SwiftUI
import Charts

struct EmotionTrendChartView: View {
    var entries: [JournalEntry]
    @State private var selectedPeriod: TimePeriod = .week
    
    // 时间段枚举
    enum TimePeriod: String, CaseIterable, Identifiable {
        case week = "周"
        case month = "月"
        case year = "年"
        
        var id: Self { self }
    }
    
    // 计算每个时间段的数据
    private var trendData: [EmotionTrendPoint] {
        let calendar = Calendar.current
        let now = Date()
        
        // 确定时间窗口
        let timeWindow: Int
        let calendarComponent: Calendar.Component
        
        switch selectedPeriod {
        case .week:
            timeWindow = 7
            calendarComponent = .day
        case .month:
            timeWindow = 30
            calendarComponent = .day
        case .year:
            timeWindow = 12
            calendarComponent = .month
        }
        
        // 准备结果数组
        var result: [EmotionTrendPoint] = []
        var valenceByDate: [Date: [Double]] = [:]
        var arousalByDate: [Date: [Double]] = [:]
        
        // 创建日期标记
        for i in 0..<timeWindow {
            let date: Date
            if selectedPeriod == .year {
                let monthsAgo = timeWindow - i - 1
                date = calendar.date(byAdding: .month, value: -monthsAgo, to: now)!
                let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
                valenceByDate[monthStart] = []
                arousalByDate[monthStart] = []
            } else {
                let daysAgo = timeWindow - i - 1
                date = calendar.date(byAdding: .day, value: -daysAgo, to: now)!
                let dayStart = calendar.startOfDay(for: date)
                valenceByDate[dayStart] = []
                arousalByDate[dayStart] = []
            }
        }
        
        // 收集每个时间段的数据
        for entry in entries {
            let date: Date
            if selectedPeriod == .year {
                date = calendar.date(from: calendar.dateComponents([.year, .month], from: entry.date))!
            } else {
                date = calendar.startOfDay(for: entry.date)
            }
            
            if valenceByDate[date] != nil {
                valenceByDate[date]?.append(entry.getValence())
                arousalByDate[date]?.append(entry.getArousal())
            }
        }
        
        // 计算平均值并创建数据点
        for (date, valences) in valenceByDate.sorted(by: { $0.key < $1.key }) {
            let arousal = arousalByDate[date] ?? []
            let averageValence = valences.isEmpty ? 0.5 : valences.reduce(0, +) / Double(valences.count)
            let averageArousal = arousal.isEmpty ? 0.5 : arousal.reduce(0, +) / Double(arousal.count)
            
            let entryCount = valences.count
            
            let formatter = DateFormatter()
            formatter.dateFormat = selectedPeriod == .year ? "yyyy年M月" : "M月d日"
            let formattedDate = formatter.string(from: date)
            
            result.append(EmotionTrendPoint(
                date: date,
                displayDate: formattedDate,
                valence: averageValence,
                arousal: averageArousal,
                count: entryCount
            ))
        }
        
        return result
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // 时间选择器
            Picker("时间段", selection: $selectedPeriod) {
                ForEach(TimePeriod.allCases) { period in
                    Text(period.rawValue).tag(period)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            if trendData.isEmpty || !trendData.contains(where: { $0.count > 0 }) {
                Text("尚无情绪趋势数据")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 40)
            } else {
                Chart {
                    ForEach(trendData) { point in
                        LineMark(
                            x: .value("日期", point.displayDate),
                            y: .value("情绪价效度", point.valence)
                        )
                        .foregroundStyle(.blue)
                        .symbol {
                            Circle()
                                .fill(.blue)
                                .frame(width: 8, height: 8)
                        }
                        
                        LineMark(
                            x: .value("日期", point.displayDate),
                            y: .value("情绪唤起度", point.arousal)
                        )
                        .foregroundStyle(.orange)
                        .symbol {
                            Circle()
                                .fill(.orange)
                                .frame(width: 8, height: 8)
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading, values: [0.2, 0.4, 0.6, 0.8]) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let doubleValue = value.as(Double.self) {
                                Text(String(format: "%.1f", doubleValue))
                                    .font(.caption)
                            }
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel {
                            if let strValue = value.as(String.self) {
                                Text(strValue)
                                    .font(.caption)
                                    .fontWeight(.light)
                            }
                        }
                    }
                }
                .frame(height: 220)
                .padding(.horizontal)
                
                // 图例
                HStack(spacing: 20) {
                    HStack {
                        Circle()
                            .fill(.blue)
                            .frame(width: 8, height: 8)
                        Text("价效度")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Circle()
                            .fill(.orange)
                            .frame(width: 8, height: 8)
                        Text("唤起度")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if let averageValence = averageValence(), let averageArousal = averageArousal() {
                        Text("平均价效: \(String(format: "%.2f", averageValence))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("平均唤起: \(String(format: "%.2f", averageArousal))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // 计算平均价效度
    private func averageValence() -> Double? {
        let validPoints = trendData.filter { $0.count > 0 }
        guard !validPoints.isEmpty else { return nil }
        return validPoints.reduce(0) { $0 + $1.valence } / Double(validPoints.count)
    }
    
    // 计算平均唤起度
    private func averageArousal() -> Double? {
        let validPoints = trendData.filter { $0.count > 0 }
        guard !validPoints.isEmpty else { return nil }
        return validPoints.reduce(0) { $0 + $1.arousal } / Double(validPoints.count)
    }
}

// 情绪趋势数据点
struct EmotionTrendPoint: Identifiable {
    let id = UUID()
    let date: Date
    let displayDate: String
    let valence: Double
    let arousal: Double
    let count: Int
}

struct EmotionTrendChartView_Previews: PreviewProvider {
    static var previews: some View {
        EmotionTrendChartView(entries: [])
            .frame(height: 250)
            .padding()
    }
} 