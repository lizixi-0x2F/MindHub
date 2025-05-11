import SwiftUI
import Charts

struct EmotionQuadrantView: View {
    var entries: [JournalEntry]
    var analysisResults: [UUID: EmotionResult]
    var dateRange: String = ""
    
    // 为不同情绪使用更简约的颜色
    private func colorForEmotion(_ emotion: String) -> Color {
        switch emotion.lowercased() {
        case let e where e.contains("喜悦") || e.contains("兴奋"):
            return Color(.systemGreen).opacity(0.8)
        case let e where e.contains("悲伤") || e.contains("沮丧"):
            return Color(.systemBlue).opacity(0.8)
        case let e where e.contains("愤怒") || e.contains("紧张"):
            return Color(.systemRed).opacity(0.8)
        case let e where e.contains("恐惧") || e.contains("焦虑"):
            return Color(.systemOrange).opacity(0.8)
        case let e where e.contains("平静") || e.contains("满足"):
            return Color(.systemTeal).opacity(0.8)
        default:
            return Color(.systemGray).opacity(0.8)
        }
    }
    
    // 判断是否为小屏幕设备
    private var isSmallDevice: Bool {
        return UIScreen.main.bounds.width < 375
    }
    
    // 根据屏幕大小确定圆点大小
    private var dotSize: CGFloat {
        return isSmallDevice ? 10 : 12
    }
    
    // 根据屏幕大小确定标签字体大小
    private var labelFontSize: CGFloat {
        return isSmallDevice ? 9 : 11
    }
    
    // 根据屏幕大小确定象限标签字体大小
    private var quadrantLabelFontSize: CGFloat {
        return isSmallDevice ? 10 : 12
    }
    
    // 根据屏幕大小确定象限标签内边距
    private var quadrantLabelPadding: CGFloat {
        return isSmallDevice ? 4 : 6
    }
    
    // 过滤有情绪分析结果的日记
    private var entriesWithResults: [(entry: JournalEntry, result: EmotionResult)] {
        entries.compactMap { entry in
            if let result = analysisResults[entry.id] {
                return (entry: entry, result: result)
            }
            return nil
        }
    }
    
    var body: some View {
        if entriesWithResults.isEmpty {
            EmotionQuadrantEmptyView()
        } else {
            GeometryReader { geometry in
                let width = geometry.size.width
                let height = geometry.size.height
                let centerX = width / 2
                let centerY = height / 2
                
                ZStack {
                    // 坐标轴
                    Path { path in
                        // 水平轴
                        path.move(to: CGPoint(x: 0, y: centerY))
                        path.addLine(to: CGPoint(x: width, y: centerY))
                        
                        // 垂直轴
                        path.move(to: CGPoint(x: centerX, y: 0))
                        path.addLine(to: CGPoint(x: centerX, y: height))
                    }
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    
                    // 坐标轴标签
                    Text("积极")
                        .font(.system(size: labelFontSize))
                        .foregroundColor(.green)
                        .position(x: width - 20, y: centerY - 10)
                    
                    Text("消极")
                        .font(.system(size: labelFontSize))
                        .foregroundColor(.red)
                        .position(x: 20, y: centerY - 10)
                    
                    Text("活跃")
                        .font(.system(size: labelFontSize))
                        .foregroundColor(.blue)
                        .position(x: centerX + 20, y: 10)
                    
                    Text("平静")
                        .font(.system(size: labelFontSize))
                        .foregroundColor(.orange)
                        .position(x: centerX + 20, y: height - 10)
                    
                    // 象限标签
                    Text("兴奋/喜悦")
                        .font(.system(size: quadrantLabelFontSize))
                        .padding(quadrantLabelPadding)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(4)
                        .position(x: centerX + width/4 - 5, y: centerY - height/4 + 5)
                    
                    Text("紧张/愤怒")
                        .font(.system(size: quadrantLabelFontSize))
                        .padding(quadrantLabelPadding)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(4)
                        .position(x: centerX - width/4 + 5, y: centerY - height/4 + 5)
                    
                    Text("沮丧/悲伤")
                        .font(.system(size: quadrantLabelFontSize))
                        .padding(quadrantLabelPadding)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(4)
                        .position(x: centerX - width/4 + 5, y: centerY + height/4 - 5)
                    
                    Text("放松/满足")
                        .font(.system(size: quadrantLabelFontSize))
                        .padding(quadrantLabelPadding)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(4)
                        .position(x: centerX + width/4 - 5, y: centerY + height/4 - 5)
                    
                    // 情绪点
                    ForEach(entriesWithResults, id: \.entry.id) { item in
                        let x = centerX + (CGFloat(item.result.valence) * (width/2 - CGFloat(30)))
                        let y = centerY - (CGFloat(item.result.arousal) * (height/2 - CGFloat(30)))
                        
                        // 情绪点
                        Circle()
                            .fill(colorForEmotion(item.result.dominantEmotion))
                            .frame(width: dotSize, height: dotSize)
                            .position(x: x, y: y)
                            // 添加交互提示
                            .overlay(
                                EmotionTooltip(entry: item.entry, emotion: item.result.dominantEmotion)
                                    .opacity(0) // 正常状态下不可见
                            )
                            .onTapGesture {
                                // 这里可以实现点击显示更多信息的功能
                            }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(10)
            }
        }
    }
}

// 情绪提示工具
struct EmotionTooltip: View {
    let entry: JournalEntry
    let emotion: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(entry.title)
                .font(.caption)
                .fontWeight(.medium)
            
            Text(emotion)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            Text(entry.date, style: .date)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(8)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
        .shadow(radius: 2)
    }
}

// 情绪象限空状态视图
struct EmotionQuadrantEmptyView: View {
    var body: some View {
        VStack {
            Spacer()
            Image(systemName: "chart.scatter")
                .font(.largeTitle)
                .foregroundColor(.gray.opacity(0.5))
                .padding(.bottom, 8)
            
            Text("暂无情绪分布数据")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(10)
    }
}

struct EmotionQuadrantView_Previews: PreviewProvider {
    static var previews: some View {
        EmotionQuadrantView(
            entries: [],
            analysisResults: [
                UUID(): EmotionResult(valence: 0.8, arousal: 0.7, dominantEmotion: "喜悦"),
                UUID(): EmotionResult(valence: -0.7, arousal: 0.6, dominantEmotion: "愤怒"),
                UUID(): EmotionResult(valence: -0.5, arousal: -0.5, dominantEmotion: "抑郁"),
                UUID(): EmotionResult(valence: 0.6, arousal: -0.4, dominantEmotion: "平静")
            ]
        )
        .frame(height: 400)
    }
} 