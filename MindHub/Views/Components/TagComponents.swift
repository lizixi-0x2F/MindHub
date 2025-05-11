import SwiftUI

// 标签卡片组件
struct TagsCard: View {
    let tags: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标题
            Text("标签")
                .font(.headline)
                .foregroundColor(.primary)
            
            // 标签
            TagsList(tags: tags)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(10)
    }
}

// 标签列表组件
struct TagsList: View {
    let tags: [String]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(tags, id: \.self) { tag in
                    TagBadge(tag: tag)
                }
            }
        }
    }
}

// 标签徽章组件
struct TagBadge: View {
    let tag: String
    
    var body: some View {
        Text(tag)
            .font(.footnote)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color(.systemFill))
            .foregroundColor(.primary)
            .cornerRadius(8)
    }
}

// 标签输入字段
struct TagsInputField: View {
    @Binding var tags: [String]
    @Binding var currentTag: String
    let addTag: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("标签")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack {
                TextField("添加标签", text: $currentTag)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: addTag) {
                    Text("添加")
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(currentTag.isEmpty)
            }
            
            // 标签列表
            EditTagsList(tags: $tags)
        }
    }
}

// 编辑标签列表
struct EditTagsList: View {
    @Binding var tags: [String]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(tags, id: \.self) { tag in
                    TagItem(tag: tag, onRemove: {
                        tags.removeAll { $0 == tag }
                    })
                }
            }
        }
        .frame(height: tags.isEmpty ? 0 : 40)
    }
}

// 标签项
struct TagItem: View {
    let tag: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack {
            Text(tag)
                .padding(.leading, 8)
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
            }
            .padding(.horizontal, 4)
        }
        .padding(.vertical, 4)
        .background(Color(.systemGray5))
        .cornerRadius(8)
    }
} 