import SwiftUI
import Charts

struct HealthDataView: View {
    @EnvironmentObject var healthKitManager: HealthKitManager
    
    @State private var selectedTimeRange: TimeRange = .week
    @State private var selectedMetric: HealthMetric = .heartRate
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 20) {
                    // 指标选择器
                    HealthMetricPicker(selectedMetric: $selectedMetric)
                        .padding(.horizontal)
                    
                    // 时间范围选择器
                    TimeRangePicker(selectedRange: $selectedTimeRange)
                        .padding(.horizontal)
                    
                    // 健康数据图表
                    HealthDataChart(
                        metric: selectedMetric,
                        timeRange: selectedTimeRange,
                        healthKitManager: healthKitManager
                    )
                    .frame(height: 250)
                    .padding(.horizontal)
                    
                    // 健康指标统计
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        HealthStatsCard(
                            title: "平均心率",
                            value: String(format: "%.0f", healthKitManager.dailyHeartRateAverage),
                            unit: "bpm",
                            icon: "heart.fill",
                            color: .red
                        )
                        
                        HealthStatsCard(
                            title: "平均心率变异性",
                            value: String(format: "%.0f", healthKitManager.dailyHRVAverage),
                            unit: "ms",
                            icon: "waveform.path.ecg",
                            color: .purple
                        )
                        
                        HealthStatsCard(
                            title: "总步数",
                            value: "\(healthKitManager.dailyStepCount)",
                            unit: "步",
                            icon: "figure.walk",
                            color: .green
                        )
                        
                        HealthStatsCard(
                            title: "消耗卡路里",
                            value: String(format: "%.0f", healthKitManager.dailyActiveEnergy),
                            unit: "kcal",
                            icon: "flame.fill",
                            color: .orange
                        )
                    }
                    .padding(.horizontal)
                    
                    // 健康提示
                    VStack(alignment: .leading, spacing: 10) {
                        Text("健康提示")
                            .font(.headline)
                        
                        Text(healthTip)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    // 添加底部间距确保滑动时显示完整
                    Spacer()
                        .frame(height: 30)
                }
                .padding(.vertical)
            }
            .navigationTitle("健康数据")
            .refreshable {
                healthKitManager.fetchLatestHealthData()
            }
            .onAppear {
                healthKitManager.fetchLatestHealthData()
            }
        }
    }
    
    // 根据健康数据提供健康提示
    private var healthTip: String {
        let tips = [
            "保持规律的睡眠时间有助于改善心率变异性，减轻压力。",
            "每天坚持30分钟中等强度的有氧运动可以显著提高心脏健康。",
            "深呼吸练习可以帮助降低心率，缓解压力和焦虑。",
            "每天喝足够的水对维持健康的心脏功能至关重要。",
            "保持积极的社交活动可以减轻压力，改善心理健康。",
            "多吃富含omega-3脂肪酸的食物，如鱼类，有助于心脏健康。",
            "每天进行正念冥想可以减轻压力，提高心率变异性。"
        ]
        
        // 根据健康指标提供特定提示
        if healthKitManager.dailyHeartRateAverage > 80 {
            return "您的平均心率略高。考虑增加放松活动，减少咖啡因摄入，并确保充分休息。"
        } else if healthKitManager.dailyStepCount < 5000 {
            return "您今天的步数低于建议水平。尝试增加日常活动，如步行上下班或午休时散步。"
        } else if healthKitManager.lastNightSleepHours < 7 {
            return "您昨晚的睡眠时间不足。尝试保持规律的睡眠时间表，睡前减少屏幕使用。"
        }
        
        // 随机返回一般性健康提示
        return tips.randomElement() ?? tips[0]
    }
}

// 健康指标选择器
struct HealthMetricPicker: View {
    @Binding var selectedMetric: HealthMetric
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(HealthMetric.allCases, id: \.self) { metric in
                    Button(action: {
                        selectedMetric = metric
                    }) {
                        HStack {
                            Image(systemName: metric.icon)
                                .foregroundColor(selectedMetric == metric ? .white : metric.color)
                            
                            Text(metric.displayName)
                                .font(.subheadline)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(selectedMetric == metric ? metric.color : metric.color.opacity(0.1))
                        .foregroundColor(selectedMetric == metric ? .white : .primary)
                        .cornerRadius(20)
                    }
                }
            }
        }
    }
}

// 健康统计卡片
struct HealthStatsCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.white)
                    .padding(8)
                    .background(color)
                    .cornerRadius(8)
                
                Text(title)
                    .font(.headline)
            }
            
            HStack(alignment: .firstTextBaseline) {
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(unit)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

// 健康数据图表
struct HealthDataChart: View {
    let metric: HealthMetric
    let timeRange: TimeRange
    let healthKitManager: HealthKitManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(metric.displayName + "趋势")
                .font(.headline)
            
            // 这里只是一个模拟图表，实际应用中应该从 HealthKitManager 中获取数据
            Chart {
                ForEach(generateDummyData(), id: \.id) { point in
                    LineMark(
                        x: .value("时间", point.date),
                        y: .value(metric.displayName, point.value)
                    )
                    .foregroundStyle(metric.color)
                    
                    AreaMark(
                        x: .value("时间", point.date),
                        y: .value(metric.displayName, point.value)
                    )
                    .foregroundStyle(
                        .linearGradient(
                            colors: [metric.color.opacity(0.3), metric.color.opacity(0.01)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
            }
            .chartXAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisValueLabel()
                        .font(.caption)
                }
            }
            .chartYAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisValueLabel()
                        .font(.caption)
                }
            }
            
            HStack {
                if metric == .heartRate {
                    Text("单位: bpm")
                } else if metric == .hrv {
                    Text("单位: ms")
                } else if metric == .steps {
                    Text("单位: 步")
                } else if metric == .calories {
                    Text("单位: kcal")
                }
                
                Spacer()
                
                Text("过去\(timeRangeText)的数据")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
    }
    
    // 根据时间范围返回相应文本
    private var timeRangeText: String {
        switch timeRange {
        case .day: return "24小时"
        case .week: return "一周"
        case .month: return "一个月"
        case .year: return "一年"
        }
    }
    
    // 生成模拟数据
    private func generateDummyData() -> [DataPoint] {
        let count: Int
        switch timeRange {
        case .day: count = 24
        case .week: count = 7
        case .month: count = 30
        case .year: count = 12
        }
        
        var points: [DataPoint] = []
        let calendar = Calendar.current
        let now = Date()
        
        for i in 0..<count {
            var dateComponent: DateComponents
            var date: Date
            
            switch timeRange {
            case .day:
                dateComponent = DateComponents(hour: -i)
                date = calendar.date(byAdding: dateComponent, to: now)!
            case .week:
                dateComponent = DateComponents(day: -i)
                date = calendar.date(byAdding: dateComponent, to: now)!
            case .month:
                dateComponent = DateComponents(day: -i)
                date = calendar.date(byAdding: dateComponent, to: now)!
            case .year:
                dateComponent = DateComponents(month: -i)
                date = calendar.date(byAdding: dateComponent, to: now)!
            }
            
            var value: Double
            switch metric {
            case .heartRate:
                value = Double.random(in: 60...100)
            case .hrv:
                value = Double.random(in: 30...80)
            case .steps:
                value = Double.random(in: 3000...12000)
            case .calories:
                value = Double.random(in: 200...800)
            }
            
            points.append(DataPoint(id: UUID(), date: date, value: value))
        }
        
        return points.reversed()
    }
}

// 数据点结构
struct DataPoint: Identifiable {
    let id: UUID
    let date: Date
    let value: Double
}

// 健康指标枚举
enum HealthMetric: String, CaseIterable {
    case heartRate
    case hrv
    case steps
    case calories
    
    var displayName: String {
        switch self {
        case .heartRate: return "心率"
        case .hrv: return "心率变异性"
        case .steps: return "步数"
        case .calories: return "卡路里"
        }
    }
    
    var icon: String {
        switch self {
        case .heartRate: return "heart.fill"
        case .hrv: return "waveform.path.ecg"
        case .steps: return "figure.walk"
        case .calories: return "flame.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .heartRate: return .red
        case .hrv: return .purple
        case .steps: return .green
        case .calories: return .orange
        }
    }
}

struct HealthDataView_Previews: PreviewProvider {
    static var previews: some View {
        HealthDataView()
            .environmentObject(HealthKitManager())
    }
} 