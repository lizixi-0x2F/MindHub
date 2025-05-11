import SwiftUI

struct JournalView: View {
    @EnvironmentObject var journalViewModel: JournalViewModel
    @State private var searchText: String = ""
    @State private var showingNewEntrySheet = false
    @State private var isEditing = false
    @State private var viewMode: JournalViewMode = .list
    @State private var filterMode: JournalFilterMode = .all
    @State private var selectedTag: String? = nil
    @State private var selectedMood: String? = nil
    @State private var showingStatisticsSheet = false
    
    var body: some View {
        NavigationView {
            JournalViewContent(
                filteredEntries: filteredEntries,
                searchText: $searchText,
                showingNewEntrySheet: $showingNewEntrySheet,
                isEditing: $isEditing,
                viewMode: $viewMode,
                filterMode: $filterMode,
                selectedTag: $selectedTag,
                selectedMood: $selectedMood,
                allTags: allTags,
                allMoods: allMoods,
                showingStatisticsSheet: $showingStatisticsSheet
            )
            .onAppear {
                journalViewModel.loadEntries()
            }
            .sheet(isPresented: $showingStatisticsSheet) {
                JournalStatisticsView(entries: journalViewModel.entries)
            }
        }
    }
    
    // 过滤后的日记条目
    private var filteredEntries: [JournalEntry] {
        var entries = journalViewModel.entries
        
        // 应用搜索过滤
        if !searchText.isEmpty {
            entries = entries.filter { entry in
                entry.title.localizedCaseInsensitiveContains(searchText) ||
                entry.content.localizedCaseInsensitiveContains(searchText) ||
                entry.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        // 应用分类过滤
        switch filterMode {
        case .all:
            break // 不需要额外过滤
        case .favorites:
            entries = entries.filter { $0.isFavorite }
        case .byTag:
            if let tag = selectedTag {
                entries = entries.filter { $0.tags.contains(tag) }
            }
        case .byMood:
            if let selectedMood = selectedMood, 
               let mood = Mood(rawValue: selectedMood) {
                entries = entries.filter { $0.mood == mood }
            }
        }
        
        return entries
    }
    
    // 所有标签（用于过滤）
    private var allTags: [String] {
        var tags = Set<String>()
        for entry in journalViewModel.entries {
            for tag in entry.tags {
                tags.insert(tag)
            }
        }
        return Array(tags).sorted()
    }
    
    // 所有情绪（用于过滤）
    private var allMoods: [String] {
        var moods = Set<String>()
        for entry in journalViewModel.entries {
            moods.insert(entry.mood.rawValue)
        }
        return Array(moods).sorted()
    }
}

enum JournalViewMode {
    case list
    case calendar
}

enum JournalFilterMode {
    case all
    case favorites
    case byTag
    case byMood
}

// 主体内容
struct JournalViewContent: View {
    let filteredEntries: [JournalEntry]
    @Binding var searchText: String
    @Binding var showingNewEntrySheet: Bool
    @Binding var isEditing: Bool
    @Binding var viewMode: JournalViewMode
    @Binding var filterMode: JournalFilterMode
    @Binding var selectedTag: String?
    @Binding var selectedMood: String?
    let allTags: [String]
    let allMoods: [String]
    @Binding var showingStatisticsSheet: Bool
    @EnvironmentObject var journalViewModel: JournalViewModel
    @State private var showingFilterSheet = false
    
    var body: some View {
        VStack {
            // 搜索栏
            SearchBar(text: $searchText, placeholder: "搜索日记...")
                .padding(.horizontal)
            
            // 功能区
            HStack {
                // 视图模式切换
                Picker("查看模式", selection: $viewMode) {
                    Text("列表").tag(JournalViewMode.list)
                    Text("日历").tag(JournalViewMode.calendar)
                }
                .pickerStyle(SegmentedPickerStyle())
                
                Spacer()
                
                // 分类过滤按钮 - 使用原生风格
                Button(action: {
                    showingFilterSheet = true
                }) {
                    HStack {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                        Text(filterButtonText)
                    }
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal)
            
            if filteredEntries.isEmpty {
                EmptyJournalView(showingNewEntrySheet: $showingNewEntrySheet)
            } else {
                if viewMode == .list {
                    JournalEntryList(
                        entries: filteredEntries,
                        showingNewEntrySheet: $showingNewEntrySheet
                    )
                } else {
                    JournalCalendarView(entries: filteredEntries)
                }
            }
        }
        .navigationTitle("我的日记")
        .toolbar {
            JournalToolbarItems(
                filteredEntries: filteredEntries,
                showingNewEntrySheet: $showingNewEntrySheet,
                isEditing: $isEditing,
                showingStatisticsSheet: $showingStatisticsSheet
            )
        }
        .sheet(isPresented: $showingNewEntrySheet) {
            NewJournalEntryView(onSave: { newEntry in 
                journalViewModel.addEntry(newEntry)
            })
                .environmentObject(journalViewModel)
        }
        .sheet(isPresented: $showingFilterSheet) {
            JournalFilterView(
                filterMode: $filterMode,
                selectedTag: $selectedTag,
                selectedMood: $selectedMood,
                allTags: allTags,
                allMoods: allMoods
            )
        }
    }
    
    // 过滤按钮的文本
    private var filterButtonText: String {
        switch filterMode {
        case .all:
            return "全部"
        case .favorites:
            return "收藏"
        case .byTag:
            return selectedTag ?? "标签"
        case .byMood:
            return selectedMood ?? "情绪"
        }
    }
}

// 过滤视图
struct JournalFilterView: View {
    @Binding var filterMode: JournalFilterMode
    @Binding var selectedTag: String?
    @Binding var selectedMood: String?
    let allTags: [String]
    let allMoods: [String]
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("筛选方式")) {
                    Button(action: {
                        filterMode = .all
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Text("全部日记")
                            Spacer()
                            if filterMode == .all {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                    
                    Button(action: {
                        filterMode = .favorites
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Text("收藏日记")
                            Spacer()
                            if filterMode == .favorites {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
                
                // 标签筛选
                if !allTags.isEmpty {
                    Section(header: Text("按标签筛选")) {
                        ForEach(allTags, id: \.self) { tag in
                            Button(action: {
                                filterMode = .byTag
                                selectedTag = tag
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                HStack {
                                    Text(tag)
                                    Spacer()
                                    if filterMode == .byTag && selectedTag == tag {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    }
                }
                
                // 情绪筛选
                if !allMoods.isEmpty {
                    Section(header: Text("按情绪筛选")) {
                        ForEach(allMoods, id: \.self) { mood in
                            Button(action: {
                                filterMode = .byMood
                                selectedMood = mood
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                HStack {
                                    Text(mood)
                                    Spacer()
                                    if filterMode == .byMood && selectedMood == mood {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("筛选日记")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("取消") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

// 日历视图
struct JournalCalendarView: View {
    let entries: [JournalEntry]
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    @EnvironmentObject var journalViewModel: JournalViewModel
    
    private var entriesForSelectedDate: [JournalEntry] {
        let calendar = Calendar.current
        return entries.filter { entry in
            calendar.isDate(entry.date, inSameDayAs: selectedDate)
        }
    }
    
    var body: some View {
        VStack {
            // 日历部分
            CalendarHeaderView(currentMonth: $currentMonth)
            
            CalendarGridView(
                entries: entries,
                currentMonth: $currentMonth,
                selectedDate: $selectedDate
            )
            
            // 选中日期的日记列表
            VStack {
                Text("\(selectedDate, style: .date)")
                    .font(.headline)
                    .padding(.top)
                
                if entriesForSelectedDate.isEmpty {
                    Text("当天没有日记")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        ForEach(entriesForSelectedDate) { entry in
                            NavigationLink(destination: JournalDetailView(entry: entry, journalViewModel: journalViewModel)) {
                                JournalEntryRow(entry: entry)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .padding(.horizontal)
        }
    }
}

struct CalendarHeaderView: View {
    @Binding var currentMonth: Date
    private let weekdays = ["日", "一", "二", "三", "四", "五", "六"]
    
    var body: some View {
        VStack {
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                }
                
                Spacer()
                
                Text(monthYearString(from: currentMonth))
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.horizontal)
            
            HStack {
                ForEach(weekdays, id: \.self) { weekday in
                    Text(weekday)
                        .frame(maxWidth: .infinity)
                        .fontWeight(.medium)
                }
            }
            .padding(.top, 8)
        }
    }
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月"
        return formatter.string(from: date)
    }
    
    private func previousMonth() {
        if let newDate = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = newDate
        }
    }
    
    private func nextMonth() {
        if let newDate = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = newDate
        }
    }
}

struct CalendarGridView: View {
    let entries: [JournalEntry]
    @Binding var currentMonth: Date
    @Binding var selectedDate: Date
    
    private var daysInMonth: [[Date?]] {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: currentMonth)
        let month = calendar.component(.month, from: currentMonth)
        
        let startDate = calendar.date(from: DateComponents(year: year, month: month, day: 1))!
        let range = calendar.range(of: .day, in: .month, for: startDate)!
        let numDays = range.count
        
        let firstWeekday = calendar.component(.weekday, from: startDate)
        let offsetDays = firstWeekday - 1
        
        var days: [Date?] = Array(repeating: nil, count: offsetDays)
        
        for day in 1...numDays {
            if let date = calendar.date(from: DateComponents(year: year, month: month, day: day)) {
                days.append(date)
            }
        }
        
        // 补全最后一行
        let remainingDays = 42 - days.count
        days.append(contentsOf: Array(repeating: nil, count: remainingDays))
        
        // 分成6行
        var result: [[Date?]] = []
        for i in 0..<6 {
            result.append(Array(days[i*7..<(i+1)*7]))
        }
        
        return result
    }
    
    var body: some View {
        VStack {
            ForEach(daysInMonth.indices, id: \.self) { rowIndex in
                HStack {
                    ForEach(0..<7, id: \.self) { colIndex in
                        let date = daysInMonth[rowIndex][colIndex]
                        if let date = date {
                            CalendarDayView(
                                date: date,
                                isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                                hasEntries: hasEntries(for: date)
                            )
                            .onTapGesture {
                                selectedDate = date
                            }
                        } else {
                            Color.clear
                                .frame(width: 32, height: 32)
                        }
                    }
                }
            }
        }
    }
    
    private var calendar: Calendar {
        return Calendar.current
    }
    
    private func hasEntries(for date: Date) -> Bool {
        return entries.contains { entry in
            calendar.isDate(entry.date, inSameDayAs: date)
        }
    }
}

struct CalendarDayView: View {
    let date: Date
    let isSelected: Bool
    let hasEntries: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(isSelected ? Color.blue : Color.clear)
                .frame(width: 32, height: 32)
            
            Text("\(day)")
                .fontWeight(isToday ? .bold : .regular)
                .foregroundColor(textColor)
            
            if hasEntries {
                Circle()
                    .fill(Color.green)
                    .frame(width: 5, height: 5)
                    .offset(y: 12)
            }
        }
        .frame(width: 40, height: 40)
    }
    
    private var day: Int {
        Calendar.current.component(.day, from: date)
    }
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    private var textColor: Color {
        if isSelected {
            return .white
        } else if isToday {
            return .blue
        } else {
            return .primary
        }
    }
}

// 工具栏视图
struct JournalToolbarItems: ToolbarContent {
    let filteredEntries: [JournalEntry]
    @Binding var showingNewEntrySheet: Bool
    @Binding var isEditing: Bool
    @Binding var showingStatisticsSheet: Bool
    
    var body: some ToolbarContent {
        #if os(iOS)
        ToolbarItem(placement: .navigationBarLeading) {
            HStack {
                EditButton()
                    .disabled(filteredEntries.isEmpty)
                
                Button(action: {
                    showingStatisticsSheet = true
                }) {
                    Image(systemName: "chart.bar")
                }
            }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: {
                showingNewEntrySheet = true
            }) {
                Image(systemName: "square.and.pencil")
            }
        }
        #else
        ToolbarItem {
            Button(action: {
                isEditing.toggle()
            }) {
                Text(isEditing ? "完成" : "编辑")
            }
            .disabled(filteredEntries.isEmpty)
        }
        
        ToolbarItem {
            Button(action: {
                showingStatisticsSheet = true
            }) {
                Image(systemName: "chart.bar")
            }
        }
        
        ToolbarItem {
            Button(action: {
                showingNewEntrySheet = true
            }) {
                Image(systemName: "square.and.pencil")
            }
        }
        #endif
    }
}

// 空日记视图
struct EmptyJournalView: View {
    @Binding var showingNewEntrySheet: Bool
    
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "book.closed")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("没有找到日记")
                .font(.title2)
            
            Text("开始记录您的第一篇日记吧")
                .foregroundColor(.secondary)
            
            Button(action: {
                showingNewEntrySheet = true
            }) {
                Text("新建日记")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.top, 10)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// 日记条目列表
struct JournalEntryList: View {
    let entries: [JournalEntry]
    @Binding var showingNewEntrySheet: Bool
    @EnvironmentObject var journalViewModel: JournalViewModel
    
    var body: some View {
        List {
            ForEach(entries) { entry in
                NavigationLink(destination: JournalDetailView(entry: entry, journalViewModel: journalViewModel)) {
                    JournalEntryRow(entry: entry)
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        journalViewModel.deleteEntry(entry)
                    } label: {
                        Label("删除", systemImage: "trash")
                    }
                    
                    Button {
                        journalViewModel.toggleFavorite(entry)
                    } label: {
                        Label(
                            entry.isFavorite ? "取消收藏" : "收藏",
                            systemImage: entry.isFavorite ? "star.slash" : "star"
                        )
                    }
                    .tint(.yellow)
                }
            }
        }
        #if os(iOS)
        .listStyle(InsetGroupedListStyle())
        #else
        .listStyle(DefaultListStyle())
        #endif
    }
}

// 日记条目行视图
struct JournalEntryRow: View {
    let entry: JournalEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // 标题和收藏状态
            JournalEntryTitle(title: entry.title, isFavorite: entry.isFavorite)
            
            // 摘要
            Text(entry.summary)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            // 底部元信息
            JournalEntryMeta(entry: entry)
        }
        .padding(.vertical, 5)
    }
}

// 日记标题和收藏状态
struct JournalEntryTitle: View {
    let title: String
    let isFavorite: Bool
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
            
            Spacer()
            
            if isFavorite {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
            }
        }
    }
}

// 日记底部元信息
struct JournalEntryMeta: View {
    let entry: JournalEntry
    
    var body: some View {
        HStack {
            Text(entry.dateText)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(entry.moodIconName)
                .font(.caption)
            
            if !entry.tags.isEmpty {
                JournalEntryTags(tags: entry.tags)
            }
        }
    }
}

// 日记标签
struct JournalEntryTags: View {
    let tags: [String]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(tags.prefix(3), id: \.self) { tag in
                    Text(tag)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(.systemGray5))
                        .cornerRadius(4)
                }
                
                if tags.count > 3 {
                    Text("+\(tags.count - 3)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(height: 22)
    }
}

// 搜索栏
struct SearchBar: View {
    @Binding var text: String
    var placeholder: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField(placeholder, text: $text)
                .foregroundColor(.primary)
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct JournalView_Previews: PreviewProvider {
    static var previews: some View {
        JournalView()
            .environmentObject(JournalViewModel())
    }
}

// 日记统计视图
struct JournalStatisticsView: View {
    let entries: [JournalEntry]
    @Environment(\.presentationMode) var presentationMode
    
    // 总天数统计
    private var totalDaysWithEntries: Int {
        let calendar = Calendar.current
        var daysSet = Set<Date>()
        
        for entry in entries {
            let components = calendar.dateComponents([.year, .month, .day], from: entry.date)
            if let date = calendar.date(from: components) {
                daysSet.insert(date)
            }
        }
        
        return daysSet.count
    }
    
    // 连续记录天数
    private var streakDays: Int {
        guard !entries.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var days = Set<Date>()
        
        // 收集所有日记日期
        for entry in entries {
            let entryDay = calendar.startOfDay(for: entry.date)
            days.insert(entryDay)
        }
        
        // 计算连续天数
        var streakCount = 0
        var currentDate = today
        
        while days.contains(currentDate) {
            streakCount += 1
            if let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate) {
                currentDate = previousDay
            } else {
                break
            }
        }
        
        return streakCount
    }
    
    // 情绪统计
    private var moodStats: [(mood: String, count: Int)] {
        var moodCounts: [String: Int] = [:]
        
        for entry in entries {
            moodCounts[entry.mood.rawValue, default: 0] += 1
        }
        
        return moodCounts.map { ($0.key, $0.value) }
            .sorted { $0.count > $1.count }
    }
    
    // 每月统计
    private var monthlyStats: [(month: String, count: Int)] {
        var monthlyCounts: [String: Int] = [:]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月"
        
        for entry in entries {
            let monthStr = dateFormatter.string(from: entry.date)
            monthlyCounts[monthStr, default: 0] += 1
        }
        
        // 转换为数组并按日期排序
        let sortedMonths = monthlyCounts.map { ($0.key, $0.value) }
            .sorted { month1, month2 in
                if let date1 = dateFormatter.date(from: month1.0),
                   let date2 = dateFormatter.date(from: month2.0) {
                    return date1 > date2
                }
                return month1.0 > month2.0
            }
        
        return sortedMonths
    }
    
    // 标签使用频率
    private var tagStats: [(tag: String, count: Int)] {
        var tagCounts: [String: Int] = [:]
        
        for entry in entries {
            for tag in entry.tags {
                tagCounts[tag, default: 0] += 1
            }
        }
        
        return tagCounts.map { ($0.key, $0.value) }
            .sorted { $0.count > $1.count }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 概览统计
                    JournalStatsSummaryView(
                        totalEntries: entries.count,
                        totalDays: totalDaysWithEntries,
                        streakDays: streakDays,
                        averageLength: averageEntryLength
                    )
                    
                    Divider()
                    
                    // 情绪统计
                    if !moodStats.isEmpty {
                        JournalStatsSectionView(
                            title: "情绪分析",
                            stats: moodStats.prefix(5).map { "\($0.mood): \($0.count)次" }
                        )
                    }
                    
                    Divider()
                    
                    // 每月统计
                    if !monthlyStats.isEmpty {
                        JournalStatsSectionView(
                            title: "每月记录",
                            stats: monthlyStats.prefix(6).map { "\($0.month): \($0.count)篇" }
                        )
                    }
                    
                    Divider()
                    
                    // 标签统计
                    if !tagStats.isEmpty {
                        JournalStatsSectionView(
                            title: "常用标签",
                            stats: tagStats.prefix(10).map { "\($0.tag): \($0.count)次" }
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("日记统计")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    // 平均日记长度
    private var averageEntryLength: Int {
        guard !entries.isEmpty else { return 0 }
        
        let totalLength = entries.reduce(0) { $0 + $1.content.count }
        return totalLength / entries.count
    }
}

// 统计概览视图
struct JournalStatsSummaryView: View {
    let totalEntries: Int
    let totalDays: Int
    let streakDays: Int
    let averageLength: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("总览")
                .font(.headline)
            
            HStack {
                StatItem(
                    value: "\(totalEntries)",
                    label: "总日记数",
                    systemImage: "doc.text"
                )
                
                Divider()
                
                StatItem(
                    value: "\(totalDays)",
                    label: "记录天数",
                    systemImage: "calendar"
                )
            }
            
            HStack {
                StatItem(
                    value: "\(streakDays)",
                    label: "连续天数",
                    systemImage: "flame"
                )
                
                Divider()
                
                StatItem(
                    value: "\(averageLength)",
                    label: "平均字数",
                    systemImage: "character"
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// 统计项目
struct StatItem: View {
    let value: String
    let label: String
    let systemImage: String
    
    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// 统计区块视图
struct JournalStatsSectionView: View {
    let title: String
    let stats: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            
            ForEach(stats, id: \.self) { stat in
                Text(stat)
                    .padding(.vertical, 4)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
} 