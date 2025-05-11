import SwiftUI

// 情绪分析卡片子视图
struct EmotionAnalysisCard: View {
    let entry: JournalEntry
    let emotionResult: EmotionResult?
    @Binding var isAnalyzing: Bool
    let analyzeEmotion: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标题和分析按钮
            EmotionCardHeader(
                emotionResult: emotionResult,
                isAnalyzing: isAnalyzing,
                analyzeEmotion: analyzeEmotion
            )
            
            if isAnalyzing {
                EmotionCardLoading()
            } else if let result = emotionResult {
                // 情绪结果展示
                EmotionCardResults(result: result)
            } else {
                // 等待分析的占位内容
                EmotionCardPlaceholder()
            }
        }
        .padding()
        .background(ThemeColors.cardBackground)
        .cornerRadius(16)
        .shadow(color: ThemeColors.shadow, radius: 4, x: 0, y: 2)
    }
}

// 拆分为多个更小的组件
struct EmotionCardHeader: View {
    let emotionResult: EmotionResult?
    let isAnalyzing: Bool
    let analyzeEmotion: () -> Void
    
    var body: some View {
        HStack {
            Text("情绪分析")
                .font(.headline)
                .foregroundColor(ThemeColors.primaryText)
            
            Spacer()
            
            if emotionResult == nil && !isAnalyzing {
                Button(action: analyzeEmotion) {
                    Text("立即分析")
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(ThemeColors.accent)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
    }
}

struct EmotionCardLoading: View {
    var body: some View {
        HStack {
            Spacer()
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: ThemeColors.accent))
            Spacer()
        }
        .padding(.vertical, 30)
    }
}

struct EmotionCardResults: View {
    let result: EmotionResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 情绪象限图
            HStack {
                EmotionQuadrantSingle(valence: result.valence, arousal: result.arousal)
                    .frame(width: 120, height: 120)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("主导情绪: \(result.dominantEmotion)")
                        .font(.subheadline)
                        .foregroundColor(.white)
                    
                    Text("积极/消极程度: \(Int(result.valence * 100))%")
                        .font(.subheadline)
                        .foregroundColor(.white)
                    
                    Text("情绪强度: \(Int(result.arousal * 100))%")
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                .padding(.leading, 8)
            }
            
            Divider()
                .background(ThemeColors.divider)
                .padding(.vertical, 4)
            
            Text(getEmotionInterpretation(result: result))
                .font(.subheadline)
                .foregroundColor(.white)
                .lineSpacing(4)
                .padding(.top, 2)
        }
    }
    
    // 根据分析结果生成情绪解读文本
    private func getEmotionInterpretation(result: EmotionResult) -> String {
        let valence = result.valence
        let arousal = result.arousal
        let emotion = result.dominantEmotion
        
        var interpretation = "本篇日记主要体现出「\(emotion)」情绪，"
        
        if valence > 0.5 {
            interpretation += "整体情感十分积极，"
        } else if valence > 0 {
            interpretation += "情感基调偏向积极，"
        } else if valence > -0.5 {
            interpretation += "情感基调偏向消极，"
        } else {
            interpretation += "整体情感较为消极，"
        }
        
        if arousal > 0.5 {
            interpretation += "情绪强度很高，表现出活跃、兴奋的状态。"
        } else if arousal > 0 {
            interpretation += "情绪体验较为鲜明，有一定的强度。"
        } else if arousal > -0.5 {
            interpretation += "情绪表达较为平缓，偏向冷静。"
        } else {
            interpretation += "情绪强度较低，处于平静或抑制状态。"
        }
        
        return interpretation
    }
}

struct EmotionCardPlaceholder: View {
    var body: some View {
        Text("点击\"立即分析\"按钮获取这篇日记的情绪分析报告")
            .foregroundColor(ThemeColors.secondaryText)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 50)
    }
}

// 为单个情绪分析结果设计的象限视图
struct EmotionQuadrantSingle: View {
    let valence: Double
    let arousal: Double
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let padding: CGFloat = 10
            let effectiveSize = size - (padding * 2)
            
            ZStack {
                // 背景
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.black.opacity(0.3))
                    .frame(width: effectiveSize, height: effectiveSize)
                
                // 坐标轴
                Path { path in
                    // X轴
                    path.move(to: CGPoint(x: padding, y: padding + effectiveSize / 2))
                    path.addLine(to: CGPoint(x: padding + effectiveSize, y: padding + effectiveSize / 2))
                    
                    // Y轴
                    path.move(to: CGPoint(x: padding + effectiveSize / 2, y: padding))
                    path.addLine(to: CGPoint(x: padding + effectiveSize / 2, y: padding + effectiveSize))
                }
                .stroke(Color.white.opacity(0.6), lineWidth: 1)
                
                // 象限标签
                VStack {
                    HStack {
                        Text("紧张")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.7))
                        
                        Spacer()
                        
                        Text("兴奋")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    HStack {
                        Text("抑郁")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.7))
                        
                        Spacer()
                        
                        Text("平静")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(padding + 2)
                .frame(width: effectiveSize, height: effectiveSize)
                
                // 当前情绪点
                let xPos = padding + (valence + 1) / 2 * effectiveSize
                let yPos = padding + (1 - (arousal + 1) / 2) * effectiveSize
                
                Circle()
                    .fill(ThemeColors.accent)
                    .frame(width: 8, height: 8)
                    .position(x: xPos, y: yPos)
            }
            .frame(width: size, height: size)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
    }
} 