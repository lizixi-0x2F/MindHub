import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appSettings: AppSettings
    @State private var showingResetConfirmation = false
    
    var body: some View {
        NavigationView {
            ZStack {
                ThemeColors.background.edgesIgnoringSafeArea(.all)
                
                Form {
                    // 情感分析设置
                    Section {
                        Toggle("启用情感分析", isOn: $appSettings.emotionAnalysisEnabled)
                        
                        if appSettings.emotionAnalysisEnabled {
                            Toggle("自动生成周报", isOn: $appSettings.autoGenerateWeeklyReport)
                            
                            Toggle("周报通知", isOn: $appSettings.weeklyReportNotificationEnabled)
                        }
                        
                        NavigationLink(destination: EmotionAnalysisInfoView()) {
                            Text("关于情感分析")
                        }
                    }
                    header: {
                        Text("情感分析")
                    }
                    
                    // 通知设置
                    Section {
                        Toggle("每日提醒", isOn: $appSettings.dailyReminderEnabled)
                        
                        if appSettings.dailyReminderEnabled {
                            DatePicker("提醒时间", 
                                      selection: Binding(
                                          get: { Calendar.current.date(bySettingHour: appSettings.reminderHour, minute: appSettings.reminderMinute, second: 0, of: Date()) ?? Date() },
                                          set: { 
                                              let components = Calendar.current.dateComponents([.hour, .minute], from: $0)
                                              appSettings.reminderHour = components.hour ?? 20
                                              appSettings.reminderMinute = components.minute ?? 0
                                          }
                                      ),
                                      displayedComponents: .hourAndMinute)
                        }
                    }
                    header: {
                        Text("通知提醒")
                    }
                    
                    // 隐私设置
                    Section {
                        Toggle("应用锁定", isOn: $appSettings.appLockEnabled)
                        
                        if appSettings.appLockEnabled {
                            Toggle("使用Face ID/Touch ID", isOn: $appSettings.biometricAuthEnabled)
                        }
                        
                        Toggle("位置记录", isOn: $appSettings.locationTrackingEnabled)
                    }
                    header: {
                        Text("隐私设置")
                    }
                    
                    // 个人信息
                    Section {
                        TextField("您的名字", text: $appSettings.userName)
                            .autocapitalization(.words)
                    }
                    header: {
                        Text("个人信息")
                    }
                    
                    // 数据管理
                    Section {
                        Button(action: { showingResetConfirmation = true }) {
                            Text("重置所有数据")
                                .foregroundColor(.red)
                        }
                    }
                    header: {
                        Text("数据管理")
                    }
                    
                    // 关于信息
                    Section {
                        HStack {
                            Text("版本")
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(ThemeColors.secondaryText)
                        }
                        
                        HStack {
                            Text("隐私政策")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(ThemeColors.secondaryText)
                        }
                        
                        HStack {
                            Text("使用条款")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(ThemeColors.secondaryText)
                        }
                    }
                    header: {
                        Text("关于")
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("设置")
            .alert(isPresented: $showingResetConfirmation) {
                Alert(
                    title: Text("重置数据"),
                    message: Text("此操作将删除所有日记和设置，且无法恢复。确定要继续吗？"),
                    primaryButton: .destructive(Text("重置")) {
                        appSettings.resetAllSettings()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}

// 情感分析信息视图
struct EmotionAnalysisInfoView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Group {
                    Text("关于情感分析")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("MindHub使用苹果原生的自然语言处理(NLP)技术分析您的日记内容，识别文本中的情绪，并提供个性化的反馈和建议。")
                    
                    Text("情绪分析模型")
                        .font(.headline)
                    
                    Text("我们使用的是苹果官方提供的自然语言处理框架(Natural Language Framework)，这是一种先进的本地情感分析技术，专门设计用于理解和分析文本中的情感表达。该技术能够识别七种基本情绪：喜悦、悲伤、愤怒、恐惧、厌恶、惊讶和中性。")
                    
                    Text("隐私保护")
                        .font(.headline)
                    
                    Text("所有情感分析都在您的设备上本地进行，您的日记内容不会上传到任何服务器。我们重视您的隐私，确保您的个人思想和感受完全保密。")
                }
                
                Group {
                    Text("情绪周报")
                        .font(.headline)
                    
                    Text("周报功能会分析您一周内的日记，生成情绪概览、趋势图和象限分布，帮助您更好地了解自己的情绪变化，并提供个性化的建议。")
                    
                    Text("唤起度和效价")
                        .font(.headline)
                    
                    Text("我们使用两个维度来描述情绪：\n• 唤起度：表示情绪的强烈程度，从平静到兴奋\n• 效价：表示情绪的正负性，从消极到积极")
                }
            }
            .padding()
            .background(ThemeColors.background)
        }
        .navigationTitle("情感分析说明")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(AppSettings())
    }
} 