import SwiftUI

struct ContentView: View {
    @EnvironmentObject var healthKitManager: HealthKitManager
    @EnvironmentObject var emotionAnalysisManager: EmotionAnalysisManager
    @EnvironmentObject var appSettings: AppSettings
    
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    VStack {
                        Image(systemName: "chart.bar.fill")
                        Text("仪表盘")
                    }
                }
                .tag(0)
                .accessibility(identifier: "dashboard-tab")
                .accessibilityLabel("仪表盘")
            
            JournalView()
                .tabItem {
                    VStack {
                        Image(systemName: "book.fill")
                        Text("日记")
                    }
                }
                .tag(1)
                .accessibility(identifier: "journal-tab")
                .accessibilityLabel("日记")
            
            EmotionAnalysisView()
                .tabItem {
                    VStack {
                        Image(systemName: "heart.fill")
                        Text("情绪")
                    }
                }
                .tag(2)
                .accessibility(identifier: "emotion-tab")
                .accessibilityLabel("情绪")
                
            HealthDataView()
                .tabItem {
                    VStack {
                        Image(systemName: "heart.text.square.fill")
                        Text("健康")
                    }
                }
                .tag(3)
                .accessibility(identifier: "health-tab")
                .accessibilityLabel("健康")
                
            SettingsView()
                .tabItem {
                    VStack {
                        Image(systemName: "gear")
                        Text("设置")
                    }
                }
                .tag(4)
                .accessibility(identifier: "settings-tab")
                .accessibilityLabel("设置")
        }
        .accessibilityIdentifier("main-tab-view")
        .onAppear {
            // 确保UI测试能正确识别TabBar
            UITabBar.appearance().isAccessibilityElement = true
            UITabBar.appearance().accessibilityTraits = .tabBar
            
            // 请求健康数据权限
            healthKitManager.requestAuthorization()
            
            // 设置默认选项卡
            if !appSettings.hasCompletedOnboarding {
                selectedTab = 4 // 设置选项卡
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(HealthKitManager())
            .environmentObject(EmotionAnalysisManager())
            .environmentObject(AppSettings())
    }
} 