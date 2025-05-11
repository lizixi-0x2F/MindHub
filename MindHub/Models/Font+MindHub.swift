import SwiftUI

// 扩展Font，提供符合设计规范的字体
extension Font {
    // 大标题 (H1) - 用于周报页面的大标题
    static var h1: Font {
        .system(size: 28, weight: .bold, design: .default)
            .leading(.loose) // 对应34pt行高
    }
    
    // 分区标题 (H2) - 用于各区域标题
    static var h2: Font {
        .system(size: 22, weight: .semibold, design: .default)
            .leading(.loose) // 对应28pt行高
    }
    
    // 正文 (Body) - 用于正文内容
    static var bodyText: Font {
        .system(size: 17, weight: .regular, design: .default)
            .leading(.relaxed) // 对应24pt行高
    }
    
    // 说明文字 (Caption) - 用于时间戳/标签
    static var caption: Font {
        .system(size: 13, weight: .regular, design: .default)
            .leading(.relaxed) // 对应18pt行高
    }
    
    // 等宽字体 (Mono) - 用于数据/代码片段
    static var mono: Font {
        .system(size: 15, weight: .medium, design: .monospaced)
            .leading(.relaxed) // 对应20pt行高
    }
}

// 扩展View，提供快捷字体样式修饰符
extension View {
    // 应用H1样式
    func h1Style() -> some View {
        self.font(.h1)
            .foregroundColor(ThemeColors.textPrimary)
    }
    
    // 应用H2样式
    func h2Style() -> some View {
        self.font(.h2)
            .foregroundColor(ThemeColors.textPrimary)
    }
    
    // 应用正文样式
    func bodyStyle() -> some View {
        self.font(.bodyText)
            .foregroundColor(ThemeColors.textPrimary)
    }
    
    // 应用说明文字样式
    func captionStyle() -> some View {
        self.font(.caption)
            .foregroundColor(ThemeColors.textSecondary)
    }
    
    // 应用等宽字体样式
    func monoStyle() -> some View {
        self.font(.mono)
            .foregroundColor(ThemeColors.textPrimary)
    }
}

// 动画扩展，提供标准过渡动画
extension Animation {
    static var mindHubStandard: Animation {
        .easeInOut(duration: 0.2)
    }
} 