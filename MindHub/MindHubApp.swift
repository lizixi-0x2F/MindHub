import SwiftUI
import UserNotifications
import BackgroundTasks

@main
struct MindHubApp: App {
    @StateObject private var journalViewModel = JournalViewModel()
    @StateObject private var appSettings = AppSettings()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(journalViewModel)
                .environmentObject(appSettings)
                .onAppear {
                    setupApp()
                }
        }
    }
    
    private func setupApp() {
        // 设置通知权限
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                setupReminderNotifications()
            }
        }
        
        // 如果是首次启动，确保数据已加载
        if appSettings.isFirstLaunch {
            journalViewModel.loadEntries() // 加载示例数据
            appSettings.isFirstLaunch = false
        }
    }
    
    private func setupReminderNotifications() {
        if appSettings.dailyReminderEnabled {
            scheduleReminderNotification(hour: appSettings.reminderHour, minute: appSettings.reminderMinute)
        }
    }
    
    private func scheduleReminderNotification(hour: Int, minute: Int) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        let content = UNMutableNotificationContent()
        content.title = "记录今天的心情"
        content.body = "花几分钟时间记录一下今天的感受吧"
        content.sound = UNNotificationSound.default
        
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyReminder", content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("通知调度失败: \(error.localizedDescription)")
            }
        }
    }
} 