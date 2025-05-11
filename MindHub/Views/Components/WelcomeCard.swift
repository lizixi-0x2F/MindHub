import SwiftUI

struct WelcomeCard: View {
    @EnvironmentObject var appSettings: AppSettings
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text("欢迎回来 👋")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("\(appSettings.userName.isEmpty ? "用户" : appSettings.userName)")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.accentColor)
            }
            
            Text("今天是记录情绪的好时机 ✨ 写下你的感受，让我们一起了解你的情绪变化。")
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

struct WelcomeCard_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeCard()
            .environmentObject(AppSettings())
            .previewLayout(.sizeThatFits)
            .padding()
    }
} 