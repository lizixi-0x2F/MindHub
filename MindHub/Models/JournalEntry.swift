import Foundation
import SwiftUI

// 心情枚举
public enum Mood: String, CaseIterable, Codable {
    case happy = "开心"
    case sad = "难过"
    case angry = "生气"
    case anxious = "焦虑"
    case relaxed = "放松"
    case neutral = "平静"
    case excited = "兴奋"
    
    var emoji: String {
        switch self {
        case .happy: return "😊"
        case .sad: return "😢"
        case .angry: return "😡"
        case .anxious: return "😰"
        case .relaxed: return "😌"
        case .neutral: return "😐"
        case .excited: return "🤩"
        }
    }
    
    // 返回所有可选的心情
    static var all: [Mood] {
        return [.happy, .sad, .angry, .anxious, .relaxed, .neutral, .excited]
    }
    
    // 获取对应的颜色
    var color: Color {
        switch self {
        case .happy:
            return .green
        case .sad:
            return .purple
        case .angry, .anxious:
            return .red
        case .relaxed:
            return .blue
        case .neutral:
            return .gray
        case .excited:
            return .orange
        }
    }
    
    // 获取默认情绪评分
    var defaultEmotionScore: Int {
        switch self {
        case .happy: return 3
        case .sad: return -3
        case .angry: return -4
        case .anxious: return -2
        case .relaxed: return 4
        case .neutral: return 0
        case .excited: return 5
        }
    }
}

// 日记条目模型
public struct JournalEntry: Identifiable, Codable {
    public let id: UUID
    public var title: String
    public var content: String
    public var date: Date
    public var mood: Mood
    public var tags: [String]
    public var isFavorite: Bool
    public var location: String?
    public var emotionScore: Int // 情绪评分 -5 到 +5
    
    public init(id: UUID = UUID(), title: String, content: String, date: Date = Date(), mood: Mood = .neutral, tags: [String] = [], isFavorite: Bool = false, location: String? = nil, emotionScore: Int? = nil) {
        self.id = id
        self.title = title
        self.content = content
        self.date = date
        self.mood = mood
        self.tags = tags
        self.isFavorite = isFavorite
        self.location = location
        self.emotionScore = emotionScore ?? mood.defaultEmotionScore // 如果没有提供情绪评分，则使用心情默认评分
    }
    
    // 格式化日期字符串
    public var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // 返回摘要（内容前100个字符）
    public var summary: String {
        if content.count <= 100 {
            return content
        } else {
            return String(content.prefix(100)) + "..."
        }
    }
    
    // 日期的简短文本表示
    public var dateText: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    // 心情图标名称
    public var moodIconName: String {
        return mood.emoji
    }
    
    // 获取情绪评分对应的颜色
    public var emotionScoreColor: Color {
        return ThemeColors.emotionScoreColor(for: emotionScore)
    }
    
    // 情绪评分文本表示
    public var emotionScoreText: String {
        if emotionScore > 0 {
            return "+\(emotionScore)"
        } else {
            return "\(emotionScore)"
        }
    }
}
