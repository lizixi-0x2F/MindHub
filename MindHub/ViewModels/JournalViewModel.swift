import Foundation
import SwiftUI
import Combine

// 导入EmotionAnalysisService以便在代码中使用
@MainActor
class JournalViewModel: ObservableObject, Sendable {
    @Published var entries: [JournalEntry] = []
    @Published var emotionAnalysisResults: [UUID: EmotionResult] = [:]
    @Published var weeklyReports: [WeeklyReport] = []
    
    // 私有属性，引用EmotionAnalysisService
    private let emotionService = EmotionAnalysisService.shared
    
    init() {
        loadEntries()
    }
    
    // 从本地存储加载日记
    func loadEntries() {
        // 模拟数据
        if entries.isEmpty {
            let calendar = Calendar.current
            let today = Date()
            
            // 创建过去两周的示例日记
            entries = [
                // 第1天（前13天）
                JournalEntry(
                    id: UUID(),
                    title: "工作压力",
                    content: "今天工作压力很大，项目快要截止了，感觉自己很紧张和焦虑。希望能够按时完成所有任务，否则可能会影响团队的进度。",
                    date: calendar.date(byAdding: .day, value: -13, to: today)!,
                    mood: .anxious,
                    tags: ["工作", "压力", "截止日期"],
                    isFavorite: false
                ),
                
                // 第2天（前12天）
                JournalEntry(
                    id: UUID(),
                    title: "与朋友聚会",
                    content: "今晚和朋友们一起吃了晚餐，聊了很多过去的事情，感觉非常开心。这样的聚会真的能让我放松下来，忘记工作中的烦恼。",
                    date: calendar.date(byAdding: .day, value: -12, to: today)!,
                    mood: .happy,
                    tags: ["朋友", "聚会", "放松"],
                    isFavorite: true
                ),
                
                // 第3天（前11天）
                JournalEntry(
                    id: UUID(),
                    title: "项目失败",
                    content: "今天我们的提案被客户拒绝了，感到非常失望。投入了这么多时间和精力，结果却不尽人意。需要好好反思一下哪里出了问题。",
                    date: calendar.date(byAdding: .day, value: -11, to: today)!,
                    mood: .sad,
                    tags: ["工作", "失败", "反思"],
                    isFavorite: false
                ),
                
                // 第4天（前10天）
                JournalEntry(
                    id: UUID(),
                    title: "愤怒的一天",
                    content: "今天在路上遇到了非常不礼貌的司机，差点发生事故。这种人真的让人生气，完全不考虑他人的安全。需要找个方式平复一下自己的情绪。",
                    date: calendar.date(byAdding: .day, value: -10, to: today)!,
                    mood: .angry,
                    tags: ["交通", "愤怒", "情绪管理"],
                    isFavorite: false
                ),
                
                // 第5天（前9天）
                JournalEntry(
                    id: UUID(),
                    title: "平静的阅读时光",
                    content: "今天下午在家里安静地读了几个小时的书，感觉非常平静和充实。这种独处的时光真的很珍贵，能够让我沉浸在自己的世界里。",
                    date: calendar.date(byAdding: .day, value: -9, to: today)!,
                    mood: .relaxed,
                    tags: ["阅读", "平静", "独处"],
                    isFavorite: true
                ),
                
                // 第6天（前8天）
                JournalEntry(
                    id: UUID(),
                    title: "新项目开始",
                    content: "今天开始了一个新项目，团队成员都很积极，我也对这个项目充满信心。希望这次能够取得好的成果，弥补上次的失败。",
                    date: calendar.date(byAdding: .day, value: -8, to: today)!,
                    mood: .excited,
                    tags: ["工作", "新项目", "团队"],
                    isFavorite: false
                ),
                
                // 第7天（前7天）
                JournalEntry(
                    id: UUID(),
                    title: "健康担忧",
                    content: "最近总是感觉疲惫，今天预约了医生进行检查。等待结果的过程真的很让人焦虑，希望不是什么严重的问题。需要多注意休息。",
                    date: calendar.date(byAdding: .day, value: -7, to: today)!,
                    mood: .anxious,
                    tags: ["健康", "焦虑", "医疗"],
                    isFavorite: false
                ),
                
                // 第8天（前6天）
                JournalEntry(
                    id: UUID(),
                    title: "家庭聚餐",
                    content: "今天和家人一起吃了晚餐，妈妈做了我最爱吃的菜。和家人在一起的时光总是那么温馨和放松，真希望能够多陪陪他们。",
                    date: calendar.date(byAdding: .day, value: -6, to: today)!,
                    mood: .happy,
                    tags: ["家庭", "晚餐", "亲情"],
                    isFavorite: true
                ),
                
                // 第9天（前5天）
                JournalEntry(
                    id: UUID(),
                    title: "医生诊断结果",
                    content: "拿到了医生的诊断结果，只是普通的疲劳，需要多休息和注意饮食。听到这个消息真的松了一口气，但也提醒我要更加关注自己的健康。",
                    date: calendar.date(byAdding: .day, value: -5, to: today)!,
                    mood: .relaxed,
                    tags: ["健康", "诊断", "休息"],
                    isFavorite: false
                ),
                
                // 第10天（前4天）
                JournalEntry(
                    id: UUID(),
                    title: "项目进展顺利",
                    content: "新项目进展得比预期更加顺利，团队配合得很好。今天还收到了客户的积极反馈，这让我感到非常欣慰和自信。",
                    date: calendar.date(byAdding: .day, value: -4, to: today)!,
                    mood: .happy,
                    tags: ["工作", "成功", "团队"],
                    isFavorite: true
                ),
                
                // 第11天（前3天）
                JournalEntry(
                    id: UUID(),
                    title: "电影之夜",
                    content: "今晚一个人看了一部很感人的电影，情节和角色都非常打动人心。有时候独自欣赏一部好电影也是一种不错的放松方式。",
                    date: calendar.date(byAdding: .day, value: -3, to: today)!,
                    mood: .relaxed,
                    tags: ["电影", "独处", "感动"],
                    isFavorite: false
                ),
                
                // 第12天（前2天）
                JournalEntry(
                    id: UUID(),
                    title: "周一的思考",
                    content: "今天是充满挑战的一天，但我感到很开心能够完成所有任务。这种成就感真的很满足，让我对接下来的工作更有动力。",
                    date: calendar.date(byAdding: .day, value: -2, to: today)!,
                    mood: .happy,
                    tags: ["工作", "思考", "成就感"],
                    isFavorite: true
                ),
                
                // 第13天（前1天）
                JournalEntry(
                    id: UUID(),
                    title: "安静的下午",
                    content: "找到了一家安静的咖啡馆，享受了一段难得的独处时光，这让我感到很放松。咖啡的香气和安静的环境真的很适合思考和放空。",
                    date: calendar.date(byAdding: .day, value: -1, to: today)!,
                    mood: .relaxed,
                    tags: ["放松", "咖啡", "独处"],
                    isFavorite: false
                ),
                
                // 今天
                JournalEntry(
                    id: UUID(),
                    title: "今日小记",
                    content: "今天完成了项目的重要部分，虽然有些疲惫但很有成就感。晚上计划看一部电影放松一下，给自己一些休息的时间。",
                    date: today,
                    mood: .neutral,
                    tags: ["工作", "娱乐", "平衡"],
                    isFavorite: false
                )
            ]
            
            // 为每个日记条目生成模拟情绪分析结果
            analyzeAllEntries()
        }
    }
    
    // 保存到本地存储
    private func saveEntries() {
        // 实际应用中，这里会将数据保存到本地存储
        print("保存日记条目：\(entries.count) 条")
    }
    
    // 分析所有日记条目
    private func analyzeAllEntries() {
        for entry in entries {
            let result = emotionService.analyzeText(entry.content)
            emotionAnalysisResults[entry.id] = result
        }
    }
    
    // 添加新日记
    func addEntry(_ entry: JournalEntry) {
        entries.append(entry)
        saveEntries()
        
        // 分析新条目的情绪
        let result = emotionService.analyzeText(entry.content)
        emotionAnalysisResults[entry.id] = result
    }
    
    // 更新日记
    func updateEntry(_ entry: JournalEntry) {
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[index] = entry
            saveEntries()
            
            // 重新分析条目的情绪
            let result = emotionService.analyzeText(entry.content)
            emotionAnalysisResults[entry.id] = result
        }
    }
    
    // 删除日记
    func deleteEntry(at indexSet: IndexSet) {
        // 先获取要删除的IDs
        let idsToRemove = indexSet.map { entries[$0].id }
        
        // 删除条目
        entries.remove(atOffsets: indexSet)
        saveEntries()
        
        // 删除相关的情绪分析结果
        for id in idsToRemove {
            emotionAnalysisResults.removeValue(forKey: id)
        }
    }
    
    // 删除指定的日记条目
    func deleteEntry(_ entry: JournalEntry) {
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries.remove(at: index)
            saveEntries()
            
            // 删除相关的情绪分析结果
            emotionAnalysisResults.removeValue(forKey: entry.id)
        }
    }
    
    // 切换收藏状态
    func toggleFavorite(_ id: UUID) {
        if let index = entries.firstIndex(where: { $0.id == id }) {
            entries[index].isFavorite.toggle()
            saveEntries()
        }
    }
    
    // 切换指定条目的收藏状态
    func toggleFavorite(_ entry: JournalEntry) {
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[index].isFavorite.toggle()
            saveEntries()
        }
    }
    
    // 获取情绪周报
    func generateWeeklyReport() async -> String {
        let calendar = Calendar.current
        let today = Date()
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: calendar.startOfDay(for: today)))!
        
        // 过滤出本周日记
        let weeklyEntries = entries.filter { entry in
            let entryDate = calendar.startOfDay(for: entry.date)
            return entryDate >= startOfWeek && entryDate <= today
        }
        
        // 如果没有足够数据，尝试生成一个报告
        if weeklyEntries.count < 3 {
            return "本周记录不足，无法生成周报。请继续记录您的日记，以便我们生成更准确的情感分析。"
        }
        
        // 生成本周周报
        let _ = await self.createAndSaveWeeklyReport(for: 0)
        
        // 返回摘要
        if let latestReport = getLatestWeeklyReport() {
            return latestReport.summary
        } else {
            return "生成周报失败，请稍后再试。"
        }
    }
    
    // 创建并保存周报，返回创建的周报对象
    func createAndSaveWeeklyReport(for weekOffset: Int) async -> WeeklyReport? {
        let calendar = Calendar.current
        let today = Date()
        let targetDate = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: today)!
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: targetDate))!
        let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart)!
        
        // 过滤出该周的日记
        let weeklyEntries = entries.filter { entry in
            entry.date >= weekStart && entry.date <= weekEnd
        }
        
        // 如果没有条目，返回nil
        if weeklyEntries.isEmpty {
            return nil
        }
        
        // 模拟异步处理
        try? await Task.sleep(nanoseconds: 500_000_000) // 半秒的延迟
        
        // 情绪分析
        let emotionResults = weeklyEntries.compactMap { entry in
            emotionAnalysisResults[entry.id]
        }
        
        // 计算平均情绪价值和唤起度
        let avgValence = emotionResults.isEmpty ? 0.0 : emotionResults.reduce(0) { $0 + $1.valence } / Double(emotionResults.count)
        let avgArousal = emotionResults.isEmpty ? 0.0 : emotionResults.reduce(0) { $0 + $1.arousal } / Double(emotionResults.count)
        
        // 计算主导情绪
        let emotionCounts = emotionResults.reduce(into: [String: Int]()) { counts, result in
            // 使用dominantEmotion作为主要情绪
            let emotion = result.dominantEmotion 
            counts[emotion, default: 0] += 1
        }
        
        let dominantEmotion = emotionCounts.max(by: { $0.value < $1.value })?.key ?? "平静"
        
        // 生成摘要
        let summary = generateSummary(entries: weeklyEntries, avgValence: avgValence, avgArousal: avgArousal)
        
        // 创建周报
        let report = WeeklyReport(
            startDate: weekStart,
            endDate: weekEnd,
            summary: summary,
            averageValence: avgValence,
            averageArousal: avgArousal,
            meditationCount: 0, // 暂不统计冥想次数
            journalCount: weeklyEntries.count,
            dominantEmotion: dominantEmotion
        )
        
        // 保存周报
        weeklyReports.append(report)
        weeklyReports.sort { $0.startDate > $1.startDate }
        
        return report
    }
    
    // 生成周报摘要
    private func generateSummary(entries: [JournalEntry], avgValence: Double, avgArousal: Double) -> String {
        let moodDescription = describeMood(valence: avgValence, arousal: avgArousal)
        
        // 提取主题
        let tags = entries.flatMap { $0.tags }
        let tagCounts = Dictionary(tags.map { ($0, 1) }, uniquingKeysWith: +)
        let topTags = tagCounts.sorted { $0.value > $1.value }.prefix(3).map { $0.key }
        let topicsText = topTags.isEmpty ? "未添加标签" : topTags.joined(separator: "、")
        
        // 生成建议
        var suggestion = ""
        if avgValence < 0 {
            suggestion = "建议：多参与积极活动，关注生活中的积极面，尝试冥想或轻度运动来提升情绪。"
        } else if avgArousal > 0.5 {
            suggestion = "建议：尝试放松活动如阅读、冥想，适当减少高强度工作，保持规律作息。"
        } else if avgArousal < -0.5 {
            suggestion = "建议：适当增加户外活动，尝试新事物，和朋友社交互动，增加生活活力。"
        } else {
            suggestion = "建议：继续保持记录习惯，关注情绪变化，多进行正念冥想练习。"
        }
        
        return "本周情绪总体表现为\(moodDescription)，平均活跃度\(String(format: "%.1f", abs(avgArousal)))，情绪倾向\(avgValence >= 0 ? "积极" : "消极")(\(String(format: "%.1f", abs(avgValence))))。记录了\(entries.count)篇日记，涉及主题包括\(topicsText)。\(suggestion)"
    }
    
    // 根据价值和唤起度描述情绪状态
    private func describeMood(valence: Double, arousal: Double) -> String {
        if valence > 0.5 && arousal > 0.5 {
            return "兴奋"
        } else if valence > 0.5 && arousal < -0.5 {
            return "平静"
        } else if valence < -0.5 && arousal > 0.5 {
            return "焦虑"
        } else if valence < -0.5 && arousal < -0.5 {
            return "低落"
        } else if valence > 0.5 {
            return "满足"
        } else if valence < -0.5 {
            return "不安"
        } else if arousal > 0.5 {
            return "警觉"
        } else if arousal < -0.5 {
            return "疲倦"
        } else {
            return "平静"
        }
    }
    
    // 获取最新周报
    func getLatestWeeklyReport() -> WeeklyReport? {
        // 根据生成日期排序，返回最新的
        return weeklyReports.sorted { $0.generatedDate > $1.generatedDate }.first
    }
    
    // 获取指定周的周报
    func getWeeklyReport(for weekOffset: Int) -> WeeklyReport? {
        let calendar = Calendar.current
        let now = Date()
        let currentWeekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
        let targetWeekStart = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: currentWeekStart)!
        
        return weeklyReports.first(where: { report in
            calendar.isDate(report.startDate, inSameDayAs: targetWeekStart)
        })
    }
    
    // 判断是否应该生成新的周报
    func shouldGenerateNewWeeklyReport() -> Bool {
        // 获取今天是否为周日
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        
        // 如果今天是周日（1），检查本周是否已有周报
        if weekday == 1 {
            let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
            
            // 检查是否已有本周的周报
            let hasCurrentWeekReport = weeklyReports.contains { report in
                calendar.isDate(report.startDate, equalTo: weekStart, toGranularity: .weekOfYear)
            }
            
            return !hasCurrentWeekReport
        }
        
        return false
    }
    
    // 按日期排序
    func sortByDate() {
        entries.sort { $0.date > $1.date }
    }
    
    // 按心情排序
    func sortByMood() {
        entries.sort { $0.mood.rawValue < $1.mood.rawValue }
    }
    
    // 获取特定日期的日记
    func getEntries(for date: Date) -> [JournalEntry] {
        let calendar = Calendar.current
        return entries.filter { entry in
            calendar.isDate(entry.date, inSameDayAs: date)
        }
    }
    
    // 获取特定日期的日记（与getEntries功能相同，为保持API一致性）
    func entriesForDate(_ date: Date) -> [JournalEntry] {
        return getEntries(for: date)
    }
    
    // 建议的心情（基于情感分析）
    func suggestedMood(for entry: JournalEntry) -> Mood {
        if let result = emotionAnalysisResults[entry.id] {
            // 根据主导情绪判断心情
            switch result.dominantEmotion {
            case "喜悦":
                return .happy
            case "悲伤":
                return .sad
            case "愤怒":
                return .angry
            case "恐惧", "厌恶":
                return .anxious
            case "惊讶":
                return .excited
            case "平静", "满足":
                return .relaxed
            default:
                return .neutral
            }
        }
        return entry.mood
    }
    
    // 获取情绪建议
    func emotionSuggestion(for entry: JournalEntry) -> String? {
        if let result = emotionAnalysisResults[entry.id] {
            // 根据情绪结果生成建议
            switch result.dominantEmotion {
            case "喜悦":
                return "继续保持这种积极的情绪，享受愉快的时光。"
            case "悲伤":
                return "给自己一些关爱，与亲友交谈可能会有所帮助。"
            case "愤怒":
                return "深呼吸，尝试一些平静的活动来缓解压力。"
            case "恐惧", "厌恶":
                return "认识到这些感受是正常的，可以尝试写下具体的担忧。"
            case "惊讶":
                return "这是一个学习和成长的机会。"
            case "平静", "满足":
                return "这是反思和感恩的好时机。"
            default:
                return "观察自己的情绪变化，保持记录。"
            }
        }
        return nil
    }
    
    // 根据标签筛选
    func entriesWithTag(_ tag: String) -> [JournalEntry] {
        return entries.filter { $0.tags.contains(tag) }
    }
} 