# MindHub 更新日志

## 2025-05-10
### 新增功能
- **GitHub风格日记贡献图**：添加了类似GitHub贡献热图的日记记录活跃度视图，直观显示过去几个月的日记记录情况。
- **情绪唤起度和价效度分析**：为每篇日记增加了情绪唤起度和价效度分析，提供更深入的情绪指标。
- **情绪象限散点图**：添加了价效度-唤起度象限散点分布图，展示日记情绪分布在四个象限的情况。
- **情绪趋势线图**：添加了每日情绪唤起度和价效度变化的线条图，可查看情绪变化趋势。
- **欢迎卡片增强**：欢迎卡片现在显示连续记录天数和30天活跃度百分比。
- **日记卡片增强**：日记卡片现在显示情绪唤起度和价效度指标。

### 优化
- **本地情感分析**：移除了对Hugging Face API的依赖，使用本地情感分析模型，提高隐私性和响应速度。
- **情感洞察增强**：基于情绪唤起度和价效度添加了新的情感洞察类型。

### 修复
- **TabBar导航崩溃问题**：修复了在点击Tab图标导航到DashboardView时应用崩溃的问题。根本原因是缺少JournalViewModel环境对象注入。
- 在MindHubApp.swift中添加了@StateObject private var journalViewModel = JournalViewModel()并将其注入到ContentView的环境对象中。
- 崩溃日志显示问题出在DashboardView中的journalViewModel访问时发生了断言失败。

### 部署改进
- 创建了ios-deploy-app.sh脚本，简化了应用部署过程。
- 使用了ios-deploy工具直接部署应用到设备上。

## 最新修复 (2025-05-10)

### 崩溃修复
- 修复了DashboardView中使用`@_exported import struct MindHub.组件名称`导致找不到模块的问题
- 修复了JournalViewModel初始化未充分准备导致的断言失败崩溃
- 改进了MindHubApp中的数据预加载逻辑，确保ViewModel在视图加载前初始化
- 增加了DashboardView中的数据加载保护措施，避免在ViewModel未准备好时触发崩溃

### 性能优化
- 增加了数据加载延迟时间，从0.5秒增加到0.8秒，确保数据完全加载
- 移除了DashboardView中的冗余数据加载操作，避免重复分析日记条目

## 早前版本
### UI测试改进
- 修复TabBar导航：在ContentView.swift中将Label替换为VStack+Image+Text组合，添加了accessibilityLabel和identifier属性。
- 更新废弃API：替换SettingsView.swift中的UIApplication.shared.windows和更新onChange API。
- 改进UI测试：增加延迟时间至5秒，使用waitForExistence替代直接检查exists，添加新的Tab可访问性测试。 