# MindHub - 心灵情绪日记应用

MindHub是一款专注于情感分析和情绪管理的日记应用，帮助用户记录和分析自己的情绪变化。应用通过自然语言处理技术，自动分析日记内容中的情感，提供直观的情绪可视化和洞察。

## 功能特点

- **自动情绪分析**：实时分析日记内容，自动识别文本中的情绪类型和强度
- **自动情绪推断**：根据分析结果自动推断用户心情，无需手动选择
- **情绪可视化**：
  - GitHub风格的日记活跃热图(GitHubStyleContributionView)
  - 情绪价效度-唤起度象限散点图(EmotionQuadrantView)
  - 情绪变化趋势图(EmotionTrendChartView)
- **个性化洞察**：根据日记内容提供情感洞察和情绪变化趋势分析
- **标签组织**：支持为日记添加标签，便于分类和查找

## 最新更新

1. **专注于情绪核心功能**：
   - 移除了健康相关功能，专注于情绪记录和分析
   - 简化了界面，优化了用户体验

2. **自动情绪分析升级**：
   - 新增自动心情推断功能，根据情感分析结果自动选择合适的心情
   - 实时分析文本，提供即时情绪反馈

3. **UI界面优化**：
   - 重新设计了仪表盘布局，将重要信息移至顶部
   - 优化了图表可视化效果
   - 增强了卡片组件的自定义性

## 技术实现

- **语言和框架**：Swift 5.9, SwiftUI
- **UI组件**：自定义SwiftUI视图，Chart框架绘制图表
- **情感分析**：利用NLP技术进行情感分析和分类
- **本地存储**：用户数据本地存储，确保隐私安全

## 项目结构

```
MindHub/
├── MindHubApp.swift      # 应用入口和初始化
├── Views/                # 所有视图组件
│   ├── ContentView.swift             # 主TabView容器
│   ├── DashboardView.swift           # 仪表盘页面
│   ├── JournalView.swift             # 日记列表页面
│   ├── EmotionAnalysisView.swift     # 情感分析页面
│   ├── SettingsView.swift            # 设置页面
│   ├── GitHubStyleContributionView.swift  # GitHub风格的活跃热图
│   ├── EmotionQuadrantView.swift     # 情绪象限图
│   └── EmotionTrendChartView.swift   # 情绪趋势图
├── ViewModels/           # 视图模型
│   └── JournalViewModel.swift        # 日记数据处理逻辑
├── Models/               # 数据模型
│   ├── JournalEntry.swift            # 日记条目模型
│   └── AppSettings.swift             # 应用设置模型
└── Services/             # 服务层
    └── EmotionAnalysisManager.swift  # 情感分析服务
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