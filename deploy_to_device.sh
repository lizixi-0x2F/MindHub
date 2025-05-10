#!/bin/bash

# MindHub自动部署脚本
# 此脚本用于自动构建MindHub应用并部署到连接的iOS设备

echo "===== MindHub自动部署工具 ====="
echo "正在准备部署环境..."

# 检查是否安装了必要的工具
if ! command -v xcodebuild &> /dev/null; then
    echo "错误: 未找到xcodebuild，请确保已安装Xcode"
    exit 1
fi

# 检查是否有设备连接
DEVICE_ID=$(xcrun xctrace list devices 2>&1 | grep -E "^iPhone|^iPad" | head -1 | sed -E 's/(.+) \(([A-Za-z0-9-]+)\) \(.+\)/\2/')

if [ -z "$DEVICE_ID" ]; then
    echo "错误: 未找到已连接的iOS设备，请确保设备已连接并解锁"
    exit 1
fi

DEVICE_NAME=$(xcrun xctrace list devices 2>&1 | grep -E "^iPhone|^iPad" | head -1 | sed -E 's/(.+) \(([A-Za-z0-9-]+)\) \(.+\)/\1/')
echo "检测到设备: $DEVICE_NAME ($DEVICE_ID)"

# 清理构建文件
echo "正在清理旧的构建文件..."
xcodebuild clean -project MindHub.xcodeproj -scheme MindHub -destination "id=$DEVICE_ID" || { echo "清理失败"; exit 1; }

# 构建应用
echo "正在构建MindHub应用..."
xcodebuild build -project MindHub.xcodeproj -scheme MindHub -destination "id=$DEVICE_ID" -configuration Debug || { echo "构建失败"; exit 1; }

# 安装应用到设备
echo "正在安装应用到设备..."
xcodebuild install -project MindHub.xcodeproj -scheme MindHub -destination "id=$DEVICE_ID" -configuration Debug || { echo "安装失败"; exit 1; }

echo "===== 部署完成 ====="
echo "MindHub应用已成功安装到您的设备"
echo "提示: 如果首次安装，请在设备上信任开发者证书:"
echo "设置 > 通用 > 设备管理 > 找到开发者证书 > 点击信任"
echo "祝您使用愉快！" 