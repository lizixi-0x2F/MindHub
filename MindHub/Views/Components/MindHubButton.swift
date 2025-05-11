import SwiftUI

/// 符合GitHub风格的按钮组件
struct MindHubButton: View {
    enum ButtonStyle {
        case primary
        case secondary
    }
    
    let title: String
    let icon: String? // SF Symbol名称
    let style: ButtonStyle
    let action: () -> Void
    
    @State private var isPressed: Bool = false
    
    init(title: String, icon: String? = nil, style: ButtonStyle = .primary, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.style = style
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            withAnimation(.mindHubStandard) {
                isPressed = true
            }
            
            // 延迟执行操作，以便动画完成
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                action()
                
                withAnimation(.mindHubStandard) {
                    isPressed = false
                }
            }
        }) {
            HStack(spacing: 8) {
                // 如果有图标，显示图标
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16))
                }
                
                Text(title)
                    .font(.body.weight(.semibold))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                style == .primary ? ThemeColors.accent : Color.clear
            )
            .foregroundColor(
                style == .primary ? ThemeColors.textPrimary : ThemeColors.accent
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(style == .secondary ? ThemeColors.accent : Color.clear, lineWidth: 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle()) // 使用PlainButtonStyle避免系统默认按钮样式
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.mindHubStandard, value: isPressed)
    }
}

/// 返回按钮组件
struct MindHubBackButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .medium))
                
                Text("返回")
                    .font(.body.weight(.medium))
            }
            .foregroundColor(ThemeColors.accent)
            .padding(8)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// 图标按钮组件
struct MindHubIconButton: View {
    let icon: String
    let size: CGFloat
    let action: () -> Void
    
    @State private var isPressed: Bool = false
    
    init(icon: String, size: CGFloat = 44, action: @escaping () -> Void) {
        self.icon = icon
        self.size = size
        self.action = action
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
            Image(systemName: icon)
                .font(.system(size: size * 0.4, weight: .medium))
                .foregroundColor(ThemeColors.textPrimary)
                .frame(width: size, height: size)
                .background(ThemeColors.surface2)
                .cornerRadius(size / 2)
                .contentShape(Circle())
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.mindHubStandard, value: isPressed)
    }
}

// 预览
struct MindHubButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            MindHubButton(title: "主操作按钮", icon: "play.fill", action: {})
            
            MindHubButton(title: "次要按钮", icon: "bookmark", style: .secondary, action: {})
            
            MindHubBackButton(action: {})
            
            HStack(spacing: 20) {
                MindHubIconButton(icon: "heart.fill", action: {})
                MindHubIconButton(icon: "bookmark", action: {})
                MindHubIconButton(icon: "square.and.arrow.up", action: {})
            }
        }
        .padding()
        .background(ThemeColors.base)
        .previewLayout(.sizeThatFits)
    }
} 