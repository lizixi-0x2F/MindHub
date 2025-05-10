import SwiftUI
import Charts

struct EmotionAnalysisView: View {
    @EnvironmentObject var journalViewModel: JournalViewModel
    @EnvironmentObject var emotionAnalysisManager: EmotionAnalysisManager
    
    @State private var selectedTimeRange: TimeRange = .week
    @State private var textToAnalyze = ""
    @State private var isAnalyzing = false
    @State private var dataLoaded = false // 添加数据加载状态
    
    var body: some View {
        NavigationView {
            ScrollView {
                if dataLoaded {
                    VStack(alignment: .leading, spacing: 20) {
                        // 时间范围选择器
                        TimeRangePicker(selectedRange: $selectedTimeRange)
                            .padding(.horizontal)
                        
                        // 情绪趋势图表
                        EmotionTrendsChart(trends: journalViewModel.getEmotionTrends(), timeRange: selectedTimeRange)
                            .frame(height: 250)
                            .padding(.horizontal)
                        
                        Divider()
                            .padding(.horizontal)
                        
                        // 实时情感分析
                        VStack(alignment: .leading, spacing: 12) {
                            Text("实时情感分析")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            TextEditor(text: $textToAnalyze)
                                .frame(height: 120)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                .padding(.horizontal)
                            
                            Button(action: {
                                analyzeText()
                            }) {
                                HStack {
                                    Text("分析")
                                        .fontWeight(.semibold)
                                    
                                    if isAnalyzing {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle())
                                            .padding(.leading, 5)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            .disabled(textToAnalyze.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isAnalyzing)
                            .padding(.horizontal)
                        }
                        
                        // 情感分析结果
                        if !emotionAnalysisManager.emotionResults.isEmpty {
                            Divider()
                                .padding(.horizontal)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Text("分析结果")
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                ForEach(emotionAnalysisManager.emotionResults.prefix(5)) { result in
                                    EmotionResultRow(result: result)
                                }
                            }
                            .padding(.bottom)
                        }
                        
                        // 添加底部间距
                        Spacer()
                            .frame(height: 30)
                    }
                    .padding(.vertical)
                } else {
                    // 显示加载状态
                    VStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(1.5)
                        
                        Text("初始化情绪分析...")
                            .font(.headline)
                            .padding(.top, 20)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                }
            }
            .navigationTitle("情绪分析")
            .onAppear {
                // 安全地初始化数据
                initializeData()
            }
        }
    }
    
    // 初始化数据
    private func initializeData() {
        // 确保日记数据已加载
        journalViewModel.loadEntries()
        
        // 检查是否需要对所有日记进行情感分析
        checkForAnalysisNeeded()
        
        // 短暂延迟后标记为已加载
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            dataLoaded = true
        }
    }
    
    // 检查是否需要进行情感分析
    private func checkForAnalysisNeeded() {
        let entriesNeedingAnalysis = journalViewModel.entries.filter { entry in
            return entry.emotionAnalysisResults == nil || entry.emotionAnalysisResults!.isEmpty
        }
        
        if !entriesNeedingAnalysis.isEmpty {
            journalViewModel.analyzeAllEntries()
        }
    }
    
    // 分析当前输入的文本
    private func analyzeText() {
        guard !textToAnalyze.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        isAnalyzing = true
        
        emotionAnalysisManager.analyzeEmotion(text: textToAnalyze)
        
        // 监听分析完成
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isAnalyzing = false
        }
    }
}

// 时间范围选择器
struct TimeRangePicker: View {
    @Binding var selectedRange: TimeRange
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(TimeRange.allCases, id: \.self) { range in
                    Button(action: {
                        selectedRange = range
                    }) {
                        Text(range.displayName)
                            .font(.subheadline)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(selectedRange == range ? Color.blue : Color.gray.opacity(0.2))
                            .foregroundColor(selectedRange == range ? .white : .primary)
                            .cornerRadius(20)
                    }
                }
            }
        }
    }
}

// 情绪结果行
struct EmotionResultRow: View {
    let result: EmotionResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(result.emotion)
                    .font(.headline)
                
                Spacer()
                
                Text(String(format: "%.1f%%", result.score * 100))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            ProgressView(value: result.score)
                .progressViewStyle(LinearProgressViewStyle(tint: colorForEmotion(result.emotion)))
        }
        .padding(.horizontal)
        .padding(.vertical, 5)
    }
    
    // 根据情感类型返回对应颜色
    private func colorForEmotion(_ emotion: String) -> Color {
        let emotion = emotion.lowercased()
        
        if emotion.contains("joy") || emotion.contains("happiness") || emotion.contains("喜悦") || emotion.contains("开心") {
            return .green
        } else if emotion.contains("sadness") || emotion.contains("悲伤") {
            return .blue
        } else if emotion.contains("anger") || emotion.contains("愤怒") {
            return .red
        } else if emotion.contains("fear") || emotion.contains("恐惧") {
            return .purple
        } else if emotion.contains("surprise") || emotion.contains("惊讶") {
            return .orange
        } else if emotion.contains("disgust") || emotion.contains("厌恶") {
            return .brown
        } else if emotion.contains("neutral") || emotion.contains("中性") {
            return .gray
        } else if emotion.contains("trust") || emotion.contains("信任") {
            return .cyan
        } else {
            return .indigo
        }
    }
}

// 情绪趋势图表
struct EmotionTrendsChart: View {
    let trends: [String: [Double]]
    let timeRange: TimeRange
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("情绪趋势")
                .font(.headline)
            
            if !trends.isEmpty && trends.values.contains(where: { !$0.isEmpty }) {
                Chart {
                    ForEach(safeFilteredTrends.keys.sorted(), id: \.self) { emotion in
                        if let values = safeFilteredTrends[emotion], !values.isEmpty {
                            ForEach(Array(values.enumerated()), id: \.offset) { index, value in
                                LineMark(
                                    x: .value("日期", index),
                                    y: .value("情感分数", value)
                                )
                                .foregroundStyle(by: .value("情感", emotion))
                            }
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .automatic)
                }
                .chartYAxis {
                    AxisMarks(values: .automatic)
                }
                .chartXAxisLabel("时间")
                .chartYAxisLabel("情感分数")
                .chartLegend(position: .bottom, alignment: .center, spacing: 10)
            } else {
                Text("没有足够的数据显示情绪趋势")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 50)
            }
        }
    }
    
    // 安全过滤趋势数据，避免空值和潜在崩溃
    private var safeFilteredTrends: [String: [Double]] {
        var result: [String: [Double]] = [:]
        
        // 首先筛选出有数据的情感
        let emotionsWithData = trends.filter { !$0.value.isEmpty }
        
        // 如果没有数据，返回空结果
        if emotionsWithData.isEmpty {
            return result
        }
        
        // 根据时间范围限制数据点数量
        for (emotion, values) in emotionsWithData {
            if values.isEmpty {
                continue
            }
            
            let limitedValues: [Double]
            
            switch timeRange {
            case .day:
                limitedValues = Array(values.suffix(min(24, values.count))) // 最近24小时
            case .week:
                limitedValues = Array(values.suffix(min(7, values.count))) // 最近7天
            case .month:
                limitedValues = Array(values.suffix(min(30, values.count))) // 最近30天
            case .year:
                // 对于年度视图，我们可能需要对数据进行聚合
                if values.count <= 12 {
                    limitedValues = values
                } else {
                    let chunkSize = max(1, values.count / 12) // 每月一个数据点
                    limitedValues = stride(from: 0, to: values.count, by: chunkSize).map { start in
                        let end = min(start + chunkSize, values.count)
                        let chunk = values[start..<end]
                        return chunk.reduce(0, +) / Double(chunk.count)
                    }
                }
            }
            
            // 只显示前5个情感，避免图表过于拥挤
            if result.count < 5 && !limitedValues.isEmpty {
                result[emotion] = limitedValues
            }
        }
        
        return result
    }
}

// 时间范围枚举
enum TimeRange: CaseIterable {
    case day
    case week
    case month
    case year
    
    var displayName: String {
        switch self {
        case .day: return "今天"
        case .week: return "本周"
        case .month: return "本月"
        case .year: return "今年"
        }
    }
}

struct EmotionAnalysisView_Previews: PreviewProvider {
    static var previews: some View {
        EmotionAnalysisView()
            .environmentObject(JournalViewModel())
            .environmentObject(EmotionAnalysisManager())
    }
} 