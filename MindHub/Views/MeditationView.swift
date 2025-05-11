import SwiftUI

struct MeditationView: View {
    // 冥想状态
    enum MeditationState {
        case ready       // 准备开始
        case active      // 冥想中
        case paused      // 暂停
        case completed   // 完成
    }
    
    // 冥想模式
    enum MeditationMode: String, CaseIterable, Identifiable {
        case breathing = "呼吸"
        case focus = "专注"
        case bodyScan = "身体扫描"
        case loving = "慈心"
        
        var id: String { self.rawValue }
        
        var description: String {
            switch self {
            case .breathing:
                return "跟随动画节奏呼吸，培养平静感"
            case .focus:
                return "专注于当下，观察思绪而不执着"
            case .bodyScan:
                return "将注意力依次放在身体各部位"
            case .loving:
                return "向自己和他人散发善意和关爱"
            }
        }
        
        var icon: String {
            switch self {
            case .breathing: return "wind"
            case .focus: return "brain.head.profile"
            case .bodyScan: return "figure.walk.motion"
            case .loving: return "heart.fill"
            }
        }
    }
    
    @State private var state: MeditationState = .ready
    @State private var selectedMode: MeditationMode = .breathing
    @State private var meditationDuration: TimeInterval = 300 // 5分钟(秒)
    @State private var elapsedTime: TimeInterval = 0
    @State private var animationScale: CGFloat = 1.0
    @State private var showModeSelection = false
    @State private var particles: [Particle] = []
    @State private var timer: Timer?
    
    // 预设的时长选项（秒）
    private let durationOptions: [TimeInterval] = [60, 300, 600, 900, 1800]
    
    var body: some View {
        ZStack {
            // 背景
            ThemeColors.base.ignoresSafeArea()
            
            VStack(spacing: 24) {
                // 顶部标题和模式选择
                topBar
                
                Spacer()
                
                // 中心动画区域
                centerAnimation
                
                // 计时器显示
                timerDisplay
                
                Spacer()
                
                // 底部控制栏
                controlBar
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 24)
            
            // 模式选择底部弹出
            if showModeSelection {
                modeSelectionSheet
            }
        }
        .onAppear {
            setupParticles()
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }
    
    // 顶部标题和模式选择
    private var topBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("冥想")
                    .font(.h1)
                    .foregroundColor(ThemeColors.textPrimary)
                
                Button(action: {
                    withAnimation(.mindHubStandard) {
                        showModeSelection.toggle()
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: selectedMode.icon)
                            .foregroundColor(ThemeColors.accent)
                        
                        Text(selectedMode.rawValue)
                            .foregroundColor(ThemeColors.accent)
                        
                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .foregroundColor(ThemeColors.accent)
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(ThemeColors.surface1)
                    .cornerRadius(8)
                }
            }
            
            Spacer()
            
            // 关闭按钮
            MindHubIconButton(icon: "xmark", size: 40) {
                // 退出冥想视图
            }
        }
    }
    
    // 中心动画区域
    private var centerAnimation: some View {
        ZStack {
            // 粒子动画
            ForEach(particles) { particle in
                Circle()
                    .fill(ThemeColors.accent.opacity(particle.opacity))
                    .frame(width: particle.size, height: particle.size)
                    .position(particle.position)
                    .animation(.linear(duration: particle.speed), value: particle.position)
            }
            
            // 呼吸动画圆圈
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            ThemeColors.accent.opacity(0.2),
                            ThemeColors.accent.opacity(0.6)
                        ]), 
                        center: .center, 
                        startRadius: 1, 
                        endRadius: 110
                    )
                )
                .frame(width: 110 * animationScale, height: 110 * animationScale)
                .scaleEffect(animationScale)
                .animation(
                    state == .active ? 
                        Animation.easeInOut(duration: 4).repeatForever(autoreverses: true) :
                        .mindHubStandard,
                    value: animationScale
                )
                .onAppear {
                    if state == .active {
                        withAnimation(Animation.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                            animationScale = state == .active ? 1.5 : 1.0
                        }
                    }
                }
                .onChange(of: state) { oldValue, newValue in
                    withAnimation(Animation.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                        animationScale = state == .active ? 1.5 : 1.0
                    }
                }
        }
        .frame(height: 220)
    }
    
    // 计时器显示
    private var timerDisplay: some View {
        VStack(spacing: 8) {
            Text(formattedTime(state == .ready ? meditationDuration : elapsedTime))
                .font(.system(size: 48, weight: .light, design: .monospaced))
                .foregroundColor(ThemeColors.textPrimary)
            
            if state == .ready {
                // 时长选择滑块
                durationSelector
            } else {
                // 进度指示
                ProgressView(value: elapsedTime, total: meditationDuration)
                    .progressViewStyle(LinearProgressViewStyle(tint: ThemeColors.accent))
                    .frame(width: 200)
            }
            
            Text(selectedMode.description)
                .font(.caption)
                .foregroundColor(ThemeColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.top, 8)
        }
    }
    
    // 持续时间选择器
    private var durationSelector: some View {
        VStack(spacing: 12) {
            // 滑块
            Slider(
                value: Binding(
                    get: { meditationDuration },
                    set: { meditationDuration = $0 }
                ),
                in: 60...1800,
                step: 60
            )
            .tint(ThemeColors.accent)
            .frame(width: 250)
            
            // 快速选择按钮
            HStack(spacing: 12) {
                ForEach(durationOptions, id: \.self) { duration in
                    Button(action: {
                        withAnimation(.mindHubStandard) {
                            meditationDuration = duration
                        }
                    }) {
                        Text(formattedTime(duration, compact: true))
                            .font(.caption)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(
                                meditationDuration == duration ?
                                    ThemeColors.accent.opacity(0.2) :
                                    ThemeColors.surface2
                            )
                            .foregroundColor(
                                meditationDuration == duration ?
                                    ThemeColors.accent :
                                    ThemeColors.textSecondary
                            )
                            .cornerRadius(6)
                    }
                }
            }
        }
    }
    
    // 底部控制栏
    private var controlBar: some View {
        HStack(spacing: 24) {
            // 仅在冥想中或暂停时显示重置按钮
            if state == .active || state == .paused {
                MindHubIconButton(icon: "arrow.counterclockwise", size: 50) {
                    resetMeditation()
                }
            }
            
            // 主控制按钮
            Button(action: {
                withAnimation(.mindHubStandard) {
                    toggleMeditationState()
                }
            }) {
                Circle()
                    .fill(ThemeColors.accent)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: controlButtonIcon)
                            .font(.system(size: 30, weight: .medium))
                            .foregroundColor(ThemeColors.textPrimary)
                    )
                    .contentShape(Circle())
            }
            .buttonStyle(PlainButtonStyle())
            
            // 仅在冥想中显示暂停/继续按钮
            if state == .active || state == .paused {
                MindHubIconButton(icon: state == .active ? "pause.fill" : "play.fill", size: 50) {
                    withAnimation(.mindHubStandard) {
                        if state == .active {
                            state = .paused
                            timer?.invalidate()
                        } else {
                            state = .active
                            startTimer()
                        }
                    }
                }
            }
        }
        .padding(.top, 16)
    }
    
    // 模式选择底部弹出
    private var modeSelectionSheet: some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack(alignment: .leading, spacing: 16) {
                // 顶部拖动条
                HStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: 2)
                        .fill(ThemeColors.surface2)
                        .frame(width: 40, height: 4)
                    Spacer()
                }
                .padding(.top, 8)
                .padding(.bottom, 16)
                
                Text("选择冥想模式")
                    .font(.h2)
                    .foregroundColor(ThemeColors.textPrimary)
                    .padding(.horizontal, 20)
                
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(MeditationMode.allCases) { mode in
                            Button(action: {
                                withAnimation(.mindHubStandard) {
                                    selectedMode = mode
                                    showModeSelection = false
                                }
                            }) {
                                HStack(spacing: 16) {
                                    ZStack {
                                        Circle()
                                            .fill(ThemeColors.accent.opacity(0.2))
                                            .frame(width: 40, height: 40)
                                        
                                        Image(systemName: mode.icon)
                                            .font(.system(size: 18))
                                            .foregroundColor(ThemeColors.accent)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(mode.rawValue)
                                            .font(.headline)
                                            .foregroundColor(ThemeColors.textPrimary)
                                        
                                        Text(mode.description)
                                            .font(.caption)
                                            .foregroundColor(ThemeColors.textSecondary)
                                            .lineLimit(2)
                                    }
                                    
                                    Spacer()
                                    
                                    if selectedMode == mode {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(ThemeColors.accent)
                                    }
                                }
                                .padding(16)
                                .background(ThemeColors.surface1)
                                .cornerRadius(12)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }
            }
            .background(ThemeColors.base)
            .cornerRadius(24, corners: [.topLeft, .topRight])
            .shadow(color: ThemeColors.shadow, radius: 20, x: 0, y: -5)
            .edgesIgnoringSafeArea(.bottom)
            .gesture(
                DragGesture()
                    .onEnded { gesture in
                        if gesture.translation.height > 100 {
                            withAnimation(.mindHubStandard) {
                                showModeSelection = false
                            }
                        }
                    }
            )
            .transition(.move(edge: .bottom))
        }
        .background(
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    withAnimation(.mindHubStandard) {
                        showModeSelection = false
                    }
                }
        )
    }
    
    // MARK: - 辅助方法
    
    // 切换冥想状态
    private func toggleMeditationState() {
        switch state {
        case .ready:
            state = .active
            startTimer()
        case .active:
            state = .completed
            timer?.invalidate()
            // 这里可以添加冥想完成的逻辑
        case .paused:
            state = .active
            startTimer()
        case .completed:
            resetMeditation()
        }
    }
    
    // 重置冥想
    private func resetMeditation() {
        timer?.invalidate()
        state = .ready
        elapsedTime = 0
    }
    
    // 启动计时器
    private func startTimer() {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if state == .active {
                elapsedTime += 1
                
                // 检查是否完成
                if elapsedTime >= meditationDuration {
                    state = .completed
                    timer?.invalidate()
                }
            }
        }
    }
    
    // 格式化时间显示
    private func formattedTime(_ seconds: TimeInterval, compact: Bool = false) -> String {
        let minutes = Int(seconds) / 60
        let remainingSeconds = Int(seconds) % 60
        
        if compact {
            return "\(minutes)分"
        } else {
            return String(format: "%02d:%02d", minutes, remainingSeconds)
        }
    }
    
    // 返回控制按钮图标
    private var controlButtonIcon: String {
        switch state {
        case .ready: return "play.fill"
        case .active: return "stop.fill"
        case .paused: return "play.fill"
        case .completed: return "arrow.clockwise"
        }
    }
    
    // 设置粒子效果
    private func setupParticles() {
        particles = []
        for _ in 0..<15 {
            particles.append(Particle.random(in: UIScreen.main.bounds))
        }
    }
}

// MARK: - 辅助结构体和扩展

// 动画粒子
struct Particle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var size: CGFloat
    var opacity: Double
    var speed: Double
    
    static func random(in rect: CGRect) -> Particle {
        let randomX = CGFloat.random(in: 0..<rect.width)
        let randomY = CGFloat.random(in: 0..<rect.height)
        let size = CGFloat.random(in: 3...8)
        let opacity = Double.random(in: 0.1...0.3)
        let speed = Double.random(in: 3...8)
        
        return Particle(
            position: CGPoint(x: randomX, y: randomY),
            size: size,
            opacity: opacity,
            speed: speed
        )
    }
}

// 圆角扩展
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// 预览
struct MeditationView_Previews: PreviewProvider {
    static var previews: some View {
        MeditationView()
            .preferredColorScheme(.dark)
    }
} 