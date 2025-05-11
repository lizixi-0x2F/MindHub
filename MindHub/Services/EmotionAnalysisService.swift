import Foundation
import SwiftUI

// 导入Apple自然语言框架
import NaturalLanguage
import os.log

// 情绪分析服务类
@MainActor public final class EmotionAnalysisService: Sendable {
    // 标记为静态单例
    public static let shared = EmotionAnalysisService()
    
    // 日志记录器
    private let logger = Logger(subsystem: "com.diary.ozlee.mindhub", category: "EmotionAnalysis")
    
    // Apple情感分析器
    private let sentimentTagger = NLTagger(tagSchemes: [.sentimentScore])
    
    // 分析方法选择
    enum AnalysisMethod {
        case appleNLP        // 使用Apple自带的NLP
        case keywordBased    // 使用基于关键词的方法
    }
    
    // 当前首选的分析方法
    private var preferredMethod: AnalysisMethod = .appleNLP
    
    // 情绪标签枚举
    enum EmotionLabel: String, CaseIterable, Sendable {
        case joy = "喜悦"
        case sadness = "悲伤"
        case anger = "愤怒"
        case fear = "恐惧"
        case disgust = "厌恶"
        case surprise = "惊讶"
        case neutral = "中性"
        
        // 转换为Mood
        func toMood() -> Mood {
            switch self {
            case .joy:
                return .happy
            case .sadness:
                return .sad
            case .anger:
                return .angry
            case .fear, .disgust:
                return .anxious
            case .surprise:
                return .excited
            case .neutral:
                return .neutral
            }
        }
        
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
                return 0.2
            case .surprise:
                return 0.9
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
                return -0.6
            case .fear:
                return -0.7
            case .disgust:
                return -0.5
            case .surprise:
                return 0.3
            case .neutral:
                return 0.0
            }
        }
    }
    
    private init() {
        logger.info("EmotionAnalysisService 初始化开始")
        
        // 检查Apple NLP情感分析是否可用
        if #available(iOS 15.0, macOS 12.0, *) {
            // 测试Apple NLP功能
            let testText = "今天天气真好，我很开心。"
            sentimentTagger.string = testText
            
            if let sentiment = sentimentTagger.tag(at: testText.startIndex, unit: .paragraph, scheme: .sentimentScore).0,
               let score = Double(sentiment.rawValue) {
                logger.info("Apple NLP情感分析可用，测试得分: \(score)")
                preferredMethod = .appleNLP
            } else {
                logger.warning("Apple NLP情感分析测试失败，将使用关键词匹配")
                preferredMethod = .keywordBased
            }
        } else {
            logger.warning("当前系统版本不支持Apple NLP情感分析，将使用关键词匹配")
            preferredMethod = .keywordBased
        }
    }
    
    // 分析所有日记条目
    public func analyzeEntries(_ entries: [JournalEntry]) -> [UUID: EmotionResult] {
        var results: [UUID: EmotionResult] = [:]
        
        for entry in entries {
            results[entry.id] = analyzeText(entry.content)
        }
        
        return results
    }
    
    // 分析单个文本
    public func analyzeText(_ text: String) -> EmotionResult {
        // 根据首选方法选择分析算法
        switch preferredMethod {
        case .appleNLP:
            // 使用Apple NLP进行情感分析
            if #available(iOS 15.0, macOS 12.0, *) {
                logger.info("使用Apple情感分析API分析文本")
                let appleResult = analyzeWithAppleNLP(text)
                return appleResult
            } else {
                // 系统版本不支持，回退到关键词方法
                logger.warning("当前系统版本不支持Apple NLP，回退到关键词方法")
                return analyzeWithKeywords(text)
            }
            
        case .keywordBased:
            // 使用关键词匹配作为备选方法
            logger.info("使用关键词匹配分析文本")
            return analyzeWithKeywords(text)
        }
    }
    
    // 使用Apple NLP分析情感
    @available(iOS 15.0, macOS 12.0, *)
    private func analyzeWithAppleNLP(_ text: String) -> EmotionResult {
        sentimentTagger.string = text
        
        // 获取整体情感得分
        var sentimentScore: Double = 0.0
        
        if let sentiment = sentimentTagger.tag(at: text.startIndex, unit: .paragraph, scheme: .sentimentScore).0,
           let score = Double(sentiment.rawValue) {
            // Apple情感得分范围: -1.0(负面) 到 1.0(正面)
            sentimentScore = score
            logger.info("Apple情感分析得分: \(sentimentScore)")
        } else {
            logger.warning("Apple情感分析返回无效结果")
        }
        
        // 对不同段落进行分析，找出情感波动
        var varianceSum: Double = 0.0
        var paragraphCount: Int = 0
        
        // 使用标准的文本范围枚举方式
        text.enumerateSubstrings(in: text.startIndex..<text.endIndex, options: .byParagraphs) { [self] substring, substringRange, _, _ in
            if let paragraph = substring {
                self.sentimentTagger.string = paragraph
                if let sentiment = self.sentimentTagger.tag(at: paragraph.startIndex, unit: .paragraph, scheme: .sentimentScore).0,
                   let score = Double(sentiment.rawValue) {
                    // 计算与整体得分的差异
                    let variance = abs(score - sentimentScore)
                    varianceSum += variance
                    paragraphCount += 1
                }
            }
        }
        
        // 计算平均情感波动作为唤起度指标
        let arousal = paragraphCount > 0 ? min(varianceSum / Double(paragraphCount) * 2.0, 1.0) : 0.0
        
        // 将Apple情感得分转换为我们的valence
        let valence = sentimentScore
        
        // 确定主导情绪
        let dominantEmotion = determineDominantEmotion(valence: valence, arousal: arousal)
        
        logger.debug("Apple NLP分析结果: 效价=\(valence), 唤起度=\(arousal), 主导情绪=\(dominantEmotion)")
        
        return EmotionResult(
            valence: valence,
            arousal: arousal,
            dominantEmotion: dominantEmotion
        )
    }
    
    // 使用关键词匹配分析情感
    private func analyzeWithKeywords(_ text: String) -> EmotionResult {
        let valence = calculateValence(for: text)
        let arousal = calculateArousal(for: text)
        let dominantEmotion = determineDominantEmotion(valence: valence, arousal: arousal)
        
        logger.debug("关键词匹配结果: 效价=\(valence), 唤起度=\(arousal), 主导情绪=\(dominantEmotion)")
        
        return EmotionResult(
            valence: valence,
            arousal: arousal,
            dominantEmotion: dominantEmotion
        )
    }
    
    // 计算效价 (valence)
    private func calculateValence(for text: String) -> Double {
        // 简单的情感词汇检测
        let positiveWords = ["开心", "快乐", "喜悦", "幸福", "高兴", "兴奋", "满意"]
        let negativeWords = ["悲伤", "难过", "痛苦", "失望", "沮丧", "愤怒", "恐惧"]
        
        var valence: Double = 0.0
        
        // 检测正面情绪词
        for word in positiveWords {
            if text.contains(word) {
                valence += 0.2
            }
        }
        
        // 检测负面情绪词
        for word in negativeWords {
            if text.contains(word) {
                valence -= 0.2
            }
        }
        
        // 确保取值范围在 -1.0 到 1.0 之间
        return min(max(valence, -1.0), 1.0)
    }
    
    // 计算唤起度 (arousal)
    private func calculateArousal(for text: String) -> Double {
        // 简单的情感词汇检测
        let highArousalWords = ["激动", "兴奋", "狂喜", "愤怒", "恐惧", "惊讶"]
        
        var arousal: Double = 0.0
        
        // 检测高唤起度词
        for word in highArousalWords {
            if text.contains(word) {
                arousal += 0.2
            }
        }
        
        // 确保取值范围在 -1.0 到 1.0 之间
        return min(max(arousal, -1.0), 1.0)
    }
    
    // 确定主导情绪
    private func determineDominantEmotion(valence: Double, arousal: Double) -> String {
        if valence > 0.3 && arousal > 0.3 {
            return "喜悦"
        } else if valence > 0.3 && arousal < -0.3 {
            return "平静"
        } else if valence < -0.3 && arousal > 0.3 {
            return "愤怒"
        } else if valence < -0.3 && arousal < -0.3 {
            return "悲伤"
        } else if valence > 0 && abs(arousal) < 0.3 {
            return "满足"
        } else if valence < 0 && abs(arousal) < 0.3 {
            return "沮丧"
        } else if arousal > 0 && abs(valence) < 0.3 {
            return "惊讶"
        } else {
            return "中性"
        }
    }
    
    // 生成情绪周报
    func generateWeeklyReport(entries: [JournalEntry]) -> String {
        guard !entries.isEmpty else {
            return "本周无日记记录，无法生成情绪周报。"
        }
        
        // 分析所有日记的情绪
        let analysisResults = analyzeEntries(entries)
        
        // 提取情绪数据
        let emotionCounts = countEmotions(results: analysisResults)
        let primaryEmotion = findPrimaryEmotion(counts: emotionCounts)
        
        // 生成周报文本
        var report = "【本周情绪周报】\n\n"
        
        // 1. 情绪概况
        report += "本周您记录了\(entries.count)篇日记，整体情绪基调为「\(primaryEmotion)」。\n\n"
        
        // 2. 情绪分布
        report += "情绪分布：\n"
        for (emotion, count) in emotionCounts.sorted(by: { $0.value > $1.value }) {
            let percentage = Double(count) / Double(analysisResults.count) * 100
            report += "- \(emotion): \(String(format: "%.1f%%", percentage))\n"
        }
        
        return report
    }
    
    // 统计情绪出现次数
    private func countEmotions(results: [UUID: EmotionResult]) -> [String: Int] {
        var counts: [String: Int] = [:]
        
        for result in results.values {
            counts[result.dominantEmotion, default: 0] += 1
        }
        
        return counts
    }
    
    // 找出主要情绪（出现最多的）
    private func findPrimaryEmotion(counts: [String: Int]) -> String {
        return counts.max(by: { $0.value < $1.value })?.key ?? "中性"
    }
} 