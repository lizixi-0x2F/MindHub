import SwiftUI

struct GitHubStyleContributionView: View {
    var entries: [JournalEntry]
    
    // 计算过去365天的数据
    private var contributionData: [Date: Int] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var result: [Date: Int] = [:]
        
        // 初始化所有日期为0条目
        for day in 0..<90 {  // 显示最近3个月的数据
            if let date = calendar.date(byAdding: .day, value: -day, to: today) {
                result[date] = 0
            }
        }
        
        // 统计每天的日记数量
        for entry in entries {
            let entryDay = calendar.startOfDay(for: entry.date)
            if result.keys.contains(entryDay) {
                result[entryDay, default: 0] += 1
            }
        }
        
        return result
    }
    
    // 计算热图颜色
    private func cellColor(for count: Int) -> Color {
        switch count {
        case 0:
            return Color(.systemGray6)
        case 1:
            return Color.blue.opacity(0.3)
        case 2:
            return Color.blue.opacity(0.5)
        case 3:
            return Color.blue.opacity(0.7)
        default:
            return Color.blue
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            let data = contributionData.sorted(by: { $0.key > $1.key })
            let weeks = stride(from: 0, to: data.count, by: 7).map { i in
                Array(data[i..<min(i+7, data.count)])
            }
            
            HStack(alignment: .top, spacing: 4) {
                // 显示月份标签
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(getRecentMonths(), id: \.self) { month in
                        Text(month)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.trailing, 4)
                
                // 显示贡献图
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 2) {
                        ForEach(Array(weeks.enumerated()), id: \.offset) { _, week in
                            VStack(spacing: 2) {
                                ForEach(week, id: \.key) { day, count in
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(cellColor(for: count))
                                        .frame(width: 10, height: 10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 2)
                                                .stroke(Color.secondary.opacity(0.1), lineWidth: 0.5)
                                        )
                                        .help("\(formattedDate(day)): \(count)篇日记")
                                }
                            }
                        }
                    }
                }
                .padding(.top, 18) // 为月份标签留出空间
            }
            
            // 图例
            HStack(spacing: 8) {
                Text("贡献值:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 2) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(cellColor(for: 0))
                        .frame(width: 10, height: 10)
                    Text("0")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 2) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(cellColor(for: 1))
                        .frame(width: 10, height: 10)
                    Text("1")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 2) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(cellColor(for: 2))
                        .frame(width: 10, height: 10)
                    Text("2")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 2) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(cellColor(for: 3))
                        .frame(width: 10, height: 10)
                    Text("3")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 2) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(cellColor(for: 4))
                        .frame(width: 10, height: 10)
                    Text("4+")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text("记录总数: \(contributionData.values.reduce(0, +))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // 获取最近几个月的月份名称
    private func getRecentMonths() -> [String] {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "M月"
        
        let today = Date()
        var result: [String] = []
        
        for i in 0..<3 {
            if let date = calendar.date(byAdding: .month, value: -i, to: today) {
                let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
                if i == 0 || calendar.component(.day, from: date) < 15 {
                    result.append(formatter.string(from: firstDayOfMonth))
                }
            }
        }
        
        return result
    }
    
    // 格式化日期
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }
}

struct GitHubStyleContributionView_Previews: PreviewProvider {
    static var previews: some View {
        GitHubStyleContributionView(entries: [])
            .frame(height: 160)
            .padding()
    }
} 