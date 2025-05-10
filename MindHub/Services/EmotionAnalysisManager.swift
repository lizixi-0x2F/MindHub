import Foundation
import CoreML
import NaturalLanguage
import Combine

class EmotionAnalysisManager: ObservableObject {
    // 情感分析结果
    @Published var emotionResults: [EmotionResult] = []
    @Published var isAnalyzing: Bool = false
    
    // 本地情感分析模型
    private var localModel: RobertaEmotionAnalysis
    
    // 情感分类列表
    private let emotionClasses = [
        "愤怒", "悲伤", "恐惧", "惊讶", 
        "喜悦", "厌恶", "中性", "期待",
        "信任", "感激", "烦躁", "焦虑"
    ]
    
    // 初始化
    init() {
        // 初始化本地模型
        localModel = RobertaEmotionAnalysis()
    }
    
    // 分析情感（只使用本地模型）
    func analyzeEmotion(text: String) {
        isAnalyzing = true
        analyzeEmotionLocally(text: text)
    }
    
    // 使用本地模型分析情感
    private func analyzeEmotionLocally(text: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            // 应用模型进行情感分析
            let prediction = self.localModel.prediction(text: text)
            
            // 解析结果
            let emotions = prediction.emotionClasses
            let scores = prediction.scores
            
            // 计算情绪唤起度和价效度
            let (arousal, valence) = self.calculateArousalAndValence(emotions: emotions, scores: scores)
            
            var results: [EmotionResult] = []
            
            for (index, emotion) in emotions.enumerated() {
                if index < scores.count {
                    let result = EmotionResult(
                        emotion: emotion,
                        score: scores[index],
                        date: Date(),
                        text: text,
                        arousal: arousal,
                        valence: valence
                    )
                    results.append(result)
                }
            }
            
            // 按分数排序
            results.sort { $0.score > $1.score }
            
            DispatchQueue.main.async {
                self.emotionResults = results
                self.isAnalyzing = false
            }
        }
    }
    
    // 计算情绪唤起度和价效度
    private func calculateArousalAndValence(emotions: [String], scores: [Double]) -> (Double, Double) {
        // 情绪唤起度映射（高唤起度的情绪如兴奋、愤怒分值高，低唤起度如平静、悲伤分值低）
        let arousalMap: [String: Double] = [
            "愤怒": 0.85, "悲伤": 0.3, "恐惧": 0.7, "惊讶": 0.8, 
            "喜悦": 0.7, "厌恶": 0.6, "中性": 0.1, "期待": 0.7,
            "信任": 0.4, "感激": 0.6, "烦躁": 0.85, "焦虑": 0.75
        ]
        
        // 情绪价效度映射（正面情绪如喜悦、信任分值高，负面情绪如愤怒、悲伤分值低）
        let valenceMap: [String: Double] = [
            "愤怒": 0.2, "悲伤": 0.3, "恐惧": 0.2, "惊讶": 0.6, 
            "喜悦": 0.9, "厌恶": 0.2, "中性": 0.5, "期待": 0.8,
            "信任": 0.8, "感激": 0.9, "烦躁": 0.3, "焦虑": 0.3
        ]
        
        var totalArousal = 0.0
        var totalValence = 0.0
        var totalWeight = 0.0
        
        for (index, emotion) in emotions.enumerated() {
            if index < scores.count {
                let score = scores[index]
                let arousal = arousalMap[emotion] ?? 0.5
                let valence = valenceMap[emotion] ?? 0.5
                
                totalArousal += arousal * score
                totalValence += valence * score
                totalWeight += score
            }
        }
        
        // 防止除以零
        if totalWeight > 0 {
            return (totalArousal / totalWeight, totalValence / totalWeight)
        } else {
            return (0.5, 0.5) // 默认中等唤起度和价效度
        }
    }
    
    // 批量分析多个文本
    func batchAnalyzeEmotions(texts: [String]) {
        isAnalyzing = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            var allResults: [EmotionResult] = []
            
            for text in texts {
                let prediction = self.localModel.prediction(text: text)
                let emotions = prediction.emotionClasses
                let scores = prediction.scores
                
                let (arousal, valence) = self.calculateArousalAndValence(emotions: emotions, scores: scores)
                
                for (index, emotion) in emotions.enumerated() {
                    if index < scores.count {
                        let result = EmotionResult(
                            emotion: emotion,
                            score: scores[index],
                            date: Date(),
                            text: text,
                            arousal: arousal,
                            valence: valence
                        )
                        allResults.append(result)
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.emotionResults = allResults
                self.isAnalyzing = false
            }
        }
    }
    
    // 执行后台情感分析
    func performBackgroundAnalysis() -> Operation {
        return BlockOperation {
            // 从存储中获取需要分析的日记
            // 进行情感分析
            // 存储结果
        }
    }
    
    // 保存情感分析结果
    func saveEmotionResults() {
        // 将结果保存到 Core Data 或本地存储
    }
    
    // 获取主要情感
    func getPrimaryEmotion() -> String {
        guard let primaryEmotion = emotionResults.first else {
            return "未知"
        }
        
        return primaryEmotion.emotion
    }
    
    // 分析文本情绪，并返回情绪唤起度和价效度
    func analyzeTextArousalValence(text: String) -> (arousal: Double, valence: Double) {
        let prediction = localModel.prediction(text: text)
        return calculateArousalAndValence(emotions: prediction.emotionClasses, scores: prediction.scores)
    }
}

// 情感分析结果模型
struct EmotionResult: Identifiable {
    var id = UUID()
    let emotion: String
    let score: Double
    let date: Date
    let text: String
    let arousal: Double  // 情绪唤起度 (0-1)
    let valence: Double  // 情绪价效度 (0-1)
    
    init(id: UUID = UUID(), emotion: String, score: Double, date: Date = Date(), text: String, arousal: Double = 0.5, valence: Double = 0.5) {
        self.id = id
        self.emotion = emotion
        self.score = score
        self.date = date
        self.text = text
        self.arousal = arousal
        self.valence = valence
    }
}

// 模拟 Core ML 模型类，实际应用中这将由 Core ML 工具生成
class RobertaEmotionAnalysis {
    func prediction(text: String) -> EmotionPrediction {
        // 这里只是模拟，实际应用中这将使用真实的 Core ML 模型进行推理
        let emotions = ["愤怒", "悲伤", "恐惧", "惊讶", "喜悦", "厌恶", "中性", "期待", "信任", "感激"]
        var scores: [Double] = []
        
        // 基于文本内容进行简单的情感分析
        let text = text.lowercased()
        
        // 为每种情绪生成初始低分
        for _ in emotions {
            scores.append(Double.random(in: 0.01...0.1))
        }
        
        // 基于关键词增加相应情绪的分数
        if text.contains("开心") || text.contains("高兴") || text.contains("快乐") {
            if let index = emotions.firstIndex(of: "喜悦") {
                scores[index] = Double.random(in: 0.7...0.9)
            }
        }
        
        if text.contains("伤心") || text.contains("难过") || text.contains("哭") {
            if let index = emotions.firstIndex(of: "悲伤") {
                scores[index] = Double.random(in: 0.7...0.9)
            }
        }
        
        if text.contains("生气") || text.contains("愤怒") || text.contains("发火") {
            if let index = emotions.firstIndex(of: "愤怒") {
                scores[index] = Double.random(in: 0.7...0.9)
            }
        }
        
        if text.contains("害怕") || text.contains("恐惧") || text.contains("担忧") {
            if let index = emotions.firstIndex(of: "恐惧") {
                scores[index] = Double.random(in: 0.7...0.9)
            }
        }
        
        if text.contains("惊讶") || text.contains("震惊") || text.contains("吃惊") {
            if let index = emotions.firstIndex(of: "惊讶") {
                scores[index] = Double.random(in: 0.7...0.9)
            }
        }
        
        if text.contains("厌恶") || text.contains("讨厌") || text.contains("恶心") {
            if let index = emotions.firstIndex(of: "厌恶") {
                scores[index] = Double.random(in: 0.7...0.9)
            }
        }
        
        if text.contains("信任") || text.contains("相信") || text.contains("依靠") {
            if let index = emotions.firstIndex(of: "信任") {
                scores[index] = Double.random(in: 0.7...0.9)
            }
        }
        
        if text.contains("期待") || text.contains("盼望") || text.contains("希望") {
            if let index = emotions.firstIndex(of: "期待") {
                scores[index] = Double.random(in: 0.7...0.9)
            }
        }
        
        if text.contains("感激") || text.contains("感谢") || text.contains("谢谢") {
            if let index = emotions.firstIndex(of: "感激") {
                scores[index] = Double.random(in: 0.7...0.9)
            }
        }
        
        // 如果没有明显情绪，增加"中性"分数
        let hasStrongEmotion = scores.contains { $0 > 0.5 }
        if !hasStrongEmotion {
            if let index = emotions.firstIndex(of: "中性") {
                scores[index] = Double.random(in: 0.7...0.9)
            }
        }
        
        // 确保分数总和为1
        let total = scores.reduce(0, +)
        scores = scores.map { $0 / total }
        
        return EmotionPrediction(emotionClasses: emotions, scores: scores)
    }
}

// 模拟预测结果结构
struct EmotionPrediction {
    let emotionClasses: [String]
    let scores: [Double]
} 