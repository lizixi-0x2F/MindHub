import SwiftUI
/// GitHub风格卡片组件
struct MindHubCard<Content: View>: View {

    var icon: String?
    var iconColor: Color?
    var content: () -> Content
    
    init(title: String? = nil, icon: String? = nil, iconColor: Color? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.icon = icon
        self.iconColor = iconColor
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 如果有标题，显示标题
            if let title = title {
                HStack(spacing: 8) {
                    // 如果有图标，显示图标
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 18))
                            .foregroundColor(iconColor ?? ThemeColors.accent)
                    }
                    
                    Text(title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(ThemeColors.textPrimary)
                    
                    Spacer()
                }
            }
            
            // 卡片内容
            content()
        }
        .padding(16)
        .background(ThemeColors.surface1)
        .cornerRadius(12)
        .shadow(color: ThemeColors.shadow, radius: 2, x: 0, y: 1)
    }
}

/// 可点击的卡片组件
struct MindHubTappableCard<Content: View>: View {
    var title: String?
    var icon: String?
    var iconColor: Color?
    var action: () -> Void
    var content: () -> Content
    
    @State private var isPressed: Bool = false
    
    init(title: String? = nil, icon: String? = nil, iconColor: Color? = nil, action: @escaping () -> Void, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.icon = icon
        self.iconColor = iconColor
        self.action = action
        self.content = content
    }
    
    var body: some View {
        Button(action: {
            withAnimation(.mindHubStandard) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                action()
                
                withAnimation(.mindHubStandard) {
                    isPressed = false
                }
            }
        }) {
            VStack(alignment: .leading, spacing: 12) {
                // 如果有标题，显示标题
                if let title = title {
                    HStack(spacing: 8) {
                        // 如果有图标，显示图标
                        if let icon = icon {
                            Image(systemName: icon)
                                .font(.system(size: 18))
                                .foregroundColor(iconColor ?? ThemeColors.accent)
                        }
                        
                        Text(title)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(ThemeColors.textPrimary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundColor(ThemeColors.textSecondary)
                    }
                }
                
                // 卡片内容
                content()
            }
            .padding(16)
            .background(ThemeColors.surface1)
            .cornerRadius(12)
            .shadow(color: ThemeColors.shadow, radius: isPressed ? 1 : 2, x: 0, y: isPressed ? 0 : 1)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.mindHubStandard, value: isPressed)
    }
}

/// 指标卡片组件
struct MindHubMetricCard: View {
    var title: String
    var value: String
    var icon: String
    var iconColor: Color
    var trend: Double? // 可选的趋势变化
    
    init(title: String, value: String, icon: String, iconColor: Color = ThemeColors.accent, trend: Double? = nil) {
        self.title = title
        self.value = value
        self.icon = icon
        self.iconColor = iconColor
        self.trend = trend
    }
    
    var body: some View {
        MindHubCard {
            VStack(alignment: .leading, spacing: 16) {
                // 图标
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(iconColor)
                }
                
                // 数值和标题
                VStack(alignment: .leading, spacing: 4) {
                    Text(value)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(ThemeColors.textPrimary)
                    
                    HStack(spacing: 4) {
                        Text(title)
                            .font(.caption)
                            .foregroundColor(ThemeColors.textSecondary)
                        
                        // 如果有趋势变化，显示趋势
                        if let trend = trend {
                            HStack(spacing: 2) {
                                Image(systemName: trend >= 0 ? "arrow.up" : "arrow.down")
                                    .font(.system(size: 9))
                                
                                Text(String(format: "%.1f%%", abs(trend)))
                                    .font(.system(size: 11))
                            }
                            .foregroundColor(trend >= 0 ? .green : .red)
                        }
                    }
                }
            }
        }
    }
}

// 预览
struct MindHubCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            MindHubCard(title: "标准卡片", icon: "star.fill", iconColor: .yellow) {
                Text("这是一个标准卡片的内容区域")
                    .foregroundColor(ThemeColors.textPrimary)
                    .padding(.top, 8)
            }
            
            MindHubTappableCard(title: "可点击卡片", icon: "bell.fill", iconColor: .red, action: {}) {
                Text("点击此卡片将触发操作")
                    .foregroundColor(ThemeColors.textPrimary)
                    .padding(.top, 8)
            }
            
            MindHubMetricCard(
                title: "冥想次数",
                value: "12",
                icon: "brain",
                iconColor: .blue,
                trend: 8.5
            )
        }
        .padding()
        .background(ThemeColors.base)
        .previewLayout(.sizeThatFits)
    }
}