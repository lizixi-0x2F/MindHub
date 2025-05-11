import SwiftUI

// 内部导航按钮组件
fileprivate struct NavigationBackButton: View {
    var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            HStack {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                Text("返回")
            }
            .foregroundColor(ThemeColors.accent)
        }
    }
}

// 内部条目操作按钮组件
fileprivate struct NavigationEntryActionButtons: View {
    @Binding var isShowingDeleteAlert: Bool
    @Binding var isShowingEditView: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Button(action: {
                isShowingEditView = true
            }) {
                Image(systemName: "pencil")
                    .font(.system(size: 16))
                    .foregroundColor(ThemeColors.accent)
            }
            
            Button(action: {
                isShowingDeleteAlert = true
            }) {
                Image(systemName: "trash")
                    .font(.system(size: 16))
                    .foregroundColor(.red)
            }
        }
    }
} 