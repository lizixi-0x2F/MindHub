import Foundation
import SwiftUI

class JournalViewModel: ObservableObject {
    @Published var entries: [JournalEntry] = []
    
    // 加载日记条目
    func loadEntries() {
        // 从本地存储加载日记条目
        if let data = UserDefaults.standard.data(forKey: "journalEntries") {
            if let decoded = try? JSONDecoder().decode([JournalEntry].self, from: data) {
                // 按日期排序，最新的在前面
                self.entries = decoded.sorted(by: { $0.date > $1.date })
                return
            }
        }
        
        // 如果没有数据，尝试读取示例数据
        if entries.isEmpty {
            createSampleData()
        }
    }
    
    // 保存日记条目
    private func saveEntries() {
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: "journalEntries")
        }
    }
    
    // 添加新日记
    func addEntry(_ entry: JournalEntry) {
        entries.insert(entry, at: 0)
        saveEntries()
    }
    
    // 更新日记
    func updateEntry(_ updatedEntry: JournalEntry) {
        if let index = entries.firstIndex(where: { $0.id == updatedEntry.id }) {
            entries[index] = updatedEntry
            saveEntries()
        }
    }
    
    // 删除日记
    func deleteEntry(_ entry: JournalEntry) {
        entries.removeAll { $0.id == entry.id }
        saveEntries()
    }
    
    // 切换收藏状态
    func toggleFavorite(_ entry: JournalEntry) {
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[index].isFavorite.toggle()
            saveEntries()
        }
    }
    
    // 创建示例数据
    func createSampleData() {
        let sampleEntries = [
            JournalEntry(
                title: "快乐的一天",
                content: "今天天气晴朗，我去公园散步，遇到了很多有趣的人。阳光温暖，微风轻拂，感觉非常舒适。中午和朋友共进午餐，聊了很多近况，十分愉快。",
                date: Calendar.current.date(byAdding: .day, value: 0, to: Date()) ?? Date(),
                mood: .happy,
                tags: ["公园", "朋友", "晴天"],
                isFavorite: true
            ),
            JournalEntry(
                title: "工作压力",
                content: "今天工作有点压力大，项目deadline临近，还有很多任务没完成。团队成员都在努力赶工，希望能按时完成。虽然很累，但也很有成就感。",
                date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
                mood: .anxious,
                tags: ["工作", "压力", "团队"],
                isFavorite: false
            ),
            JournalEntry(
                title: "阅读时光",
                content: "今天下午在咖啡馆读完了那本期待已久的小说，结局出人意料但很合理。咖啡的香气和书中的情节交织在一起，度过了一个安静而充实的下午。",
                date: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(),
                mood: .neutral,
                tags: ["阅读", "咖啡馆", "闲暇"],
                isFavorite: true
            )
        ]
        
        entries = sampleEntries
        saveEntries()
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
} 