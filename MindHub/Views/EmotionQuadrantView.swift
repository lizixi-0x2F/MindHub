import SwiftUI

struct EmotionQuadrantView: View {
    var entries: [JournalEntry]
    
    // 仅显示有情绪值的条目
    private var validEntries: [JournalEntry] {
        return entries.filter { entry in
            return entry.arousal != nil && entry.valence != nil
        }
    }
    
    // 计算最近30天的条目
    private var recentEntries: [JournalEntry] {
        let calendar = Calendar.current
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: Date())!
        return validEntries.filter { $0.date >= thirtyDaysAgo }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if recentEntries.isEmpty {
                Text("尚无情绪象限数据")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 40)
            } else {
                ZStack {
                    // 背景和网格
                    Rectangle()
                        .fill(Color(.systemGray6))
                        .cornerRadius(8)
                    
                    // 坐标轴
                    VStack {
                        Divider()
                            .frame(height: 1)
                            .background(Color.gray)
                    }
                    
                    HStack {
                        Divider()
                            .frame(width: 1)
                            .background(Color.gray)
                    }
                    
                    // 象限标签
                    VStack {
                        HStack {
                            Text("焦虑")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(8)
                                .background(Color(.systemBackground))
                                .cornerRadius(4)
                            
                            Spacer()
                            
                            Text("兴奋")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(8)
                                .background(Color(.systemBackground))
                                .cornerRadius(4)
                        }
                        
                        Spacer()
                        
                        HStack {
                            Text("抑郁")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(8)
                                .background(Color(.systemBackground))
                                .cornerRadius(4)
                            
                            Spacer()
                            
                            Text("满足")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(8)
                                .background(Color(.systemBackground))
                                .cornerRadius(4)
                        }
                    }
                    .padding()
                    
                    // 坐标轴标签
                    VStack {
                        Spacer()
                        Text("唤起度")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .rotationEffect(Angle(degrees: 270))
                            .offset(x: -150)
                    }
                    
                    HStack {
                        Spacer()
                        VStack {
                            Spacer()
                            Text("价效度")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .offset(y: 140)
                        }
                    }
                    
                    // 数据点
                    GeometryReader { geometry in
                        ForEach(recentEntries) { entry in
                            let x = (entry.getValence() * geometry.size.width) - (geometry.size.width / 2)
                            let y = (geometry.size.height / 2) - (entry.getArousal() * geometry.size.height)
                            
                            Circle()
                                .fill(entry.mood.color)
                                .frame(width: 12, height: 12)
                                .position(x: geometry.size.width / 2 + x, y: geometry.size.height / 2 + y)
                                .overlay(
                                    Text(entry.mood.icon)
                                        .font(.caption2)
                                        .offset(y: -15)
                                )
                                .shadow(radius: 1)
                        }
                    }
                }
                .frame(height: 280)
                .padding(.horizontal, 8)
                
                // 图例和解释
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("最近30天的情绪分布")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(recentEntries.count)个数据点")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("横轴：价效度 (负面 ← → 正面)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("纵轴：唤起度 (平静 ↓ ↑ 激动)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 8)
            }
        }
    }
}

struct EmotionQuadrantView_Previews: PreviewProvider {
    static var previews: some View {
        EmotionQuadrantView(entries: [])
            .frame(height: 320)
            .padding()
    }
} 