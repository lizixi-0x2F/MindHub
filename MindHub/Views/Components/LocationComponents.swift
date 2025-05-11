import SwiftUI

// 位置信息卡片子视图
struct LocationInfoCard: View {
    let location: String?
    
    var body: some View {
        LocationCardContent(location: location)
    }
}

struct LocationCardContent: View {
    let location: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标题
            Text("位置信息")
                .font(.headline)
                .foregroundColor(ThemeColors.primaryText)
            
            if let locationText = location, !locationText.isEmpty {
                LocationDisplay(locationText: locationText)
            } else {
                LocationPlaceholder()
            }
        }
        .padding()
        .background(ThemeColors.cardBackground)
        .cornerRadius(16)
        .shadow(color: ThemeColors.shadow, radius: 4, x: 0, y: 2)
    }
}

struct LocationDisplay: View {
    let locationText: String
    
    var body: some View {
        HStack {
            Image(systemName: "mappin.circle.fill")
                .foregroundColor(.red)
                .font(.system(size: 20))
            
            Text(locationText)
                .font(.subheadline)
                .foregroundColor(ThemeColors.secondaryText)
            
            Spacer()
        }
    }
}

struct LocationPlaceholder: View {
    var body: some View {
        Text("无位置信息")
            .font(.subheadline)
            .foregroundColor(ThemeColors.tertiaryText)
    }
}

// 位置输入字段
struct LocationInputField: View {
    @Binding var location: String?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("位置")
                .font(.headline)
                .foregroundColor(ThemeColors.primaryText)
            
            HStack {
                TextField("位置", text: Binding(
                    get: { location ?? "" },
                    set: { location = $0.isEmpty ? nil : $0 }
                ))
                .padding(8)
                .background(ThemeColors.secondaryBackground)
                .cornerRadius(4)
                
                if location != nil {
                    Button(action: {
                        location = nil
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red.opacity(0.7))
                    }
                }
            }
        }
        .padding()
        .background(ThemeColors.cardBackground)
        .cornerRadius(8)
    }
} 