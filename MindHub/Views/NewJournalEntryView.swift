import SwiftUI

struct NewJournalEntryView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title = ""
    @State private var content = ""
    @State private var tags = ""
    @State private var isFavorite = false
    @State private var isAnalyzing = false
    @State private var predictedMood: Mood = .neutral
    
    let emotionAnalysisManager: EmotionAnalysisManager
    let onSave: (JournalEntry) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("标题")) {
                    TextField("标题", text: $title)
                        .accessibilityIdentifier("journal-title-input")
                }
                
                Section(header: Text("内容")) {
                    TextEditor(text: $content)
                        .frame(minHeight: 150)
                        .accessibilityIdentifier("journal-text-input")
                }
                
                Section(header: Text("标签")) {
                    TextField("使用逗号分隔标签，例如: 工作, 旅行", text: $tags)
                        .accessibilityIdentifier("tags-input")
                }
                
                Section {
                    Toggle("收藏", isOn: $isFavorite)
                        .accessibilityIdentifier("favorite-toggle")
                }
                
                if !content.isEmpty && content.count > 20 {
                    Section(header: Text("情感分析")) {
                        if isAnalyzing {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                Text("正在分析情感...")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            .accessibilityIdentifier("analyzing-indicator")
                        } else if !emotionAnalysisManager.emotionResults.isEmpty {
                            // 显示预测的心情
                            HStack {
                                Text("检测到的心情")
                                    .font(.subheadline)
                                
                                Spacer()
                                
                                HStack(spacing: 4) {
                                    Text(predictedMood.icon)
                                        .font(.title3)
                                    Text(predictedMood.rawValue)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .accessibilityIdentifier("predicted-mood")
                            
                            Divider()
                            
                            // 情感分析结果
                            ForEach(emotionAnalysisManager.emotionResults.prefix(3)) { result in
                                HStack {
                                    Text(result.emotion)
                                        .font(.subheadline)
                                    
                                    Spacer()
                                    
                                    Text(String(format: "%.1f%%", result.score * 100))
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .accessibilityIdentifier("emotion-result-\(result.emotion)")
                            }
                            
                            // 显示唤起度和价效度
                            if let firstResult = emotionAnalysisManager.emotionResults.first {
                                Divider()
                                
                                HStack {
                                    Text("情绪唤起度")
                                        .font(.subheadline)
                                    
                                    Spacer()
                                    
                                    Text(String(format: "%.1f%%", firstResult.arousal * 100))
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                HStack {
                                    Text("情绪价效度")
                                        .font(.subheadline)
                                    
                                    Spacer()
                                    
                                    Text(String(format: "%.1f%%", firstResult.valence * 100))
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .accessibilityIdentifier("emotion-results-section")
                }
            }
            .navigationTitle("新日记")
            .navigationBarItems(
                leading: Button("取消") {
                    presentationMode.wrappedValue.dismiss()
                }
                .accessibilityIdentifier("cancel-button"),
                trailing: Button("保存") {
                    saveEntry()
                }
                .disabled(title.isEmpty || content.isEmpty)
                .accessibilityIdentifier("save-button")
            )
            .onChange(of: content) { oldValue, newValue in
                if !newValue.isEmpty && newValue.count > 20 {
                    performAnalysis()
                }
            }
        }
    }
    
    // 执行情感分析
    private func performAnalysis() {
        isAnalyzing = true
        
        // 使用本地模型进行分析
        emotionAnalysisManager.analyzeEmotion(text: content)
        
        // 监听分析完成
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isAnalyzing = false
            
            // 根据情感分析结果推断心情
            predictMood()
        }
    }
    
    // 根据情感分析预测心情
    private func predictMood() {
        guard !emotionAnalysisManager.emotionResults.isEmpty else {
            predictedMood = .neutral
            return
        }
        
        // 获取最主要的情感和价效度/唤起度
        let topEmotion = emotionAnalysisManager.emotionResults.first!
        let valence = topEmotion.valence
        let arousal = topEmotion.arousal
        
        // 通过情感价效度和唤起度确定心情
        if valence >= 0.7 {
            if arousal >= 0.7 {
                predictedMood = .excited  // 高价效高唤起 = 兴奋
            } else {
                predictedMood = .happy    // 高价效低唤起 = 开心
            }
        } else if valence <= 0.3 {
            if arousal >= 0.7 {
                predictedMood = .angry    // 低价效高唤起 = 愤怒
            } else {
                predictedMood = .sad      // 低价效低唤起 = 悲伤
            }
        } else {
            if arousal >= 0.7 {
                predictedMood = .anxious  // 中价效高唤起 = 焦虑
            } else if arousal <= 0.3 {
                predictedMood = .tired    // 中价效低唤起 = 疲惫，用作放松的替代
            } else {
                predictedMood = .neutral  // 中价效中唤起 = 平静
            }
        }
        
        // 考虑情感类型进行额外调整
        let emotionType = topEmotion.emotion.lowercased()
        if emotionType.contains("joy") || emotionType.contains("happy") || emotionType.contains("喜悦") {
            predictedMood = .happy
        } else if emotionType.contains("anger") || emotionType.contains("愤怒") {
            predictedMood = .angry
        } else if emotionType.contains("sad") || emotionType.contains("悲伤") {
            predictedMood = .sad
        } else if emotionType.contains("fear") || emotionType.contains("恐惧") {
            predictedMood = .anxious
        } else if emotionType.contains("relax") || emotionType.contains("calm") || emotionType.contains("放松") || emotionType.contains("平静") {
            predictedMood = .neutral
        }
    }
    
    // 保存日记
    private func saveEntry() {
        // 处理标签
        let entryTags = tags.split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) }
        
        // 确保进行过情感分析
        if emotionAnalysisManager.emotionResults.isEmpty && content.count > 20 {
            performAnalysis()
            // 等待分析完成
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                saveEntryAfterAnalysis(tags: entryTags)
            }
        } else {
            saveEntryAfterAnalysis(tags: entryTags)
        }
    }
    
    // 分析完成后保存
    private func saveEntryAfterAnalysis(tags: [String]) {
        // 创建情感分析结果
        var emotionResults: [EmotionAnalysisResult]?
        var arousal: Double?
        var valence: Double?
        
        if !emotionAnalysisManager.emotionResults.isEmpty {
            emotionResults = emotionAnalysisManager.emotionResults.map { result in
                EmotionAnalysisResult(
                    emotion: result.emotion,
                    score: result.score,
                    arousal: result.arousal,
                    valence: result.valence
                )
            }
            
            if let firstResult = emotionAnalysisManager.emotionResults.first {
                arousal = firstResult.arousal
                valence = firstResult.valence
            }
        }
        
        // 创建新日记
        let newEntry = JournalEntry(
            title: title,
            content: content,
            date: Date(),
            mood: predictedMood,  // 使用预测的心情
            tags: tags,
            isFavorite: isFavorite,
            emotionAnalysisResults: emotionResults,
            arousal: arousal,
            valence: valence
        )
        
        // 保存并关闭
        onSave(newEntry)
        presentationMode.wrappedValue.dismiss()
    }
}

struct NewJournalEntryView_Previews: PreviewProvider {
    static var previews: some View {
        NewJournalEntryView(
            emotionAnalysisManager: EmotionAnalysisManager(),
            onSave: { _ in }
        )
    }
} 