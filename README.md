# MindHub - 心灵情绪日记应用

MindHub是一款专注于情感分析和情绪管理的日记应用，帮助用户记录和分析自己的情绪变化。应用通过苹果原生的自然语言处理(NLP)技术，自动分析日记内容中的情感，提供直观的情绪可视化和洞察。

## 功能特点

- **Apple情绪分析**：采用苹果原生NLP框架分析日记内容，准确识别文本中的情绪类型和强度
- **情绪周报**：自动生成每周情绪分析报告，包含情绪摘要、关键日记分析和个性化建议
- **自动情绪推断**：根据分析结果自动推断用户心情，无需手动选择
- **情绪可视化**：
  - GitHub风格的日记活跃热图(GitHubStyleContributionView)
  - 情绪价效度-唤起度象限散点图(EmotionQuadrantView)
  - 情绪变化趋势图(EmotionTrendChartView)
- **个性化洞察**：根据日记内容提供情感洞察和情绪变化趋势分析
- **标签组织**：支持为日记添加标签，便于分类和查找

## 最新更新

1. **Apple NLP集成**：
   - 集成苹果原生自然语言处理框架进行情感分析
   - 本地设备上进行分析，保护用户隐私
   - 支持七种基本情绪识别：喜悦、悲伤、愤怒、恐惧、厌恶、惊讶和中性

2. **情绪周报功能**：
   - 自动生成每周情绪周报，提供情绪概览和建议
   - 详细分析情绪变化趋势和分布
   - 提取关键情绪日记内容并提供个性化建议

3. **情绪可视化升级**：
   - 新增情绪象限图，展示情绪的唤起度和效价分布
   - 新增情绪趋势图，追踪情绪变化
   - 优化GitHub风格的活跃度热图展示

4. **UI界面优化**：
   - 重新设计了仪表盘布局，整合情绪分析组件
   - 优化了图表可视化效果
   - 增强了卡片组件的自定义性

## 技术实现

- **语言和框架**：Swift 5.9, SwiftUI
- **UI组件**：自定义SwiftUI视图，Chart框架绘制图表
- **情感分析**：Apple NaturalLanguage框架进行情绪识别和分析
- **本地存储**：用户数据本地存储，确保隐私安全
- **情绪模型**：采用唤起度-效价二维模型分析情绪

## 情感分析模型说明

MindHub使用Apple的NaturalLanguage框架进行情感分析。该框架具有以下特点：

- **高效的情感分析**：能够准确理解语言的上下文和情感色彩
- **多情绪识别**：能准确识别多种基本情绪及其强度
- **本地推理**：分析在设备本地运行，确保用户隐私
- **系统级优化**：作为系统组件，享有更好的性能和资源管理

模型可以捕捉到的情绪维度：
- **唤起度 (Arousal)**: 表示情绪的激活程度，从平静到激动
- **效价 (Valence)**: 表示情绪的正负性，从消极到积极

## 项目结构

```
MindHub/
├── MindHubApp.swift      # 应用入口和初始化
├── Views/                # 所有视图组件
│   ├── ContentView.swift             # 主TabView容器
│   ├── DashboardView.swift           # 仪表盘页面
│   ├── JournalView.swift             # 日记列表页面
│   ├── WeeklyReportView.swift        # 情绪周报页面
│   ├── EmotionQuadrantView.swift     # 情绪象限图
│   ├── EmotionTrendChartView.swift   # 情绪趋势图
│   ├── GitHubStyleContributionView.swift  # GitHub风格的活跃热图
│   └── SettingsView.swift            # 设置页面
├── ViewModels/           # 视图模型
│   └── JournalViewModel.swift        # 日记数据处理逻辑
├── Models/               # 数据模型
│   ├── JournalEntry.swift            # 日记条目模型
│   └── AppSettings.swift             # 应用设置模型
└── Services/             # 服务层
    └── EmotionAnalysisService.swift  # Apple NLP情感分析服务
```

## 开发环境要求

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## 安装和运行

1. 克隆仓库
```bash
git clone https://github.com/lizixi-0x2F/MindHub.git
```

2. 打开Xcode项目
```bash
cd MindHub
open MindHub.xcodeproj
```

3. 选择目标设备并运行

## 贡献指南

欢迎提交问题报告和功能请求。如果您想贡献代码：

1. Fork该仓库
2. 创建您的特性分支 (`git checkout -b feature/amazing-feature`)
3. 提交您的更改 (`git commit -m 'Add some amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 开启一个Pull Request

## 许可证

© 2025 MindHub 版权所有。本项目采用MIT许可证。 