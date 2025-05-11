import SwiftUI

// 为应用提供统一的颜色主题管理
struct ThemeColors {
    // GitHub 风格深色主题 - 根据设计文档更新命名
    static let base = Color(hex: "#0D1117")! // 应用背景，最高层次
    static let surface1 = Color(hex: "#161B22")! // Card/Modal 背景
    static let surface2 = Color(hex: "#21262D")! // 选中、高亮区域
    
    // 强调色及文本颜色 - 根据设计文档更新
    static let accent = Color(hex: "#1ABC9C")! // 主操作、链接、滑块激活
    static let accentAlt = Color(hex: "#3DDC97")! // 次级强调
    static let error = Color(hex: "#E5534B")! // 错误文本/边框
    static let textPrimary = Color(hex: "#E6EDF3")! // 标题、正文
    static let textSecondary = Color(hex: "#8B949E")! // Placeholders、辅助信息
    static let textTertiary = Color(hex: "#6E7681")! // 第三级文本，更低对比度
    
    // 情感颜色 - 用于情感标记和可视化
    static let joyColor = Color(hex: "#2ECC71")! // 喜悦 - 明亮绿色
    static let sadnessColor = Color(hex: "#3498DB")! // 悲伤 - 蓝色
    static let angerColor = Color(hex: "#E74C3C")! // 愤怒 - 红色
    static let fearColor = Color(hex: "#9B59B6")! // 恐惧 - 紫色
    static let surpriseColor = Color(hex: "#F39C12")! // 惊讶 - 橙色
    static let neutralColor = Color(hex: "#95A5A6")! // 中性 - 灰色
    
    // 渐变 - 根据设计文档新增
    static let accentGradient = LinearGradient(
        colors: [Color(hex: "#1ABC9C")!, Color(hex: "#3DDC97")!],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // 兼容性别名，避免代码中引用断开
    static let background = base
    static let cardBackground = surface1
    static let secondaryBackground = surface2
    static let primaryText = textPrimary
    static let secondaryText = textSecondary
    static let tertiaryText = textTertiary
    static let divider = surface2
    static let shadow = Color.black.opacity(0.2)
    
    // 贡献图颜色 - GitHub 风格
    static let emptyCell = surface1
    
    // 图表颜色 - 使用系统颜色
    static let chartColors: [Color] = [
        accent,
        accentAlt,
        Color(hex: "#4078c0")!,
        Color(hex: "#6e40c0")!,
        Color(hex: "#c04078")!
    ]
    
    // 贡献图颜色 - GitHub 风格热力图，根据设计文档采用5级梯度
    static func contributionColor(for level: Int) -> Color {
        switch level {
        case 0:
            return surface1 // 空白单元格色 #161B22
        case 1:
            return accent.opacity(0.2) // 最浅色
        case 2:
            return accent.opacity(0.4) // 浅色
        case 3:
            return accent.opacity(0.7) // 中色
        case 4:
            return accent.opacity(0.9) // 深色
        default:
            return accent // 最深色 #1ABC9C
        }
    }
    
    // 根据情绪分数(-5到+5)返回对应颜色
    static func emotionScoreColor(for score: Int) -> Color {
        switch score {
        case -5 ..< -3:
            return error // 强负面情绪
        case -3 ..< -1:
            return error.opacity(0.7) // 中负面情绪
        case -1 ..< 1:
            return textSecondary // 中性情绪
        case 1 ..< 3:
            return accent.opacity(0.7) // 中正面情绪
        case 3...5:
            return accent // 强正面情绪
        default:
            return textSecondary // 默认为中性
        }
    }
    
    // 卡片样式 - GitHub 风格
    static func cardStyle<T: View>(_ content: T) -> some View {
        content
            .padding(16)
            .background(surface1)
            .cornerRadius(12) // 根据需求文档，组件圆角12pt
    }
    
    // 主按钮样式 - 根据设计文档规范
    static func primaryButtonStyle<T: View>(_ content: T) -> some View {
        content
            .font(.body.weight(.semibold))
            .foregroundColor(textPrimary)
            .frame(maxWidth: .infinity)
            .padding()
            .background(accent)
            .cornerRadius(12)
            .contentShape(Rectangle())
    }
    
    // 次要按钮样式 - GitHub 风格
    static func secondaryButtonStyle<T: View>(_ content: T) -> some View {
        content
            .font(.body.weight(.medium))
            .foregroundColor(accent)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.clear)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(accent, lineWidth: 1)
            )
            .contentShape(Rectangle())
    }
}

// 颜色HEX扩展
extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }
        
        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
}