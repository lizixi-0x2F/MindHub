#!/bin/bash

# MindHub快速部署脚本
# 使用ios-deploy工具快速部署应用到iOS设备

echo "===== MindHub快速部署工具 ====="

# 检查是否安装了ios-deploy
if ! command -v ios-deploy &> /dev/null; then
    echo "正在安装ios-deploy工具..."
    npm install -g ios-deploy || { 
        echo "安装ios-deploy失败，尝试使用brew安装..."
        brew install ios-deploy || {
            echo "错误: 无法安装ios-deploy，请手动安装后重试"
            echo "可使用命令: npm install -g ios-deploy 或 brew install ios-deploy"
            exit 1
        }
    }
fi

echo "正在构建MindHub应用..."
xcodebuild -project MindHub.xcodeproj -scheme MindHub -configuration Debug -derivedDataPath ./build

# 查找构建出的.app文件
APP_PATH=$(find ./build -name "*.app" -type d | head -1)

if [ -z "$APP_PATH" ]; then
    echo "错误: 未找到构建的.app文件"
    exit 1
fi

echo "找到应用: $APP_PATH"
echo "正在安装到设备..."

# 使用ios-deploy安装应用
ios-deploy --bundle "$APP_PATH" --debug

if [ $? -eq 0 ]; then
    echo "===== 部署成功 ====="
    echo "MindHub应用已安装到您的设备"
else
    echo "===== 部署失败 ====="
    echo "请检查设备连接和权限设置"
fi 