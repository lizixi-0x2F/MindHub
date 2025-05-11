import SwiftUI

/// Markdown编辑器组件
struct MarkdownEditor: View {
    @Binding var text: String
    @State private var selectedRange: NSRange?
    @FocusState private var isEditorFocused: Bool
    
    // Markdown格式控制按钮
    var body: some View {
        VStack(spacing: 0) {
            // 格式工具栏
            formatToolbar
            
            // 编辑器区域
            editorArea
        }
    }
    
    // 格式工具栏
    private var formatToolbar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // 标题按钮
                FormatButton(icon: "h.square.fill", title: "标题") {
                    applyMarkdown(prefix: "# ")
                }
                
                // 加粗按钮
                FormatButton(icon: "bold", title: "加粗") {
                    applyMarkdown(prefix: "**", suffix: "**")
                }
                
                // 斜体按钮
                FormatButton(icon: "italic", title: "斜体") {
                    applyMarkdown(prefix: "*", suffix: "*")
                }
                
                // 引用按钮
                FormatButton(icon: "text.quote", title: "引用") {
                    applyMarkdown(prefix: "> ")
                }
                
                // 列表按钮
                FormatButton(icon: "list.bullet", title: "列表") {
                    applyMarkdown(prefix: "- ")
                }
                
                // 待办事项按钮
                FormatButton(icon: "checklist", title: "待办") {
                    applyMarkdown(prefix: "- [ ] ")
                }
                
                // 链接按钮
                FormatButton(icon: "link", title: "链接") {
                    applyMarkdown(prefix: "[", suffix: "](链接地址)")
                }
                
                // 代码按钮
                FormatButton(icon: "chevron.left.forwardslash.chevron.right", title: "代码") {
                    applyMarkdown(prefix: "`", suffix: "`")
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(ThemeColors.surface2)
        }
    }
    
    // 编辑区域
    private var editorArea: some View {
        TextEditor(text: $text)
            .focused($isEditorFocused)
            .scrollContentBackground(.hidden)
            .padding(16)
            .background(ThemeColors.surface1)
            .font(.body)
            .foregroundColor(ThemeColors.textPrimary)
            .cornerRadius(12)
            .frame(minHeight: 200)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(ThemeColors.surface2, lineWidth: 1)
            )
            .onTapGesture {
                isEditorFocused = true
            }
    }
    
    // 应用Markdown格式
    private func applyMarkdown(prefix: String, suffix: String = "") {
        // 如果文本为空或光标不在文本内
        if text.isEmpty {
            text = "\(prefix)输入文本\(suffix)"
            return
        }
        
        // 默认添加到文本末尾
        // 在真实应用中，这里应该检测当前光标位置并在正确位置插入标记
        text += "\n\(prefix)输入文本\(suffix)"
    }
}

// 格式按钮
struct FormatButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                
                Text(title)
                    .font(.caption2)
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 12)
            .background(ThemeColors.surface1)
            .foregroundColor(ThemeColors.accent)
            .cornerRadius(8)
        }
    }
}

// 预览
struct MarkdownEditor_Previews: PreviewProvider {
    static var previews: some View {
        MarkdownEditor(text: .constant("这是一段**Markdown**文本\n# 标题\n- 列表项"))
            .padding()
            .background(ThemeColors.base)
            .preferredColorScheme(.dark)
    }
} 