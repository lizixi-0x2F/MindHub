import Foundation
import SwiftUI

// 情绪分析结果
public struct EmotionResult: Equatable {
    public let valence: Double  // 效价，积极/消极维度 (-1 to 1)
    public let arousal: Double  // 唤醒度，活跃/平静维度 (-1 to 1)
    public let dominantEmotion: String  // 主导情绪
    
    public init(valence: Double, arousal: Double, dominantEmotion: String) {
        self.valence = valence
        self.arousal = arousal
        self.dominantEmotion = dominantEmotion
    }
    
    // 实现Equatable
    public static func == (lhs: EmotionResult, rhs: EmotionResult) -> Bool {
        return lhs.valence == rhs.valence &&
               lhs.arousal == rhs.arousal &&
               lhs.dominantEmotion == rhs.dominantEmotion
    }
}

// 情绪分析结果别名 - 避免与Services模块中的类型冲突
public typealias EmotionAnalysisResult = EmotionResult

// 情绪标签枚举
public enum EmotionLabel: String, CaseIterable {
    case joy = "喜悦"
    case sadness = "悲伤"
    case anger = "愤怒"
    case fear = "恐惧"
    case disgust = "厌恶"
    case surprise = "惊讶"
    case neutral = "中性"
    
    // 唤起度
    var arousal: Double {
        switch self {
        case .joy:
            return 0.6
        case .sadness:
            return -0.5
        case .anger:
            return 0.8
        case .fear:
            return 0.7
        case .disgust:
            return 0.3
        case .surprise:
            return 0.7
        case .neutral:
            return 0.0
        }
    }
    
    // 效价
    var valence: Double {
        switch self {
        case .joy:
            return 0.8
        case .sadness:
            return -0.7
        case .anger:
            return -0.8
        case .fear:
            return -0.7
        case .disgust:
            return -0.6
        case .surprise:
            return 0.4
        case .neutral:
            return 0.0
        }
    }
    
    // 返回颜色
    var color: Color {
        switch self {
        case .joy:
            return .yellow
        case .sadness:
            return .blue
        case .anger:
            return .red
        case .fear:
            return .purple
        case .disgust:
            return .green
        case .surprise:
            return .orange
        case .neutral:
            return .gray
        }
    }
    
    // 从文本分析获取情绪标签
    static func fromAnalysis(_ text: String) -> EmotionLabel {
        // 简单实现，实际应用中应使用NLP模型
        
        let text = text.lowercased()
        
        // 简单关键词匹配
        if text.contains("开心") || text.contains("快乐") || text.contains("高兴") {
            return .joy
        } else if text.contains("伤心") || text.contains("难过") || text.contains("悲伤") {
            return .sadness
        } else if text.contains("愤怒") || text.contains("生气") || text.contains("烦躁") {
            return .anger
        } else if text.contains("害怕") || text.contains("恐惧") || text.contains("担心") {
            return .fear
        } else if text.contains("厌恶") || text.contains("讨厌") || text.contains("恶心") {
            return .disgust
        } else if text.contains("惊讶") || text.contains("震惊") || text.contains("意外") {
            return .surprise
        }
        
        return .neutral
    }
}

// 情绪时间范围
public enum TimeRange: String, CaseIterable, Identifiable {
    case week = "周"
    case month = "月"
    case year = "年"
    
    public var id: String { self.rawValue }
}

// 周报模型
public struct WeeklyReport: Identifiable, Codable {
    public let id: UUID
    public let startDate: Date
    public let endDate: Date
    public let summary: String
    public let averageValence: Double
    public let averageArousal: Double
    public let meditationCount: Int
    public let journalCount: Int
    public let dominantEmotion: String
    public let generatedDate: Date
    
    public init(
        id: UUID = UUID(),
        startDate: Date,
        endDate: Date,
        summary: String,
        averageValence: Double,
        averageArousal: Double,
        meditationCount: Int,
        journalCount: Int,
        dominantEmotion: String,
        generatedDate: Date = Date()
    ) {
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
        self.summary = summary
        self.averageValence = averageValence
        self.averageArousal = averageArousal
        self.meditationCount = meditationCount
        self.journalCount = journalCount
        self.dominantEmotion = dominantEmotion
        self.generatedDate = generatedDate
    }
    
    // 格式化的日期范围
    var dateRangeText: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM月dd日"
        return "\(dateFormatter.string(from: startDate)) - \(dateFormatter.string(from: endDate))"
    }
} 