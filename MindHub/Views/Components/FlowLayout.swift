import SwiftUI

/// 流式布局组件，让多个元素自动换行排列，类似标签云效果
struct FlowLayout<Content: View>: View {
    let spacing: CGFloat
    let content: () -> Content
    @State private var width: CGFloat = 0
    @State private var height: CGFloat = 0
    
    init(spacing: CGFloat = 8, @ViewBuilder content: @escaping () -> Content) {
        self.spacing = spacing
        self.content = content
    }
    
    var body: some View {
        GeometryReader { geometry in
            self.generateContent(in: geometry)
        }
    }
    
    private func generateContent(in geometry: GeometryProxy) -> some View {
        return ZStack(alignment: .topLeading) {
            ForEach(itemWidthsAndOrigins(in: geometry)) { itemData in
                content()
                    .padding([.horizontal, .vertical], spacing)
                    .alignmentGuide(.leading) { _ in -itemData.origin.x }
                    .alignmentGuide(.top) { _ in -itemData.origin.y }
            }
        }
        .background(calculateBackgroundFrame())
        .frame(width: width, height: height)
    }
    
    private func calculateBackgroundFrame() -> some View {
        GeometryReader { geometry in
            Color.clear.onAppear {
                width = geometry.size.width
                height = geometry.size.height
            }
        }
    }
    
    private struct ItemData: Identifiable {
        let id = UUID()
        let width: CGFloat
        let origin: CGPoint
    }
    
    private func itemWidthsAndOrigins(in geometry: GeometryProxy) -> [ItemData] {
        let contentWidth = geometry.size.width
        
        var itemsData: [ItemData] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        
        // 这里简化处理，假设所有项目的宽度相等并自动换行
        // 实际应用中可能需要根据内容计算每个项目的实际宽度
        let itemWidth = (contentWidth / 4) - (spacing * 2)
        
        for _ in 0..<5 { // 假设有5个项目
            if currentX + itemWidth > contentWidth {
                currentX = 0
                currentY += lineHeight + spacing * 2
                lineHeight = 0
            }
            
            let origin = CGPoint(x: currentX, y: currentY)
            itemsData.append(ItemData(width: itemWidth, origin: origin))
            
            currentX += itemWidth + spacing * 2
            lineHeight = max(lineHeight, 30) // 假设项目高度为30
        }
        
        return itemsData
    }
}

#Preview {
    FlowLayout(spacing: 8) {
        Text("SwiftUI")
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.blue.opacity(0.2))
            .cornerRadius(8)
        
        Text("Flutter")
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.green.opacity(0.2))
            .cornerRadius(8)
        
        Text("React Native")
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.orange.opacity(0.2))
            .cornerRadius(8)
        
        Text("Kotlin")
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.purple.opacity(0.2))
            .cornerRadius(8)
        
        Text("Dart")
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.pink.opacity(0.2))
            .cornerRadius(8)
    }
    .padding()
    .frame(height: 200)
} 