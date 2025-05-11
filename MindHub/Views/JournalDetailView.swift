import SwiftUI

// 使用组件化视图结构重构JournalDetailView
struct JournalDetailView: View {
    let entry: JournalEntry
    @ObservedObject var journalViewModel: JournalViewModel
    @State private var isShowingDeleteAlert = false
    @State private var isShowingEditView = false
    @State private var isAnalyzing = false
    @State private var emotionResult: EmotionResult?
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 日记内容卡片
                VStack(alignment: .leading, spacing: 16) {
                    Text(entry.title)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(entry.date, style: .date)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(entry.content)
                        .font(.body)
                        .lineSpacing(6)
                }
                .padding()
                .background(ThemeColors.cardBackground)
                .cornerRadius(16)
                
                // 情绪分析卡片
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("情绪分析")
                            .font(.headline)
                        
                        Spacer()
                        
                        if emotionResult == nil && !isAnalyzing {
                            Button(action: analyzeEmotion) {
                                Text("立即分析")
                                    .font(.subheadline)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(ThemeColors.accent)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    
                    if isAnalyzing {
                        HStack {
                            Spacer()
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                            Spacer()
                        }
                        .padding(.vertical, 30)
                    } else if let result = emotionResult ?? journalViewModel.emotionAnalysisResults[entry.id] {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .top, spacing: 12) {
                                // 情绪象限图
                                ZStack {
                                    Rectangle()
                                        .fill(Color.black.opacity(0.3))
                                        .frame(width: 100, height: 100)
                                        .cornerRadius(8)
                                    
                                    // 当前情绪点
                                    Circle()
                                        .fill(ThemeColors.accent)
                                        .frame(width: 8, height: 8)
                                        .offset(
                                            x: CGFloat(result.valence) * 40, 
                                            y: CGFloat(-result.arousal) * 40
                                        )
                                }
                                .frame(width: 100, height: 100)
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("主导情绪: \(result.dominantEmotion)")
                                        .foregroundColor(.white)
                                    
                                    Text("积极/消极: \(Int(result.valence * 100))%")
                                        .foregroundColor(.white)
                                    
                                    Text("情绪强度: \(Int(result.arousal * 100))%")
                                        .foregroundColor(.white)
                                }
                            }
                            
                            Divider().background(ThemeColors.divider)
                            
                            // 情绪解读
                            Text("本篇日记主要体现出「\(result.dominantEmotion)」情绪，整体情感较为\(result.valence > 0 ? "积极" : "消极")，情绪强度\(result.arousal > 0 ? "较高" : "较低")。")
                                .foregroundColor(.white)
                                .lineSpacing(4)
                        }
                    } else {
                        Text("点击\"立即分析\"按钮获取这篇日记的情绪分析报告")
                            .foregroundColor(ThemeColors.secondaryText)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 50)
                    }
                }
                .padding()
                .background(ThemeColors.cardBackground)
                .cornerRadius(16)
                
                // 标签卡片（如果有标签）
                if !entry.tags.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("标签")
                            .font(.headline)
                            .foregroundColor(ThemeColors.primaryText)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(entry.tags, id: \.self) { tag in
                                    Text(tag)
                                        .font(.footnote)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.blue.opacity(0.2))
                                        .foregroundColor(.blue)
                                        .cornerRadius(12)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(ThemeColors.cardBackground)
                    .cornerRadius(16)
                }
                
                // 位置信息（如果有）
                if let location = entry.location {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("位置信息")
                            .font(.headline)
                            .foregroundColor(ThemeColors.primaryText)
                        
                        HStack {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(.red)
                            
                            Text(location)
                                .foregroundColor(ThemeColors.secondaryText)
                            
                            Spacer()
                        }
                    }
                    .padding()
                    .background(ThemeColors.cardBackground)
                    .cornerRadius(16)
                }
                
                // 关键词卡片
                VStack(alignment: .leading, spacing: 12) {
                    Text("关键词")
                        .font(.headline)
                        .foregroundColor(ThemeColors.primaryText)
                    
                    // 简化的关键词提取逻辑
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 60), spacing: 8)], alignment: .leading, spacing: 8) {
                        ForEach(entry.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(ThemeColors.accent.opacity(0.2))
                                .foregroundColor(ThemeColors.accent)
                                .cornerRadius(12)
                        }
                    }
                }
                .padding()
                .background(ThemeColors.cardBackground)
                .cornerRadius(16)
            }
            .padding()
        }
        .background(ThemeColors.background.edgesIgnoringSafeArea(.all))
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("返回")
                }
                .foregroundColor(ThemeColors.accent)
            },
            trailing: HStack(spacing: 16) {
                Button(action: { isShowingEditView = true }) {
                    Image(systemName: "pencil")
                }
                
                Button(action: { isShowingDeleteAlert = true }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
        )
        .sheet(isPresented: $isShowingEditView) {
            NavigationView {
                VStack {
                    // 简化的编辑视图
                    Text("编辑日记").padding()
                }
                .navigationTitle("编辑日记")
                .navigationBarItems(
                    leading: Button("取消") {
                        isShowingEditView = false
                    },
                    trailing: Button("保存") {
                        isShowingEditView = false
                    }
                )
            }
        }
        .alert(isPresented: $isShowingDeleteAlert) {
            Alert(
                title: Text("删除日记"),
                message: Text("确定要删除这篇日记吗？此操作无法撤销。"),
                primaryButton: .destructive(Text("删除"), action: {
                    journalViewModel.deleteEntry(entry)
                    presentationMode.wrappedValue.dismiss()
                }),
                secondaryButton: .cancel(Text("取消"))
            )
        }
    }
    
    // 分析情绪 - 修复await关键字使用
    private func analyzeEmotion() {
        isAnalyzing = true
        
        Task {
            let result = await EmotionAnalysisService.shared.analyzeText(entry.content)
            
            // 在主线程更新UI
            DispatchQueue.main.async {
                self.emotionResult = result
                journalViewModel.emotionAnalysisResults[entry.id] = result
                isAnalyzing = false
            }
        }
    }
}

// 只保留预览
struct JournalDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            JournalDetailView(
                entry: JournalEntry(
                    title: "今天是美好的一天",
                    content: "今天我去了公园，看到了美丽的风景。心情非常愉快，希望明天也是这样的好天气。",
                    mood: .happy,
                    tags: ["公园", "心情好"]
                ),
                journalViewModel: JournalViewModel()
            )
        }
    }
} 