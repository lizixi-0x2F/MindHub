import SwiftUI

struct StatisticsCard: View {
    let title: String
    let icon: String // 系统图标名称
    let items: [(String, String)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .font(.headline)
                    .foregroundColor(.accentColor)
                
                Text(title)
                    .font(.headline)
            }
            .padding(.bottom, 5)
            
            ForEach(items, id: \.0) { item in
                HStack {
                    Text(item.0)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(item.1)
                        .fontWeight(.medium)
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(10)
    }
}

struct StatisticsCard_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsCard(
            title: "日记统计",
            icon: "doc.text.fill",
            items: [
                ("总日记数", "42"),
                ("收藏数量", "7"),
                ("本周日记", "5")
            ]
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
} 