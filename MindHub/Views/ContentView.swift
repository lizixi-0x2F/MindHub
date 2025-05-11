import SwiftUI

struct ContentView: View {
    @EnvironmentObject var journalViewModel: JournalViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 日记视图
            JournalView()
                .tabItem {
                    Label("日记 📝", systemImage: "book.fill")
                }
                .tag(0)
            
            // 统计视图
            DashboardView()
                .tabItem {
                    Label("统计 📊", systemImage: "chart.bar.fill")
                }
                .tag(1)
            
            // 设置视图
            SettingsView()
                .tabItem {
                    Label("设置 ⚙️", systemImage: "gear")
                }
                .tag(2)
        }
        .tint(ThemeColors.accent) // 使用主题颜色
        .onAppear {
            // 加载日记数据
            journalViewModel.loadEntries()
            
            // 设置TabBar样式，使用GitHub风格的深色
            let appearance = UITabBarAppearance()
            appearance.configureWithDefaultBackground()
            appearance.backgroundColor = UIColor(ThemeColors.base)
            
            UITabBar.appearance().standardAppearance = appearance
            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(JournalViewModel())
            .preferredColorScheme(.dark)
    }
} 