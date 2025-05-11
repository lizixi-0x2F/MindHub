import SwiftUI
import Charts
import Foundation

// 直接在视图文件中定义ViewModel以避免循环引用
@MainActor
class WeeklyReportViewModel: ObservableObject {
    @Published var weeklyReports: [WeeklyReport] = []
    @Published var currentWeekOffset: Int = 0
    @Published var isGenerating: Bool = false
    
    var journalViewModel: JournalViewModel
    
    init(journalViewModel: JournalViewModel) {
        self.journalViewModel = journalViewModel
        loadReports()
    }
    
    // 加载周报
    func loadReports() {
        // 从JournalViewModel获取
        self.weeklyReports = journalViewModel.weeklyReports
    }
    
    // 创建周报
    func createWeeklyReport(for weekOffset: Int) async {
        // 避免重复生成
        if let _ = getReport(for: weekOffset) {
            return
        }
        
        isGenerating = true
        
        // 模拟延迟操作
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // 生成周报并保存
        let report = await journalViewModel.createAndSaveWeeklyReport(for: weekOffset)
        
        // 更新UI
        if let report = report {
            self.weeklyReports.append(report)
            self.weeklyReports.sort { $0.startDate > $1.startDate }
        }
        self.isGenerating = false
    }
    
    // 获取特定周的周报
    func getReport(for weekOffset: Int) -> WeeklyReport? {
        let calendar = Calendar.current
        let today = Date()
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: today)!))!
        let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart)!
        
        return weeklyReports.first { report in
            return (report.startDate >= weekStart && report.startDate <= weekEnd) ||
                   (report.endDate >= weekStart && report.endDate <= weekEnd)
        }
    }
    
    // 获取当前选择周的周报
    var currentReport: WeeklyReport? {
        return getReport(for: currentWeekOffset)
    }
    
    // 切换到上一周
    func previousWeek() {
        currentWeekOffset += 1
    }
    
    // 切换到下一周
    func nextWeek() {
        if currentWeekOffset > 0 {
            currentWeekOffset -= 1
        }
    }
    
    // 获取当前选择周的日期范围文本
    var currentWeekRangeText: String {
        let calendar = Calendar.current
        let today = Date()
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: calendar.date(byAdding: .weekOfYear, value: -currentWeekOffset, to: today)!))!
        let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart)!
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM月dd日"
        
        return "\(dateFormatter.string(from: weekStart)) - \(dateFormatter.string(from: weekEnd))"
    }
}

struct WeeklyReportView: View {
    @EnvironmentObject var journalViewModel: JournalViewModel
    @StateObject private var viewModel: WeeklyReportViewModel
    
    init() {
        // 创建WeeklyReportViewModel，将在onAppear通过environmentObject获取journalViewModel
        self._viewModel = StateObject(wrappedValue: WeeklyReportViewModel(journalViewModel: JournalViewModel()))
    }
    
    var body: some View {
        ZStack {
            // 背景
            ThemeColors.background
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 16) {
                    // 标题和日期范围
                    HStack {
                        Text("情绪周报")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(ThemeColors.textPrimary)
                        
                        Spacer()
                        
                        // 周切换器
                        HStack(spacing: 16) {
                            Button(action: {
                                viewModel.previousWeek()
                            }) {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(ThemeColors.accent)
                            }
                            
                            Text(viewModel.currentWeekRangeText)
                                .font(.system(size: 15))
                                .foregroundColor(ThemeColors.textPrimary)
                            
                            Button(action: {
                                viewModel.nextWeek()
                            }) {
                                Image(systemName: "chevron.right")
                                    .foregroundColor(viewModel.currentWeekOffset > 0 ? ThemeColors.accent : ThemeColors.textSecondary.opacity(0.5))
                            }
                            .disabled(viewModel.currentWeekOffset <= 0)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    if let report = viewModel.currentReport {
                        // 周报主体
                        WeeklyReportContent(report: report)
                    } else {
                        // 无报告状态
                        VStack(spacing: 20) {
                            Image(systemName: "doc.text.magnifyingglass")
                                .font(.system(size: 60))
                                .foregroundColor(ThemeColors.textSecondary.opacity(0.7))
                            
                            Text("该周暂无周报")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(ThemeColors.textPrimary)
                            
                            Text("周报会自动生成，或点击下方按钮手动生成")
                                .font(.system(size: 14))
                                .foregroundColor(ThemeColors.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                            
                            Button(action: {
                                Task {
                                    await viewModel.createWeeklyReport(for: viewModel.currentWeekOffset)
                                }
                            }) {
                                HStack {
                                    if viewModel.isGenerating {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .padding(.trailing, 4)
                                    } else {
                                        Image(systemName: "doc.badge.plus")
                                            .padding(.trailing, 4)
                                    }
                                    
                                    Text(viewModel.isGenerating ? "生成中..." : "生成周报")
                                }
                                .frame(minWidth: 160)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 20)
                                .background(ThemeColors.accent)
                                .cornerRadius(10)
                            }
                            .padding(.top, 8)
                            .disabled(viewModel.isGenerating)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 60)
                    }
                }
            }
        }
        .navigationTitle("情绪周报")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // 更新ViewModel中的journalViewModel引用
            if let journalVM = journalViewModel as JournalViewModel? {
                viewModel.journalViewModel = journalVM
            }
        }
    }
}

// 周报内容组件
struct WeeklyReportContent: View {
    let report: WeeklyReport
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // 情绪摘要卡片
            VStack(alignment: .leading, spacing: 12) {
                Text("情绪摘要")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(ThemeColors.textPrimary)
                
                Text(report.summary)
                    .font(.system(size: 15))
                    .lineSpacing(5)
                    .foregroundColor(ThemeColors.textPrimary)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(ThemeColors.surface1)
            .cornerRadius(12)
            .padding(.horizontal)
            
            // 情绪象限图
            VStack(alignment: .leading, spacing: 12) {
                Text("情绪象限分布")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(ThemeColors.textPrimary)
                
                VStack {
                    // 象限坐标轴
                    ZStack {
                        // 背景网格
                        VStack(spacing: 0) {
                            ForEach(0..<3) { _ in
                                HStack(spacing: 0) {
                                    ForEach(0..<3) { _ in
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.1))
                                            .frame(height: 80)
                                    }
                                }
                            }
                        }
                        
                        // 坐标轴
                        Path { path in
                            // 水平轴
                            path.move(to: CGPoint(x: 0, y: 120))
                            path.addLine(to: CGPoint(x: 240, y: 120))
                            
                            // 垂直轴
                            path.move(to: CGPoint(x: 120, y: 0))
                            path.addLine(to: CGPoint(x: 120, y: 240))
                        }
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        
                        // 情绪标签
                        VStack {
                            HStack {
                                Text("焦虑")
                                    .font(.system(size: 12))
                                    .foregroundColor(ThemeColors.textSecondary)
                                    .frame(width: 100, height: 100, alignment: .leading)
                                
                                Text("兴奋")
                                    .font(.system(size: 12))
                                    .foregroundColor(ThemeColors.textSecondary)
                                    .frame(width: 100, height: 100, alignment: .trailing)
                            }
                            
                            HStack {
                                Text("低落")
                                    .font(.system(size: 12))
                                    .foregroundColor(ThemeColors.textSecondary)
                                    .frame(width: 100, height: 100, alignment: .leading)
                                
                                Text("满足")
                                    .font(.system(size: 12))
                                    .foregroundColor(ThemeColors.textSecondary)
                                    .frame(width: 100, height: 100, alignment: .trailing)
                            }
                        }
                        .frame(width: 240, height: 240)
                        
                        // 情绪点
                        Circle()
                            .fill(ThemeColors.accent)
                            .frame(width: 20, height: 20)
                            .position(x: 120 + report.averageValence * 100, y: 120 - report.averageArousal * 100)
                    }
                    .frame(width: 240, height: 240)
                    .clipped()
                    
                    // 坐标轴说明
                    HStack {
                        Text("消极")
                            .font(.system(size: 12))
                            .foregroundColor(ThemeColors.textSecondary)
                        
                        Spacer()
                        
                        Text("效价")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(ThemeColors.textSecondary)
                        
                        Spacer()
                        
                        Text("积极")
                            .font(.system(size: 12))
                            .foregroundColor(ThemeColors.textSecondary)
                    }
                    .frame(width: 240)
                    .padding(.top, 4)
                    
                    // 垂直轴说明 - 旋转文本
                    HStack {
                        Text("唤起度")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(ThemeColors.textSecondary)
                            .rotationEffect(Angle(degrees: -90))
                            .frame(width: 12)
                            .offset(x: -132, y: -120)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical)
            }
            .padding()
            .background(ThemeColors.surface1)
            .cornerRadius(12)
            .padding(.horizontal)
            
            // 统计指标
            VStack(alignment: .leading, spacing: 12) {
                Text("本周统计")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(ThemeColors.textPrimary)
                
                HStack(spacing: 20) {
                    // 日记数量
                    VStack {
                        Text("\(report.journalCount)")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(ThemeColors.accent)
                        
                        Text("日记数量")
                            .font(.system(size: 12))
                            .foregroundColor(ThemeColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    
                    // 主导情绪
                    VStack {
                        Text(report.dominantEmotion)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(ThemeColors.accent)
                        
                        Text("主导情绪")
                            .font(.system(size: 12))
                            .foregroundColor(ThemeColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    
                    // 情绪波动
                    VStack {
                        let emotionValue = abs(report.averageValence)
                        Text(String(format: "%.1f", emotionValue))
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(ThemeColors.accent)
                        
                        Text("情绪强度")
                            .font(.system(size: 12))
                            .foregroundColor(ThemeColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.vertical, 8)
            }
            .padding()
            .background(ThemeColors.surface1)
            .cornerRadius(12)
            .padding(.horizontal)
            
            Spacer(minLength: 40)
        }
    }
}

#Preview {
    WeeklyReportView()
} 