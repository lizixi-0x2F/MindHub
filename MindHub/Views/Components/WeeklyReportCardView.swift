import SwiftUI

struct WeeklyReportCardView: View {
    let report: WeeklyReport?
    var onTapViewDetails: () -> Void
    @State private var isExpanded: Bool = false
    
    private var hasReport: Bool {
        return report != nil
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 标题栏
            HStack {
                Image(systemName: "chart.bar.doc.horizontal")
                    .foregroundColor(ThemeColors.accent)
                    .font(.system(size: 18))
                
                Text("周报")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(ThemeColors.textPrimary)
                
                Spacer()
                
                if hasReport {
                    Text(report!.dateRangeText)
                        .font(.system(size: 12))
                        .foregroundColor(ThemeColors.textSecondary)
                }
                
                Button(action: {
                    withAnimation(.easeOut(duration: 0.25)) {
                        isExpanded.toggle()
                    }
                }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(ThemeColors.textSecondary)
                        .frame(width: 28, height: 28)
                        .background(ThemeColors.surface2)
                        .cornerRadius(14)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            if isExpanded && hasReport {
                Divider()
                    .opacity(0.15)
                    .padding(.horizontal, 16)
                
                // 报告内容
                VStack(alignment: .leading, spacing: 16) {
                    // 情绪概览
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("情绪概览")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(ThemeColors.textPrimary)
                            
                            Text("•")
                                .foregroundColor(ThemeColors.textSecondary)
                            
                            Text("主导情绪: \(report!.dominantEmotion)")
                                .font(.system(size: 13))
                                .foregroundColor(ThemeColors.textSecondary)
                        }
                        
                        // GitHub风格热力图预览
                        GitHubStyleContributionPreview(intensity: report!.averageValence)
                    }
                    
                    // 摘要文本
                    Text(report!.summary)
                        .font(.system(size: 14))
                        .lineSpacing(5)
                        .foregroundColor(ThemeColors.textPrimary)
                    
                    // 查看详情按钮
                    Button(action: onTapViewDetails) {
                        Text("查看完整周报")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(ThemeColors.accent)
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            } else if !hasReport {
                // 无报告状态
                VStack(spacing: 12) {
                    Text("本周尚未生成周报")
                        .font(.system(size: 14))
                        .foregroundColor(ThemeColors.textSecondary)
                    
                    Text("每周日自动生成，记录越多，分析越准确")
                        .font(.system(size: 12))
                        .foregroundColor(ThemeColors.textSecondary.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            }
        }
        .background(ThemeColors.surface1)
        .cornerRadius(16)
        .shadow(color: ThemeColors.shadow, radius: 4, x: 0, y: 2)
    }
}

// GitHub风格贡献热力图预览组件
struct GitHubStyleContributionPreview: View {
    let intensity: Double // -1 到 1 的值
    
    private func intensityColor(_ value: Double) -> Color {
        let normalizedValue = (value + 1) / 2 // 将 -1 到 1 转换为 0 到 1
        
        if normalizedValue < 0.25 {
            return Color(red: 0.1, green: 0.3, blue: 0.5).opacity(0.5 + normalizedValue)
        } else if normalizedValue < 0.5 {
            return Color(red: 0.1, green: 0.5, blue: 0.7).opacity(0.6 + normalizedValue/2)
        } else if normalizedValue < 0.75 {
            return Color(red: 0.1, green: 0.7, blue: 0.9).opacity(0.7 + normalizedValue/3)
        } else {
            return Color(red: 0.2, green: 0.8, blue: 1.0).opacity(0.8 + normalizedValue/5)
        }
    }
    
    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<7, id: \.self) { index in
                let scaledIntensity = intensity * Double(index + 1) / 7.0
                Rectangle()
                    .fill(intensityColor(scaledIntensity))
                    .frame(width: 15, height: 15)
                    .cornerRadius(2)
            }
            
            Spacer()
            
            // 说明文本
            Text("活跃度")
                .font(.system(size: 12))
                .foregroundColor(ThemeColors.textSecondary)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        WeeklyReportCardView(
            report: WeeklyReport(
                startDate: Date().addingTimeInterval(-7*24*3600),
                endDate: Date(),
                summary: "本周情绪总体表现为平静，平均活跃度0.3，情绪倾向积极(0.5)。记录了7篇日记，涉及主题包括工作、阅读、家庭等。建议：继续保持记录习惯，关注情绪变化，多进行正念冥想练习。",
                averageValence: 0.5,
                averageArousal: 0.3,
                meditationCount: 3,
                journalCount: 7,
                dominantEmotion: "平静"
            ),
            onTapViewDetails: {}
        )
        
        WeeklyReportCardView(
            report: nil,
            onTapViewDetails: {}
        )
    }
    .padding()
    .background(ThemeColors.background)
} 