import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appSettings: AppSettings
    @EnvironmentObject var healthKitManager: HealthKitManager
    @EnvironmentObject var emotionAnalysisManager: EmotionAnalysisManager
    
    @State private var showingResetAlert = false
    @State private var showingUserProfileSheet = false
    @State private var showingAboutSheet = false
    
    @AppStorage("colorScheme") private var colorScheme: Int = 0
    
    var body: some View {
        NavigationView {
            Form {
                // 用户资料部分
                Section(header: Text("用户资料")) {
                    Button(action: {
                        showingUserProfileSheet = true
                    }) {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                            
                            VStack(alignment: .leading) {
                                Text(appSettings.userName.isEmpty ? "设置用户资料" : appSettings.userName)
                                    .foregroundColor(.primary)
                                
                                if !appSettings.userName.isEmpty {
                                    Text(appSettings.userGender)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // 应用设置部分
                Section(header: Text("应用设置")) {
                    Picker("外观", selection: $colorScheme) {
                        Text("系统").tag(0)
                        Text("浅色").tag(1)
                        Text("深色").tag(2)
                    }
                    
                    Toggle("启用通知", isOn: $appSettings.notificationsEnabled)
                    
                    Toggle("启用情感分析", isOn: $appSettings.emotionAnalysisEnabled)
                    
                    Toggle("启用健康数据同步", isOn: $appSettings.healthDataSyncEnabled)
                }
                
                // 情感分析设置部分
                Section(header: Text("情感分析设置")) {
                    Toggle("自动分析新日记", isOn: $appSettings.autoAnalyzeNewEntries)
                    
                    Toggle("显示唤起度-价效象限图", isOn: $appSettings.showEmotionQuadrantChart)
                    
                    Toggle("显示情绪趋势图", isOn: $appSettings.showEmotionTrendChart)
                    
                    Button("重新分析所有日记") {
                        reanalyzeAllJournals()
                    }
                    .foregroundColor(.blue)
                }
                
                // 提醒设置部分
                Section(header: Text("提醒设置")) {
                    DatePicker("日记提醒时间", selection: $appSettings.journalReminderTime, displayedComponents: .hourAndMinute)
                }
                
                // 数据管理部分
                Section(header: Text("数据管理")) {
                    Button("导出数据") {
                        exportData()
                    }
                    
                    Button("备份设置") {
                        backupSettings()
                    }
                    
                    Button("重置所有设置") {
                        showingResetAlert = true
                    }
                    .foregroundColor(.red)
                }
                
                // 关于部分
                Section(header: Text("关于")) {
                    Button(action: {
                        showingAboutSheet = true
                    }) {
                        HStack {
                            Text("关于 MindHub")
                            Spacer()
                            Text("v1.0.2")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Link("隐私政策", destination: URL(string: "https://mindhub.app/privacy")!)
                    
                    Link("反馈", destination: URL(string: "mailto:support@mindhub.app")!)
                }
            }
            .navigationTitle("设置")
            .alert(isPresented: $showingResetAlert) {
                Alert(
                    title: Text("重置所有设置"),
                    message: Text("这将重置所有应用程序设置。您的日记数据不会被删除。"),
                    primaryButton: .destructive(Text("重置")) {
                        resetAllSettings()
                    },
                    secondaryButton: .cancel()
                )
            }
            .sheet(isPresented: $showingUserProfileSheet) {
                UserProfileView()
            }
            .sheet(isPresented: $showingAboutSheet) {
                AboutView()
            }
        }
        .onChange(of: colorScheme) { oldValue, newValue in
            setAppAppearance(newValue)
        }
    }
    
    // 重新分析所有日记
    private func reanalyzeAllJournals() {
        // 获取JournalViewModel进行分析
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name("ReanalyzeAllJournals"), object: nil)
        }
    }
    
    // 设置应用外观
    private func setAppAppearance(_ value: Int) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        
        switch value {
        case 1:
            window.overrideUserInterfaceStyle = .light
        case 2:
            window.overrideUserInterfaceStyle = .dark
        default:
            window.overrideUserInterfaceStyle = .unspecified
        }
    }
    
    // 导出数据
    private func exportData() {
        // 实现数据导出功能
    }
    
    // 备份设置
    private func backupSettings() {
        // 实现设置备份功能
    }
    
    // 重置所有设置
    private func resetAllSettings() {
        appSettings.resetAllSettings()
    }
}

// 用户资料视图
struct UserProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appSettings: AppSettings
    
    @State private var userName: String = ""
    @State private var userGender: String = "未指定"
    @State private var userBirthday: Date = Date()
    @State private var showBirthday: Bool = false
    
    let genders = ["未指定", "男", "女", "其他"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("个人信息")) {
                    TextField("姓名", text: $userName)
                    
                    Picker("性别", selection: $userGender) {
                        ForEach(genders, id: \.self) { gender in
                            Text(gender).tag(gender)
                        }
                    }
                    
                    Toggle("设置生日", isOn: $showBirthday)
                    
                    if showBirthday {
                        DatePicker("生日", selection: $userBirthday, displayedComponents: .date)
                    }
                }
                
                Section(footer: Text("这些信息仅存储在设备上，不会上传到云端。")) {
                    Button("保存") {
                        saveUserProfile()
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .navigationTitle("用户资料")
            .navigationBarItems(
                leading: Button("取消") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .onAppear {
                loadUserProfile()
            }
        }
    }
    
    // 加载用户资料
    private func loadUserProfile() {
        userName = appSettings.userName
        userGender = appSettings.userGender
        
        if let birthday = appSettings.userBirthday {
            userBirthday = birthday
            showBirthday = true
        }
    }
    
    // 保存用户资料
    private func saveUserProfile() {
        appSettings.updateUserInfo(
            name: userName,
            birthday: showBirthday ? userBirthday : nil,
            gender: userGender
        )
        
        presentationMode.wrappedValue.dismiss()
    }
}

// 关于视图
struct AboutView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                    .padding(.top, 50)
                
                Text("MindHub")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("版本 1.0.2 (Build 2)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                VStack(spacing: 8) {
                    Text("© 2025 MindHub Team")
                        .font(.caption)
                    
                    Text("保持记录，关注情绪，更好地了解自己")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.bottom, 30)
            }
            .navigationTitle("关于")
            .navigationBarItems(
                trailing: Button("完成") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(AppSettings())
            .environmentObject(HealthKitManager())
            .environmentObject(EmotionAnalysisManager())
    }
} 