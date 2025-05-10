import Foundation
import SwiftUI
import Combine

class AppSettings: ObservableObject {
    // 本地存储键
    private enum Keys {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let prefersDarkMode = "prefersDarkMode"
        static let notificationsEnabled = "notificationsEnabled"
        static let emotionAnalysisEnabled = "emotionAnalysisEnabled"
        static let healthDataSyncEnabled = "healthDataSyncEnabled"
        static let lastSyncDate = "lastSyncDate"
        static let userName = "userName"
        static let userBirthday = "userBirthday"
        static let userGender = "userGender"
        static let journalReminderTime = "journalReminderTime"
        static let autoAnalyzeNewEntries = "autoAnalyzeNewEntries"
        static let showEmotionQuadrantChart = "showEmotionQuadrantChart"
        static let showEmotionTrendChart = "showEmotionTrendChart"
    }
    
    // 应用程序设置
    @Published var hasCompletedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: Keys.hasCompletedOnboarding)
        }
    }
    
    @Published var prefersDarkMode: Bool {
        didSet {
            UserDefaults.standard.set(prefersDarkMode, forKey: Keys.prefersDarkMode)
        }
    }
    
    @Published var notificationsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: Keys.notificationsEnabled)
        }
    }
    
    @Published var emotionAnalysisEnabled: Bool {
        didSet {
            UserDefaults.standard.set(emotionAnalysisEnabled, forKey: Keys.emotionAnalysisEnabled)
        }
    }
    
    @Published var healthDataSyncEnabled: Bool {
        didSet {
            UserDefaults.standard.set(healthDataSyncEnabled, forKey: Keys.healthDataSyncEnabled)
        }
    }
    
    @Published var lastSyncDate: Date? {
        didSet {
            UserDefaults.standard.set(lastSyncDate, forKey: Keys.lastSyncDate)
        }
    }
    
    @Published var userName: String {
        didSet {
            UserDefaults.standard.set(userName, forKey: Keys.userName)
        }
    }
    
    @Published var userBirthday: Date? {
        didSet {
            UserDefaults.standard.set(userBirthday, forKey: Keys.userBirthday)
        }
    }
    
    @Published var userGender: String {
        didSet {
            UserDefaults.standard.set(userGender, forKey: Keys.userGender)
        }
    }
    
    @Published var journalReminderTime: Date {
        didSet {
            UserDefaults.standard.set(journalReminderTime, forKey: Keys.journalReminderTime)
        }
    }
    
    @Published var autoAnalyzeNewEntries: Bool {
        didSet {
            UserDefaults.standard.set(autoAnalyzeNewEntries, forKey: Keys.autoAnalyzeNewEntries)
        }
    }
    
    @Published var showEmotionQuadrantChart: Bool {
        didSet {
            UserDefaults.standard.set(showEmotionQuadrantChart, forKey: Keys.showEmotionQuadrantChart)
        }
    }
    
    @Published var showEmotionTrendChart: Bool {
        didSet {
            UserDefaults.standard.set(showEmotionTrendChart, forKey: Keys.showEmotionTrendChart)
        }
    }
    
    // 观察者取消令牌
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // 从 UserDefaults 加载设置
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: Keys.hasCompletedOnboarding)
        self.prefersDarkMode = UserDefaults.standard.bool(forKey: Keys.prefersDarkMode)
        self.notificationsEnabled = UserDefaults.standard.bool(forKey: Keys.notificationsEnabled)
        self.emotionAnalysisEnabled = UserDefaults.standard.bool(forKey: Keys.emotionAnalysisEnabled)
        self.healthDataSyncEnabled = UserDefaults.standard.bool(forKey: Keys.healthDataSyncEnabled)
        self.lastSyncDate = UserDefaults.standard.object(forKey: Keys.lastSyncDate) as? Date
        self.userName = UserDefaults.standard.string(forKey: Keys.userName) ?? ""
        self.userBirthday = UserDefaults.standard.object(forKey: Keys.userBirthday) as? Date
        self.userGender = UserDefaults.standard.string(forKey: Keys.userGender) ?? "未指定"
        
        // 加载情感分析设置
        self.autoAnalyzeNewEntries = UserDefaults.standard.object(forKey: Keys.autoAnalyzeNewEntries) as? Bool ?? true
        self.showEmotionQuadrantChart = UserDefaults.standard.object(forKey: Keys.showEmotionQuadrantChart) as? Bool ?? true
        self.showEmotionTrendChart = UserDefaults.standard.object(forKey: Keys.showEmotionTrendChart) as? Bool ?? true
        
        if let storedTime = UserDefaults.standard.object(forKey: Keys.journalReminderTime) as? Date {
            self.journalReminderTime = storedTime
        } else {
            // 默认提醒时间为晚上9点
            var components = DateComponents()
            components.hour = 21
            components.minute = 0
            self.journalReminderTime = Calendar.current.date(from: components) ?? Date()
        }
    }
    
    // 重置所有设置
    func resetAllSettings() {
        hasCompletedOnboarding = false
        prefersDarkMode = false
        notificationsEnabled = true
        emotionAnalysisEnabled = true
        healthDataSyncEnabled = true
        lastSyncDate = nil
        userName = ""
        userBirthday = nil
        userGender = "未指定"
        autoAnalyzeNewEntries = true
        showEmotionQuadrantChart = true
        showEmotionTrendChart = true
        
        var components = DateComponents()
        components.hour = 21
        components.minute = 0
        journalReminderTime = Calendar.current.date(from: components) ?? Date()
    }
    
    // 完成引导流程
    func completeOnboarding() {
        hasCompletedOnboarding = true
    }
    
    // 更新用户信息
    func updateUserInfo(name: String, birthday: Date?, gender: String) {
        userName = name
        userBirthday = birthday
        userGender = gender
    }
} 