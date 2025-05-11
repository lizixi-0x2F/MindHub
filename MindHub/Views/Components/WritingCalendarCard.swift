import SwiftUI

struct WritingCalendarCard: View {
    let title: String
    let entries: [JournalEntry]
    
    @State private var selectedMonth: Date = Date()
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let weekdaySymbols = Calendar.current.shortWeekdaySymbols
    
    // 获取选中月份的所有日期
    private var daysInMonth: [Date] {
        let calendar = Calendar.current
        
        // 获取选中月份的第一天
        let components = calendar.dateComponents([.year, .month], from: selectedMonth)
        let firstDayOfMonth = calendar.date(from: components)!
        
        // 获取该月第一天是星期几（0是星期日）
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        
        // 计算需要显示的起始日期（上个月的部分日期）
        let daysToSubtract = firstWeekday - 1
        let startDate = calendar.date(byAdding: .day, value: -daysToSubtract, to: firstDayOfMonth)!
        
        // 生成接下来42天的日期（6周）
        var dates: [Date] = []
        for i in 0..<42 {
            if let date = calendar.date(byAdding: .day, value: i, to: startDate) {
                dates.append(date)
            }
        }
        
        return dates
    }
    
    // 检查指定日期是否有日记
    private func hasEntries(for date: Date) -> Bool {
        let calendar = Calendar.current
        return entries.contains { entry in
            calendar.isDate(entry.date, inSameDayAs: date)
        }
    }
    
    // 获取指定日期的日记数量
    private func entryCount(for date: Date) -> Int {
        let calendar = Calendar.current
        return entries.filter { entry in
            calendar.isDate(entry.date, inSameDayAs: date)
        }.count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .padding(.bottom, 5)
            
            // 月份选择器
            HStack {
                Button(action: {
                    if let newDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedMonth) {
                        selectedMonth = newDate
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Text(monthYearFormatter.string(from: selectedMonth))
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Button(action: {
                    if let newDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedMonth) {
                        selectedMonth = newDate
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.blue)
                }
            }
            .padding(.vertical, 5)
            
            // 星期几标题
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(weekdaySymbols, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // 日历网格
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(daysInMonth, id: \.self) { date in
                    VStack(spacing: 2) {
                        let day = Calendar.current.component(.day, from: date)
                        let isCurrentMonth = Calendar.current.isDate(date, equalTo: selectedMonth, toGranularity: .month)
                        let isToday = Calendar.current.isDateInToday(date)
                        let hasEntry = hasEntries(for: date)
                        
                        Text("\(day)")
                            .font(.footnote)
                            .foregroundColor(isCurrentMonth ? (isToday ? .blue : .primary) : .secondary.opacity(0.5))
                            .fontWeight(isToday ? .bold : .regular)
                        
                        if hasEntry {
                            let count = entryCount(for: date)
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 6, height: 6)
                                .opacity(isCurrentMonth ? 1.0 : 0.3)
                                .overlay(
                                    count > 1 ?
                                    Text("\(count)")
                                        .font(.system(size: 6))
                                        .foregroundColor(.white)
                                    : nil
                                )
                        } else {
                            Circle()
                                .fill(Color.clear)
                                .frame(width: 6, height: 6)
                        }
                    }
                    .frame(height: 30)
                }
            }
        }
        .padding()
        .background(ThemeColors.cardBackground)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    // 月份和年份格式化
    private var monthYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月"
        return formatter
    }
}

struct WritingCalendarCard_Previews: PreviewProvider {
    static var previews: some View {
        // 创建模拟数据
        var entries: [JournalEntry] = []
        let calendar = Calendar.current
        
        for i in 1...10 {
            if let date = calendar.date(byAdding: .day, value: -i * 3, to: Date()) {
                entries.append(JournalEntry(
                    title: "日记 \(i)",
                    content: "这是一篇测试日记",
                    date: date
                ))
            }
        }
        
        return WritingCalendarCard(
            title: "写作日历",
            entries: entries
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
} 