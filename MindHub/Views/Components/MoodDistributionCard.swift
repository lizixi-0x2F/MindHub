import SwiftUI
import Charts

struct MoodDistributionCard: View {
    let title: String
    let entries: [JournalEntry]
    
    // 计算每种心情的分布
    private var moodDistribution: [(mood: Mood, count: Int)] {
        var distribution: [Mood: Int] = [:]
        
        // 初始化所有可能的心情
        for mood in Mood.all {
            distribution[mood] = 0
        }
        
        // 统计每种心情的数量
        for entry in entries {
            distribution[entry.mood, default: 0] += 1
        }
        
        // 转换为数组并排序
        return distribution.map { (mood: $0.key, count: $0.value) }
            .sorted(by: { $0.count > $1.count })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.accentColor)
                
                Text(title)
                    .font(.headline)
            }
            .padding(.bottom, 5)
            
            if entries.isEmpty {
                Text("暂无数据 📊")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                VStack(spacing: 12) {
                    ForEach(moodDistribution.prefix(5), id: \.mood) { item in
                        HStack {
                            Text("\(item.mood.emoji) \(item.mood.rawValue)")
                                .frame(width: 80, alignment: .leading)
                            
                            // 进度条
                            GeometryReader { geometry in
                                let width = geometry.size.width
                                let maxCount = moodDistribution.first?.count ?? 1
                                let barWidth = max(CGFloat(item.count) / CGFloat(maxCount) * width, 20)
                                
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color(.systemGray5))
                                        .frame(height: 18)
                                    
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.accentColor.opacity(0.7))
                                        .frame(width: barWidth, height: 18)
                                }
                            }
                            .frame(height: 18)
                            
                            Text("\(item.count)")
                                .font(.system(.footnote, design: .rounded))
                                .frame(width: 30, alignment: .trailing)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

struct MoodDistributionCard_Previews: PreviewProvider {
    static var previews: some View {
        // 创建模拟数据
        let moods: [Mood] = [.happy, .sad, .anxious, .angry, .neutral, .excited, .relaxed]
        var entries: [JournalEntry] = []
        
        for i in 1...20 {
            let mood = moods[i % moods.count]
            entries.append(JournalEntry(
                title: "日记 \(i)",
                content: "这是一篇测试日记",
                mood: mood
            ))
        }
        
        return MoodDistributionCard(
            title: "心情分布",
            entries: entries
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}