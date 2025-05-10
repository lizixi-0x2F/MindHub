# MindHub 部署指南

本指南将帮助您在Xcode中构建并部署MindHub应用到iOS设备。

## 前提条件

1. macOS系统
2. 安装了Xcode 15.0或更高版本
3. 有效的Apple开发者账号
4. iOS设备（iPhone或iPad）
5. 正确连接iOS设备到Mac

## 使用Xcode构建和部署

### 第1步：打开项目

```bash
open MindHub.xcodeproj
```

### 第2步：设置签名证书

1. 在Xcode的Project Navigator中点击"MindHub"项目
2. 在"Signing & Capabilities"选项卡中：
   - 确保已选择您的开发团队
   - 选择"Automatically manage signing"
   - 等待Xcode生成配置文件

### 第3步：选择目标设备

1. 在Xcode顶部的工具栏中，从设备下拉菜单中选择您的iOS设备（例如"苗壮的iPhone"）
2. 确保设备已解锁且已信任您的电脑

### 第4步：构建和运行应用

1. 在Xcode中点击运行按钮（▶）或使用快捷键Command+R
2. 等待Xcode构建应用并将其部署到设备上
3. 如果是首次部署，您可能需要在设备上信任开发者证书：
   - 在iOS设备上：设置 > 通用 > 设备管理 > [您的开发者账号] > 信任

## 使用脚本部署

我们提供了多个脚本来简化部署过程:

### 完整构建和部署脚本

```bash
# 给脚本添加执行权限
chmod +x build_and_deploy.sh

# 运行脚本
./build_and_deploy.sh
```

### 简易部署脚本（仅部署已构建的应用）

```bash
# 给脚本添加执行权限
chmod +x deploy_simple.sh

# 运行脚本
./deploy_simple.sh
```

### 使用ios-deploy直接部署

```bash
# 找到已构建的应用
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "MindHub.app" | grep -v "Build/Products/Debug-iphonesimulator" | head -1)

# 部署到设备
ios-deploy --debug --bundle "$APP_PATH"
```

## 常见问题解决

### 构建错误：找不到自定义组件

如果您遇到类似"Cannot find GitHubStyleContributionView in scope"的错误：

1. 打开 `MindHub/Views/DashboardView.swift`
2. 取消注释这行代码：`// @_exported import MindHub.ImportsList`

### 部署错误：无法安装应用

1. 检查您的开发者证书是否有效
2. 确保您的设备已添加到您的开发者账号中
3. 重新启动Xcode和您的iOS设备

### 运行时崩溃

如果应用在运行时崩溃：

1. 在Xcode中使用调试模式运行以查看崩溃日志
2. 检查应用是否已获得所需权限（健康数据访问等）
3. 检查应用日志中是否有"JournalViewModel"相关错误 