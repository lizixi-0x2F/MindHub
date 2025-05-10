#!/bin/bash

# MindHub自动部署脚本
# 此脚本用于自动构建MindHub应用并部署到iOS设备或模拟器

echo "===== MindHub自动部署工具 ====="
echo "正在准备部署环境..."

# 检查是否安装了必要的工具
if ! command -v xcodebuild &> /dev/null; then
    echo "错误: 未找到xcodebuild，请确保已安装Xcode"
    exit 1
fi

# 检查设备连接情况
echo "正在检查可用设备..."
xcrun xctrace list devices 2>&1 | grep -E "^iPhone|^iPad"

# 让用户选择部署目标
echo ""
echo "请选择部署方式:"
echo "1) 部署到真机设备"
echo "2) 部署到模拟器"
read -p "请输入选项 (1/2): " DEPLOY_OPTION

if [ "$DEPLOY_OPTION" == "1" ]; then
    # 检查是否有真机设备连接
    DEVICE_ID=$(xcrun xctrace list devices 2>&1 | grep -E "^iPhone|^iPad" | grep -v "Simulator" | head -1 | sed -E 's/(.+) \(([A-Za-z0-9-]+)\) \(.+\)/\2/')
    
    if [ -z "$DEVICE_ID" ]; then
        echo "错误: 未找到已连接的真机iOS设备，请确保设备已连接并解锁"
        exit 1
    fi
    
    DEVICE_NAME=$(xcrun xctrace list devices 2>&1 | grep -E "^iPhone|^iPad" | grep -v "Simulator" | head -1 | sed -E 's/(.+) \(([A-Za-z0-9-]+)\) \(.+\)/\1/')
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
    
else
    # 获取可用模拟器列表
    SIMULATORS=$(xcrun xctrace list devices 2>&1 | grep -E "^iPhone|^iPad" | grep "Simulator" | sed -E 's/(.+) \(([A-Za-z0-9-]+)\) \(.+\)/\2/')
    SIMULATOR_NAMES=$(xcrun xctrace list devices 2>&1 | grep -E "^iPhone|^iPad" | grep "Simulator" | sed -E 's/(.+) \(([A-Za-z0-9-]+)\) \(.+\)/\1/')
    
    # 显示模拟器列表
    echo "可用模拟器列表:"
    IFS=$'\n'
    SIMULATOR_ARRAY=($SIMULATORS)
    SIMULATOR_NAMES_ARRAY=($SIMULATOR_NAMES)
    
    for i in "${!SIMULATOR_ARRAY[@]}"; do
        echo "$((i+1))) ${SIMULATOR_NAMES_ARRAY[$i]} (${SIMULATOR_ARRAY[$i]})"
    done
    
    # 让用户选择模拟器
    read -p "请选择模拟器 (1-${#SIMULATOR_ARRAY[@]}): " SIMULATOR_CHOICE
    
    if [ -z "$SIMULATOR_CHOICE" ] || [ $SIMULATOR_CHOICE -lt 1 ] || [ $SIMULATOR_CHOICE -gt ${#SIMULATOR_ARRAY[@]} ]; then
        echo "无效选择，使用第一个模拟器"
        SIMULATOR_CHOICE=1
    fi
    
    SELECTED_SIMULATOR=${SIMULATOR_ARRAY[$((SIMULATOR_CHOICE-1))]}
    SELECTED_SIMULATOR_NAME=${SIMULATOR_NAMES_ARRAY[$((SIMULATOR_CHOICE-1))]}
    
    echo "选择了模拟器: $SELECTED_SIMULATOR_NAME"
    
    # 清理构建文件
    echo "正在清理旧的构建文件..."
    xcodebuild clean -project MindHub.xcodeproj -scheme MindHub -destination "id=$SELECTED_SIMULATOR" || { echo "清理失败"; exit 1; }
    
    # 构建应用
    echo "正在构建MindHub应用..."
    xcodebuild build -project MindHub.xcodeproj -scheme MindHub -destination "id=$SELECTED_SIMULATOR" -configuration Debug || { echo "构建失败"; exit 1; }
    
    # 启动模拟器并安装应用
    echo "正在启动模拟器并安装应用..."
    xcrun simctl boot "$SELECTED_SIMULATOR" 2>/dev/null
    xcodebuild install -project MindHub.xcodeproj -scheme MindHub -destination "id=$SELECTED_SIMULATOR" -configuration Debug || { echo "安装失败"; exit 1; }
    
    # 启动应用
    echo "正在启动应用..."
    xcrun simctl launch "$SELECTED_SIMULATOR" com.yourdomain.MindHub || { echo "启动应用失败"; }
    
    echo "===== 部署完成 ====="
    echo "MindHub应用已成功安装到模拟器"
fi

echo "祝您使用愉快！" 