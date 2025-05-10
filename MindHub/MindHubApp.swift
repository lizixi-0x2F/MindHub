import SwiftUI
import HealthKit
import BackgroundTasks
import UserNotifications

@main
struct MindHubApp: App {
    // 应用程序状态管理
    @StateObject private var healthKitManager = HealthKitManager()
    @StateObject private var emotionAnalysisManager = EmotionAnalysisManager()
    @StateObject private var appSettings = AppSettings()
    @StateObject private var journalViewModel = JournalViewModel()
    
    // 初始化应用程序
    init() {
        // 确保JournalViewModel在初始化时被正确加载
        let _ = JournalViewModel()
        
        setupBackgroundTasks()
        setupNotifications()
        
        // 预加载初始数据
        preloadData()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(healthKitManager)
                .environmentObject(emotionAnalysisManager)
                .environmentObject(appSettings)
                .environmentObject(journalViewModel)
                .onAppear {
                    // 确保journalViewModel已加载
                    journalViewModel.loadEntries()
                }
        }
    }
    
    // 预加载数据，确保ViewModel准备就绪
    private func preloadData() {
        // 预加载日记数据
        journalViewModel.loadEntries()
        
        // 请求健康数据授权
        healthKitManager.requestAuthorization()
        
        // 预加载健康数据
        healthKitManager.fetchLatestHealthData()
    }
    
    // 设置后台任务
    private func setupBackgroundTasks() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.diary.ozlee.mindhub.emotionanalysis", using: nil) { task in
            self.handleEmotionAnalysisTask(task: task as! BGProcessingTask)
        }
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.diary.ozlee.mindhub.dataprocessing", using: nil) { task in
            self.handleDataProcessingTask(task: task as! BGProcessingTask)
        }
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.diary.ozlee.mindhub.healthdatasync", using: nil) { task in
            self.handleHealthDataSyncTask(task: task as! BGProcessingTask)
        }
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.diary.ozlee.mindhub.refresh", using: nil) { task in
            self.handleRefreshTask(task: task as! BGAppRefreshTask)
        }
    }
    
    // 设置通知
    private func setupNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("通知权限已获取")
            } else {
                print("通知权限被拒绝")
            }
        }
    }
    
    // 处理情感分析后台任务
    private func handleEmotionAnalysisTask(task: BGProcessingTask) {
        scheduleEmotionAnalysisTask()
        
        let operation = emotionAnalysisManager.performBackgroundAnalysis()
        
        task.expirationHandler = {
            operation.cancel()
        }
        
        operation.completionBlock = {
            task.setTaskCompleted(success: !operation.isCancelled)
        }
    }
    
    // 处理数据处理后台任务
    private func handleDataProcessingTask(task: BGProcessingTask) {
        scheduleDataProcessingTask()
        
        // 执行数据处理操作
        
        task.setTaskCompleted(success: true)
    }
    
    // 处理健康数据同步后台任务
    private func handleHealthDataSyncTask(task: BGProcessingTask) {
        scheduleHealthDataSyncTask()
        
        let operation = healthKitManager.syncHealthData()
        
        task.expirationHandler = {
            operation.cancel()
        }
        
        operation.completionBlock = {
            task.setTaskCompleted(success: !operation.isCancelled)
        }
    }
    
    // 处理应用刷新后台任务
    private func handleRefreshTask(task: BGAppRefreshTask) {
        scheduleRefreshTask()
        
        // 执行刷新操作
        
        task.setTaskCompleted(success: true)
    }
    
    // 调度情感分析任务
    private func scheduleEmotionAnalysisTask() {
        let request = BGProcessingTaskRequest(identifier: "com.diary.ozlee.mindhub.emotionanalysis")
        request.requiresNetworkConnectivity = true
        request.requiresExternalPower = false
        request.earliestBeginDate = Date(timeIntervalSinceNow: 3600)
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("无法调度情感分析任务: \(error)")
        }
    }
    
    // 调度数据处理任务
    private func scheduleDataProcessingTask() {
        let request = BGProcessingTaskRequest(identifier: "com.diary.ozlee.mindhub.dataprocessing")
        request.requiresNetworkConnectivity = false
        request.requiresExternalPower = false
        request.earliestBeginDate = Date(timeIntervalSinceNow: 7200)
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("无法调度数据处理任务: \(error)")
        }
    }
    
    // 调度健康数据同步任务
    private func scheduleHealthDataSyncTask() {
        let request = BGProcessingTaskRequest(identifier: "com.diary.ozlee.mindhub.healthdatasync")
        request.requiresNetworkConnectivity = true
        request.requiresExternalPower = false
        request.earliestBeginDate = Date(timeIntervalSinceNow: 3600)
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("无法调度健康数据同步任务: \(error)")
        }
    }
    
    // 调度应用刷新任务
    private func scheduleRefreshTask() {
        let request = BGAppRefreshTaskRequest(identifier: "com.diary.ozlee.mindhub.refresh")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 3600)
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("无法调度应用刷新任务: \(error)")
        }
    }
} 