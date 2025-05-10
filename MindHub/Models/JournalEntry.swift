import Foundation
import SwiftUI

struct JournalEntry: Identifiable, Codable {
    var id: UUID
    var title: String
    var content: String
    var date: Date
    var mood: Mood
    var tags: [String]
    var isFavorite: Bool
    var emotionAnalysisResults: [EmotionAnalysisResult]?
    var attachments: [Attachment]?
    var location: Location?
    var arousal: Double?  // 情绪唤起度 0-1
    var valence: Double?  // 情绪价效度 0-1
    
    // 初始化
    init(id: UUID = UUID(), 
         title: String, 
         content: String, 
         date: Date = Date(), 
         mood: Mood = .neutral, 
         tags: [String] = [], 
         isFavorite: Bool = false, 
         emotionAnalysisResults: [EmotionAnalysisResult]? = nil,
         attachments: [Attachment]? = nil,
         location: Location? = nil,
         arousal: Double? = nil,
         valence: Double? = nil) {
        self.id = id
        self.title = title
        self.content = content
        self.date = date
        self.mood = mood
        self.tags = tags
        self.isFavorite = isFavorite
        self.emotionAnalysisResults = emotionAnalysisResults
        self.attachments = attachments
        self.location = location
        self.arousal = arousal
        self.valence = valence
    }
    
    // 获取主要情绪
    func getPrimaryEmotion() -> String? {
        guard let results = emotionAnalysisResults, !results.isEmpty else {
            return nil
        }
        
        // 返回分数最高的情绪
        return results.max(by: { $0.score < $1.score })?.emotion
    }
    
    // 获取情绪唤起度
    func getArousal() -> Double {
        // 如果已经有计算好的唤起度，直接返回
        if let arousal = arousal {
            return arousal
        }
        
        // 否则从情感分析结果中计算
        guard let results = emotionAnalysisResults, !results.isEmpty else {
            return 0.5 // 默认中等唤起度
        }
        
        // 计算加权唤起度
        var totalArousal = 0.0
        var totalWeight = 0.0
        
        for result in results {
            totalArousal += result.arousal * result.score
            totalWeight += result.score
        }
        
        return totalWeight > 0 ? totalArousal / totalWeight : 0.5
    }
    
    // 获取情绪价效度
    func getValence() -> Double {
        // 如果已经有计算好的价效度，直接返回
        if let valence = valence {
            return valence
        }
        
        // 否则从情感分析结果中计算
        guard let results = emotionAnalysisResults, !results.isEmpty else {
            return 0.5 // 默认中等价效度
        }
        
        // 计算加权价效度
        var totalValence = 0.0
        var totalWeight = 0.0
        
        for result in results {
            totalValence += result.valence * result.score
            totalWeight += result.score
        }
        
        return totalWeight > 0 ? totalValence / totalWeight : 0.5
    }
}

// 心情枚举
enum Mood: String, Codable, CaseIterable, Identifiable {
    case veryHappy = "非常开心"
    case happy = "开心"
    case neutral = "平静"
    case sad = "难过"
    case verySad = "非常难过"
    case angry = "愤怒"
    case anxious = "焦虑"
    case tired = "疲惫"
    case excited = "兴奋"
    case confused = "困惑"
    
    var id: String { self.rawValue }
    
    // 获取心情对应的图标
    var icon: String {
        switch self {
        case .veryHappy: return "😄"
        case .happy: return "🙂"
        case .neutral: return "😐"
        case .sad: return "😔"
        case .verySad: return "😢"
        case .angry: return "😠"
        case .anxious: return "😰"
        case .tired: return "😴"
        case .excited: return "🤩"
        case .confused: return "🤔"
        }
    }
    
    // 获取心情对应的颜色
    var color: Color {
        switch self {
        case .veryHappy, .excited: return .green
        case .happy: return .mint
        case .neutral: return .gray
        case .sad: return .blue
        case .verySad: return .indigo
        case .angry: return .red
        case .anxious: return .orange
        case .tired: return .purple
        case .confused: return .yellow
        }
    }
    
    // 获取心情对应的唤起度
    var arousal: Double {
        switch self {
        case .veryHappy: return 0.7
        case .happy: return 0.6
        case .neutral: return 0.1
        case .sad: return 0.3
        case .verySad: return 0.4
        case .angry: return 0.9
        case .anxious: return 0.8
        case .tired: return 0.2
        case .excited: return 0.9
        case .confused: return 0.5
        }
    }
    
    // 获取心情对应的价效度
    var valence: Double {
        switch self {
        case .veryHappy: return 0.9
        case .happy: return 0.8
        case .neutral: return 0.5
        case .sad: return 0.3
        case .verySad: return 0.1
        case .angry: return 0.2
        case .anxious: return 0.3
        case .tired: return 0.4
        case .excited: return 0.8
        case .confused: return 0.4
        }
    }
}

// 情感分析结果
struct EmotionAnalysisResult: Codable, Identifiable {
    var id: UUID
    var emotion: String
    var score: Double
    var date: Date
    var arousal: Double = 0.5  // 情绪唤起度 (0-1)
    var valence: Double = 0.5  // 情绪价效度 (0-1)
    
    init(id: UUID = UUID(), emotion: String, score: Double, date: Date = Date(), arousal: Double = 0.5, valence: Double = 0.5) {
        self.id = id
        self.emotion = emotion
        self.score = score
        self.date = date
        self.arousal = arousal
        self.valence = valence
    }
}

// 附件
struct Attachment: Codable, Identifiable {
    var id: UUID
    var type: AttachmentType
    var url: URL
    var thumbnailURL: URL?
    var caption: String?
    
    init(id: UUID = UUID(), type: AttachmentType, url: URL, thumbnailURL: URL? = nil, caption: String? = nil) {
        self.id = id
        self.type = type
        self.url = url
        self.thumbnailURL = thumbnailURL
        self.caption = caption
    }
}

// 附件类型
enum AttachmentType: String, Codable {
    case image
    case audio
    case video
    case document
}

// 位置
struct Location: Codable {
    var latitude: Double
    var longitude: Double
    var name: String?
    
    init(latitude: Double, longitude: Double, name: String? = nil) {
        self.latitude = latitude
        self.longitude = longitude
        self.name = name
    }
} 