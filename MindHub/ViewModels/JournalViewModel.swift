import Foundation
import Combine

class JournalViewModel: ObservableObject {
    @Published var entries: [JournalEntry] = []
    @Published var isLoading: Bool = false
    
    private var emotionAnalysisManager = EmotionAnalysisManager()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadEntries()
        
        // 注册重新分析所有日记的通知
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleReanalyzeAllJournals),
            name: NSNotification.Name("ReanalyzeAllJournals"),
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // 响应重新分析所有日记的通知
    @objc private func handleReanalyzeAllJournals() {
        analyzeAllEntries()
    }
    
    // 加载所有日记
    func loadEntries() {
        isLoading = true
        
        // 从本地存储加载日记
        if let savedEntries = UserDefaults.standard.data(forKey: "journalEntries") {
            do {
                let decodedEntries = try JSONDecoder().decode([JournalEntry].self, from: savedEntries)
                DispatchQueue.main.async {
                    self.entries = decodedEntries
                    self.isLoading = false
                    
                    // 对没有情绪唤起度和价效度的条目进行分析
                    self.analyzeMissingEmotionData()
                }
            } catch {
                print("无法解码日记: \(error.localizedDescription)")
                isLoading = false
            }
        } else {
            // 如果没有保存的日记，创建一些示例数据
            createSampleEntries()
            isLoading = false
        }
    }
    
    // 创建示例日记
    private func createSampleEntries() {
        let sampleEntries = [
            JournalEntry(
                title: "美好的一天",
                content: "今天天气很好，我早上去公园散步，感觉很放松。下午见了老朋友，我们一起喝咖啡聊天，分享了各自的近况。",
                date: Date().addingTimeInterval(-86400), // 昨天
                mood: .happy,
                tags: ["散步", "朋友", "咖啡"],
                isFavorite: true,
                arousal: 0.6,
                valence: 0.8
            ),
            JournalEntry(
                title: "工作压力",
                content: "今天工作很忙，有很多项目截止日期即将到来。我觉得有点焦虑，但我尽力保持冷静，一步一步完成任务。明天需要更好地规划时间。",
                date: Date().addingTimeInterval(-172800), // 前天
                mood: .anxious,
                tags: ["工作", "压力", "时间管理"],
                arousal: 0.7,
                valence: 0.3
            ),
            JournalEntry(
                title: "新书推荐",
                content: "今天开始阅读一本新书《思考，快与慢》，这本书讲述了人类思维的两种模式。第一章非常吸引人，期待接下来的内容。",
                date: Date().addingTimeInterval(-259200), // 三天前
                mood: .excited,
                tags: ["阅读", "心理学", "书籍"],
                arousal: 0.8,
                valence: 0.7
            )
        ]
        
        entries = sampleEntries
        saveEntries()
    }
    
    // 保存日记
    private func saveEntries() {
        do {
            let encodedEntries = try JSONEncoder().encode(entries)
            UserDefaults.standard.set(encodedEntries, forKey: "journalEntries")
        } catch {
            print("无法编码日记: \(error.localizedDescription)")
        }
    }
    
    // 添加新日记
    func addEntry(_ entry: JournalEntry) {
        var newEntry = entry
        
        // 如果没有指定情绪唤起度和价效度，则进行计算
        if newEntry.arousal == nil || newEntry.valence == nil {
            let (arousal, valence) = calculateEmotionValues(for: newEntry)
            newEntry.arousal = arousal
            newEntry.valence = valence
        }
        
        entries.insert(newEntry, at: 0)
        saveEntries()
        
        // 执行情感分析
        analyzeEntryEmotions(newEntry)
    }
    
    // 更新日记
    func updateEntry(_ entry: JournalEntry) {
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            var updatedEntry = entry
            
            // 如果内容发生变化，重新计算情绪值
            if entries[index].content != updatedEntry.content {
                let (arousal, valence) = calculateEmotionValues(for: updatedEntry)
                updatedEntry.arousal = arousal
                updatedEntry.valence = valence
                
                // 执行情感分析
                analyzeEntryEmotions(updatedEntry)
            }
            
            entries[index] = updatedEntry
            saveEntries()
        }
    }
    
    // 删除日记
    func deleteEntries(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        saveEntries()
    }
    
    // 切换收藏状态
    func toggleFavorite(for entryID: UUID) {
        if let index = entries.firstIndex(where: { $0.id == entryID }) {
            entries[index].isFavorite.toggle()
            saveEntries()
        }
    }
    
    // 按日期排序
    func sortByDate() {
        entries.sort { $0.date > $1.date }
    }
    
    // 按心情排序
    func sortByMood() {
        entries.sort { $0.mood.rawValue < $1.mood.rawValue }
    }
    
    // 按情感分析结果排序
    func sortByEmotion() {
        entries.sort { entry1, entry2 in
            let emotion1 = entry1.getPrimaryEmotion() ?? ""
            let emotion2 = entry2.getPrimaryEmotion() ?? ""
            return emotion1 < emotion2
        }
    }
    
    // 按唤起度排序
    func sortByArousal() {
        entries.sort { $0.getArousal() > $1.getArousal() }
    }
    
    // 按价效度排序
    func sortByValence() {
        entries.sort { $0.getValence() > $1.getValence() }
    }
    
    // 对单个日记条目进行情感分析
    private func analyzeEntryEmotions(_ entry: JournalEntry) {
        emotionAnalysisManager.analyzeEmotion(text: entry.content)
        
        emotionAnalysisManager.$emotionResults
            .dropFirst()
            .sink { [weak self] results in
                guard let self = self, !results.isEmpty else { return }
                
                // 找到对应的日记并更新
                if let index = self.entries.firstIndex(where: { $0.id == entry.id }) {
                    var updatedEntry = self.entries[index]
                    
                    // 将唤起度和价效度从结果中获取
                    let primaryResult = results.first!
                    updatedEntry.arousal = primaryResult.arousal
                    updatedEntry.valence = primaryResult.valence
                    
                    // 创建情感分析结果数组
                    let analysisResults = results.map { result in
                        EmotionAnalysisResult(
                            emotion: result.emotion,
                            score: result.score,
                            date: Date(),
                            arousal: result.arousal,
                            valence: result.valence
                        )
                    }
                    
                    updatedEntry.emotionAnalysisResults = analysisResults
                    self.entries[index] = updatedEntry
                    self.saveEntries()
                }
            }
            .store(in: &cancellables)
    }
    
    // 分析缺少情绪数据的条目
    private func analyzeMissingEmotionData() {
        let entriesToAnalyze = entries.filter { $0.arousal == nil || $0.valence == nil || $0.emotionAnalysisResults == nil }
        
        for entry in entriesToAnalyze {
            analyzeEntryEmotions(entry)
        }
    }
    
    // 计算情绪唤起度和价效度
    private func calculateEmotionValues(for entry: JournalEntry) -> (arousal: Double, valence: Double) {
        // 首先从心情中获取基本值
        var arousal = entry.mood.arousal
        var valence = entry.mood.valence
        
        // 然后通过文本分析进一步调整
        let textValues = emotionAnalysisManager.analyzeTextArousalValence(text: entry.content)
        
        // 将心情值和文本分析值进行加权平均
        arousal = (arousal * 0.4) + (textValues.arousal * 0.6)
        valence = (valence * 0.4) + (textValues.valence * 0.6)
        
        return (arousal, valence)
    }
    
    // 对所有日记进行情感分析
    func analyzeAllEntries() {
        let contents = entries.map { $0.content }
        
        emotionAnalysisManager.batchAnalyzeEmotions(texts: contents)
        
        // 当情感分析完成时，更新日记中的情感分析结果
        emotionAnalysisManager.$emotionResults
            .dropFirst()
            .sink { [weak self] results in
                guard let self = self else { return }
                
                // 按文本分组结果
                var resultsByText: [String: [EmotionResult]] = [:]
                for result in results {
                    resultsByText[result.text, default: []].append(result)
                }
                
                // 更新每个日记条目
                for (index, entry) in self.entries.enumerated() {
                    if let resultsForEntry = resultsByText[entry.content] {
                        var updatedEntry = entry
                        
                        // 确保有情感分析结果
                        if updatedEntry.emotionAnalysisResults == nil {
                            updatedEntry.emotionAnalysisResults = []
                        }
                        
                        // 将结果转换为EmotionAnalysisResult
                        let analysisResults = resultsForEntry.map { result in
                            EmotionAnalysisResult(
                                emotion: result.emotion,
                                score: result.score,
                                date: Date(),
                                arousal: result.arousal,
                                valence: result.valence
                            )
                        }
                        
                        // 合并新旧结果
                        updatedEntry.emotionAnalysisResults = analysisResults
                        
                        // 更新唤起度和价效度
                        if let primaryResult = resultsForEntry.first {
                            updatedEntry.arousal = primaryResult.arousal
                            updatedEntry.valence = primaryResult.valence
                        }
                        
                        self.entries[index] = updatedEntry
                    }
                }
                
                self.saveEntries()
            }
            .store(in: &cancellables)
    }
    
    // 获取特定日期的日记
    func getEntries(for date: Date) -> [JournalEntry] {
        let calendar = Calendar.current
        return entries.filter { entry in
            calendar.isDate(entry.date, inSameDayAs: date)
        }
    }
    
    // 获取情绪趋势数据
    func getEmotionTrends() -> [String: [Double]] {
        var trends: [String: [Double]] = [:]
        
        // 初始化常见情绪
        let commonEmotions = ["joy", "sadness", "anger", "fear", "surprise", "trust", 
                              "喜悦", "悲伤", "愤怒", "恐惧", "惊讶", "信任"]
        
        for emotion in commonEmotions {
            trends[emotion] = []
        }
        
        // 按日期排序
        let sortedEntries = entries.sorted { $0.date < $1.date }
        
        for entry in sortedEntries {
            if let results = entry.emotionAnalysisResults {
                for result in results {
                    if trends[result.emotion] != nil {
                        trends[result.emotion]?.append(result.score)
                    } else {
                        trends[result.emotion] = [result.score]
                    }
                }
            }
        }
        
        return trends
    }
    
    // 获取日记活跃的天数百分比
    func getActiveJournalingPercentage(for days: Int) -> Double {
        let calendar = Calendar.current
        let today = Date()
        let startDate = calendar.date(byAdding: .day, value: -days, to: today)!
        
        // 收集有日记的日期
        var daysWithEntries = Set<Date>()
        for entry in entries {
            if entry.date >= startDate && entry.date <= today {
                let dayStart = calendar.startOfDay(for: entry.date)
                daysWithEntries.insert(dayStart)
            }
        }
        
        // 计算百分比
        return Double(daysWithEntries.count) / Double(days)
    }
} 