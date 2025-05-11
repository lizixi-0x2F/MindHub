import Foundation
import SwiftUI
import Combine
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

class AppSettings: ObservableObject {
    // 键值常量
    private struct Keys {
        static let isFirstLaunch = "isFirstLaunch"
        static let reminderHour = "reminderHour"
        static let reminderMinute = "reminderMinute"
        static let appLockEnabled = "appLockEnabled"
        static let biometricAuthEnabled = "biometricAuthEnabled"
        static let locationTrackingEnabled = "locationTrackingEnabled"
        static let userName = "userName"
        static let emotionAnalysisEnabled = "emotionAnalysisEnabled"
        static let autoGenerateWeeklyReport = "autoGenerateWeeklyReport"
        static let weeklyReportNotificationEnabled = "weeklyReportNotificationEnabled"
        static let dailyReminderEnabled = "dailyReminderEnabled"
    }
    
    // 首次启动标志
    @Published var isFirstLaunch: Bool {
        didSet {
            UserDefaults.standard.set(isFirstLaunch, forKey: Keys.isFirstLaunch)
        }
    }
    
    // 用户名
    @Published var userName: String {
        didSet {
            UserDefaults.standard.set(userName, forKey: Keys.userName)
        }
    }
    
    // 每日提醒
    @Published var dailyReminderEnabled: Bool {
        didSet {
            UserDefaults.standard.set(dailyReminderEnabled, forKey: Keys.dailyReminderEnabled)
        }
    }
    
    // 提醒时间
    @Published var reminderHour: Int {
        didSet {
            UserDefaults.standard.set(reminderHour, forKey: Keys.reminderHour)
        }
    }
    
    @Published var reminderMinute: Int {
        didSet {
            UserDefaults.standard.set(reminderMinute, forKey: Keys.reminderMinute)
        }
    }
    
    // 安全设置
    @Published var appLockEnabled: Bool {
        didSet {
            UserDefaults.standard.set(appLockEnabled, forKey: Keys.appLockEnabled)
        }
    }
    
    @Published var biometricAuthEnabled: Bool {
        didSet {
            UserDefaults.standard.set(biometricAuthEnabled, forKey: Keys.biometricAuthEnabled)
        }
    }
    
    // 位置跟踪
    @Published var locationTrackingEnabled: Bool {
        didSet {
            UserDefaults.standard.set(locationTrackingEnabled, forKey: Keys.locationTrackingEnabled)
        }
    }
    
    // 情感分析
    @Published var emotionAnalysisEnabled: Bool {
        didSet {
            UserDefaults.standard.set(emotionAnalysisEnabled, forKey: Keys.emotionAnalysisEnabled)
        }
    }
    
    // 自动生成周报
    @Published var autoGenerateWeeklyReport: Bool {
        didSet {
            UserDefaults.standard.set(autoGenerateWeeklyReport, forKey: Keys.autoGenerateWeeklyReport)
        }
    }
    
    // 周报通知
    @Published var weeklyReportNotificationEnabled: Bool {
        didSet {
            UserDefaults.standard.set(weeklyReportNotificationEnabled, forKey: Keys.weeklyReportNotificationEnabled)
        }
    }
    
    // 初始化
    init() {
        self.isFirstLaunch = UserDefaults.standard.bool(forKey: Keys.isFirstLaunch)
        self.reminderHour = UserDefaults.standard.integer(forKey: Keys.reminderHour)
        self.reminderMinute = UserDefaults.standard.integer(forKey: Keys.reminderMinute)
        self.appLockEnabled = UserDefaults.standard.bool(forKey: Keys.appLockEnabled)
        self.biometricAuthEnabled = UserDefaults.standard.bool(forKey: Keys.biometricAuthEnabled)
        self.locationTrackingEnabled = UserDefaults.standard.bool(forKey: Keys.locationTrackingEnabled)
        self.userName = UserDefaults.standard.string(forKey: Keys.userName) ?? ""
        self.emotionAnalysisEnabled = UserDefaults.standard.bool(forKey: Keys.emotionAnalysisEnabled)
        self.autoGenerateWeeklyReport = UserDefaults.standard.bool(forKey: Keys.autoGenerateWeeklyReport)
        self.weeklyReportNotificationEnabled = UserDefaults.standard.bool(forKey: Keys.weeklyReportNotificationEnabled)
        self.dailyReminderEnabled = UserDefaults.standard.bool(forKey: Keys.dailyReminderEnabled)
        
        // 设置初始值（如果是首次启动）
        if !UserDefaults.standard.bool(forKey: Keys.isFirstLaunch) {
            setDefaultValues()
        }
    }
    
    // 设置默认值
    private func setDefaultValues() {
        isFirstLaunch = true
        reminderHour = 20  // 默认提醒时间：晚上8点
        reminderMinute = 0
        appLockEnabled = false
        biometricAuthEnabled = false
        locationTrackingEnabled = true
        emotionAnalysisEnabled = true
        autoGenerateWeeklyReport = true
        weeklyReportNotificationEnabled = true
        dailyReminderEnabled = true
    }
    
    // 重置所有设置
    func resetAllSettings() {
        setDefaultValues()
    }
}

// 字体大小枚举 - 保留为固定值
enum FontSize {
    static let textSize: CGFloat = 16
    static let headingSize: CGFloat = 22
    static let titleSize: CGFloat = 28
    static let captionSize: CGFloat = 12
}

// 不要在这里定义 Color.init(hex:) 方法，因为在 ThemeColors.swift 中已经定义过 